import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/di/di.dart';
import 'config/services/auth_service.dart';
import 'config/services/google_auth_service.dart';
import 'core/utils/app_constants.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Localization in parallel
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  // Setup Crashlytics non-blockingly to avoid slowing down startup
  _setupCrashlytics();

  await GoogleAuthService.initialize(
    serverClientId: AppConstants.googleServerClientId,
  );

  configureDependencies();

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

      child: MyApp(isOnboardingDone: isOnboardingDone, isLoggedIn: isLoggedIn),
    ),
  );
}

/// Sets up Crashlytics error handlers.
/// This is separated to keep main() clean and avoid blocking the startup flow.
void _setupCrashlytics() {
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
