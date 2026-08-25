import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:super_fitness/core/network/ollama_config.dart';

import 'config/di/di.dart';
import 'config/services/auth_service.dart';
import 'config/services/google_auth_service.dart';
import 'config/services/remote_config_service.dart';
import 'core/data/local/sqlite/asset_installer.dart';
import 'core/utils/app_constants.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite has no native implementation on the web. sqflite_common_ffi_web
  // provides a databaseFactory backed by IndexedDB. The no-worker variant
  // avoids a SharedWorker response-serialization issue on Chrome.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }

  // Initialize Firebase, Hive and Localization in parallel
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Hive.initFlutter(),
  ]);

  // Setup Crashlytics non-blockingly to avoid slowing down startup
  _setupCrashlytics();

  // `serverClientId` is only supported on Android/iOS. On web, google_sign_in_web
  // reads the client ID from the <meta name="google-signin-client_id"> tag in
  // web/index.html instead, and throws an assertion error if serverClientId
  // is passed at all. So we only pass it on non-web platforms.
  await GoogleAuthService.initialize(
    serverClientId: kIsWeb ? null : AppConstants.googleServerClientId,
  );

  configureDependencies();

  // Initialize Remote Config before starting the app.
  // This makes it safe for all other singletons to access it synchronously.
  await getIt<RemoteConfigService>().initialize();

  // Validate Ollama Configuration
  getIt<OllamaConfig>().validateConfig();

  await getIt<AssetInstaller>().initialize();

  final results = await Future.wait([
    AuthService.isOnboardingCompleted(),
    AuthService.isLoggedIn(),
  ]);

  final isOnboardingDone = results[0];
  final isLoggedIn = results[1];

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale(AppConstants.englishCode),
        Locale(AppConstants.arabicCode),
      ],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,

      child: MyApp(isOnboardingDone: isOnboardingDone, isLoggedIn: isLoggedIn),
    ),
  );
}

/// Sets up Crashlytics error handlers.
/// This is separated to keep main() clean and avoid blocking the startup flow.
///
/// Firebase Crashlytics has no web SDK/plugin — calling any of its methods
/// on the web throws (e.g. "isCrashlyticsCollectionEnabled" assertion
/// failures), so we skip wiring it up entirely when running on the web.
void _setupCrashlytics() {
  if (kIsWeb) return;

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class MyApp extends StatelessWidget {
  final bool isOnboardingDone;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isOnboardingDone,
    required this.isLoggedIn,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Sync Intl global locale with EasyLocalization's locale
    Intl.defaultLocale = context.locale.languageCode;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: 'Super Fitness',
          theme: AppTheme.mainTheme,
          navigatorKey: AppRoutes.navigatorKey,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: isOnboardingDone
              ? isLoggedIn
                    ? AppRoutes.mainLayout
                    : AppRoutes.login
              : AppRoutes.onboarding,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
        );
      },
    );
  }
}
