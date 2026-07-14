import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

import '../../features/auth/presentation/screens/complete_register_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String registerScreen = 'register';
  static const String completeRegister = 'completeRegister';
  static const String forgetPassword = '/forgotPassword';
  static const String changePassword = '/changePassword';
  static const String verifyResetCode = '/VerifyResetCode';
  static const String mainLayout = 'mainLayout';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case onboarding:
          return MaterialPageRoute(builder: (_) => OnboardingScreen());
        case registerScreen:
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: getIt<RegisterCubit>(),
              child: const RegisterScreen(),
            ),
          );
        case completeRegister:
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: getIt<SignupCubit>(),
              child: const CompleteRegisterScreen(),
            ),
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
