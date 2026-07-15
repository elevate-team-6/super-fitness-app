import 'package:flutter/material.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/screens/verify_reset_code_screen.dart';

import '../../features/onboarding/screens/onboarding_screen.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String registerScreen = 'register';
  static const String forgetPassword = '/forgotPassword';
  static const String resetPassword = '/resetPassword';
  static const String verifyResetCode = '/VerifyResetCode';
  static const String mainLayout = 'mainLayout';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case onboarding:
          return MaterialPageRoute(builder: (_) => OnboardingScreen());
        case AppRoutes.forgetPassword:
          return MaterialPageRoute(
            builder: (_) => const ForgotPasswordScreen(),
          );

        case AppRoutes.verifyResetCode:
          return MaterialPageRoute(
            builder: (_) =>
                VerifyResetCodeScreen(email: settings.arguments as String),
          );

        case AppRoutes.resetPassword:
          return MaterialPageRoute(
            builder: (_) =>
                ResetPasswordScreen(email: settings.arguments as String),
          );

        default:
          return _unDefinedRoute(settings.name);
      }
    } catch (e) {
      return _errorRoute(e.toString());
    }
  }

  static MaterialPageRoute<dynamic> _unDefinedRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'No route defined for $name',
            style: AppTextStyles.white16500,
          ),
        ),
      ),
    );
  }

  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'Something went wrong\n$message',
            style: AppTextStyles.white16500,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
