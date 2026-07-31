import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/auth/domain/entities/social_signup_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/presentation/screens/change_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/screens/login_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_event.dart';
import 'package:super_fitness/features/profile/domain/entities/complete_register_mode.dart';
import 'package:super_fitness/features/profile/domain/entities/edit_profile_section.dart';
import 'package:super_fitness/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart';
import '../../features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';

import '../../features/auth/presentation/screens/complete_register_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import '../../features/home/presentation/screens/details_food_screen.dart';
import '../../features/home/presentation/screens/food_screen.dart';
import '../../features/home/presentation/view_models/details_food_view_model/details_food_cubit.dart';
import '../../features/home/presentation/view_models/details_food_view_model/details_food_event.dart';
import '../../features/home/presentation/view_models/food_view_model/food_cubit.dart';
import '../../features/home/presentation/view_models/food_view_model/food_event.dart';
import '../../features/home/presentation/view_models/home_view_model/home_cubit.dart';
import '../../features/home/presentation/view_models/home_view_model/home_event.dart';
import '../../features/main_layout/presentation/cubit/main_layout_cubit.dart';
import '../../features/main_layout/presentation/screens/main_layout_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/web_view_screen.dart';
import '../../features/workouts/domain/entities/exercise_entity.dart';
import '../../features/workouts/presentation/screens/exercise_details_screen.dart';
import '../../features/workouts/presentation/screens/exercise_screen.dart';
import '../../features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import '../../features/workouts/presentation/view_models/workouts_view_model/workouts_cubit.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String registerScreen = 'register';
  static const String completeRegister = 'completeRegister';
  static const String forgetPassword = '/forgotPassword';
  static const String changePassword = '/changePassword';
  static const String mainLayout = 'mainLayout';
  static const String exerciseScreen = 'exerciseScreen';
  static const String food = 'food';
  static const String detailsFood = 'detailsFood';
  static const String exerciseDetails = 'exerciseDetails';
  static const String webView = 'webView';
  static const String editProfile = 'editProfile';

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

          if (args.mode == CompleteRegisterMode.edit) {
            return MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: args.editProfileCubit!,
                child: CompleteRegisterScreen(
                  mode: args.mode,
                  section: args.section,
                ),
              ),
            );
          } else {
            final RegisterCubit cubit;
            if (args.socialData != null) {
              cubit = getIt<RegisterCubit>();
              cubit.doEvent(InitializeFromSocialEvent(args.socialData!));
            } else {
              cubit = args.registerCubit!;
            }

            return MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const CompleteRegisterScreen(
                  mode: CompleteRegisterMode.register,
                ),
              ),
            );
          }

        case editProfile:
          final args = settings.arguments as EditProfileArgs;
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) =>
                  getIt<EditProfileCubit>()
                    ..doEvent(InitializeProfileEvent(args.user)),
              child: EditProfileScreen(user: args.user),
            ),
          );

        case forgetPassword:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<ForgotPasswordCubit>(),
              child: const ForgotPasswordScreen(),
            ),
          );

        case changePassword:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<ChangePasswordCubit>(),
              child: const ChangePasswordScreen(),
            ),
          );

        case mainLayout:
          return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<MainLayoutCubit>()),
                BlocProvider(
                  create: (_) =>
                      getIt<HomeCubit>()
                        ..doEvent(const FetchAllHomeDataEvent()),
                ),
                BlocProvider(create: (context) => getIt<WorkoutsCubit>()),
              ],
              child: const MainLayoutScreen(),
            ),
          );

        case food:
          final args = settings.arguments as FoodScreenArgs?;

          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<FoodCubit>()
                ..doIntent(
                  GetMealsCategoriesEvent(initialCategory: args?.categoryName),
                ),
              child: const FoodScreen(),
            ),
          );

        case detailsFood:
          final args = settings.arguments as DetailsFoodArgs;

          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) =>
                  getIt<DetailsFoodCubit>()
                    ..doIntent(LoadDetailsFoodEvent(args.mealId)),
              child: DetailsFoodScreen(mealName: args.mealName),
            ),
          );

        case webView:
          final args = settings.arguments as WebViewArgs;

          return MaterialPageRoute(
            builder: (_) => WebViewScreen(title: args.title, url: args.url),
          );

        case exerciseScreen:
          final args = settings.arguments as ExerciseArgs;
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<ExerciseCubit>(),
              child: ExerciseScreen(
                primeMoverMuscleId: args.primeMoverMuscleId,
                primeMoverMuscleName: args.primeMoverMuscleName,
              ),
            ),
          );

        case exerciseDetails:
          final exercise = settings.arguments as ExerciseEntity;
          return MaterialPageRoute(
            builder: (_) => ExerciseDetailsScreen(exercise: exercise),
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

class FoodScreenArgs {
  final String? categoryName;

  FoodScreenArgs({this.categoryName});
}

class DetailsFoodArgs {
  final String mealId;

  /// Already known from the grid card that was tapped, so the app bar has a
  /// title to show while the full record is still loading.
  final String mealName;

  DetailsFoodArgs({required this.mealId, required this.mealName});
}

class CompleteRegisterArgs {
  final RegisterCubit? registerCubit;
  final EditProfileCubit? editProfileCubit;
  final SocialSignupEntity? socialData;
  final CompleteRegisterMode mode;
  final EditProfileSection? section;

  const CompleteRegisterArgs({
    RegisterCubit? cubit,
    RegisterCubit? registerCubit,
    this.editProfileCubit,
    this.socialData,
    this.mode = CompleteRegisterMode.register,
    this.section,
  }) : registerCubit = registerCubit ?? cubit;

  RegisterCubit? get cubit => registerCubit;
}

class EditProfileArgs {
  final UserEntity user;
  const EditProfileArgs({required this.user});
}

class WebViewArgs {
  /// Shown in the app bar while the page loads, so the user isn't looking at a
  /// blank header.
  final String title;
  final String url;

  const WebViewArgs({required this.title, required this.url});
}

class ExerciseArgs {
  final String primeMoverMuscleId;
  final String primeMoverMuscleName;

  const ExerciseArgs({
    required this.primeMoverMuscleId,
    required this.primeMoverMuscleName,
  });
}
