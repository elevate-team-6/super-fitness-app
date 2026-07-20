import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/auth/domain/entities/social_signup_entity.dart';
import 'package:super_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_event.dart';
import '../../features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';

import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/complete_register_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import '../../features/home/domain/entities/meal_time.dart';
import '../../features/home/presentation/screens/food_screen.dart';
import '../../features/home/presentation/screens/details_food_screen.dart';
import '../../features/home/presentation/view_model/food_view_model/food_cubit.dart';
import '../../features/home/presentation/view_model/food_view_model/food_event.dart';
import '../../features/home/presentation/view_model/details_food_view_model/details_food_cubit.dart';
import '../../features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import '../../features/main_layout/presentation/screens/main_layout_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String registerScreen = 'register';
  static const String completeRegister = 'completeRegister';
  static const String forgetPassword = '/forgotPassword';
  static const String mainLayout = 'mainLayout';
  static const String food = 'food';
  static const String detailsFood = 'detailsFood';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case onboarding:
          return MaterialPageRoute(builder: (_) => OnboardingScreen());

        case login:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<LoginCubit>(),
              child: const LoginScreen(),
            ),
          );

        case registerScreen:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<RegisterCubit>(),
              child: const RegisterScreen(),
            ),
          );
        case completeRegister:
          final args = settings.arguments as CompleteRegisterArgs;
          final RegisterCubit cubit;

          if (args.socialData != null) {
            cubit = getIt<RegisterCubit>();
            cubit.doEvent(InitializeFromSocialEvent(args.socialData!));
          } else {
            cubit = args.cubit!;
          }

          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: const CompleteRegisterScreen(),
            ),
          );
        case forgetPassword:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<ForgotPasswordCubit>(),
              child: const ForgotPasswordScreen(),
            ),
          );

        case mainLayout:
          return MaterialPageRoute(builder: (_) => const MainLayoutScreen());

        case food:
          final args = settings.arguments as FoodArgs;

          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<FoodCubit>()
                ..doIntent(SelectMealTimeEvent(args.mealTime)),
              child: const FoodScreen(),
            ),
          );

        case detailsFood:
          final args = settings.arguments as DetailsFoodArgs;

          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<DetailsFoodCubit>()
                ..setMealId(args.mealId)
                ..doIntent(const LoadDetailsFoodEvent()),
              child: DetailsFoodScreen(mealName: args.mealName),
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

class ForgotPasswordArgs {
  final ForgotPasswordCubit cubit;
  final String email;

  ForgotPasswordArgs({required this.cubit, required this.email});
}

class FoodArgs {
  /// Meal time the food screen opens on, set by whichever Home card was tapped.
  final MealTime mealTime;

  FoodArgs(this.mealTime);
}

class DetailsFoodArgs {
  final String mealId;

  /// Already known from the grid card that was tapped, so the app bar has a
  /// title to show while the full record is still loading.
  final String mealName;

  DetailsFoodArgs({required this.mealId, required this.mealName});
}

class CompleteRegisterArgs {
  final RegisterCubit? cubit;
  final SocialSignupEntity? socialData;

  CompleteRegisterArgs({this.cubit, this.socialData});
}
