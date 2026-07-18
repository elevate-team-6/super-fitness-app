import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/di/di.dart';
import 'config/services/auth_service.dart';
import 'core/utils/app_constants.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  configureDependencies();

  final isOnboardingDone = await AuthService.isOnboardingCompleted();
  final isLoggedIn = await AuthService.isLoggedIn();
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
          title: 'Flowers App',
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