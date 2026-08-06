import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_cubit.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_event.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_state.dart';
import 'package:super_fitness/features/home/presentation/screens/home_screen.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_state.dart';
import 'package:super_fitness/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:super_fitness/features/main_layout/presentation/screens/main_layout_screen.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_profile_data_use_case.dart';
import 'package:super_fitness/features/profile/presentation/screens/profile_screen.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_events.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_state.dart';

class FakeChatCubit extends Cubit<ChatState> implements ChatCubit {
  FakeChatCubit() : super(const ChatState());

  @override
  Stream<BaseUiEvent> get eventStream => const Stream.empty();

  @override
  void doEvent(ChatEvent event) {}

  @override
  void emitUiEvent(BaseUiEvent event) {}
}

class FakeWorkoutsCubit extends Cubit<WorkoutsState> implements WorkoutsCubit {
  FakeWorkoutsCubit() : super(const WorkoutsState());

  @override
  Stream<BaseUiEvent> get eventStream => const Stream.empty();

  @override
  void doEvent(WorkoutsEvents event) {}

  @override
  void emitUiEvent(BaseUiEvent event) {}
}

class FakeHomeCubit extends Cubit<HomeState> implements HomeCubit {
  FakeHomeCubit() : super(const HomeState());

  @override
  Stream<BaseUiEvent> get eventStream => const Stream.empty();

  @override
  void doEvent(HomeEvent event) {}

  @override
  void emitUiEvent(BaseUiEvent event) {}
}

class FakeMainLayoutCubit extends Cubit<MainLayoutState>
    implements MainLayoutCubit {
  FakeMainLayoutCubit() : super(const MainLayoutState(currentIndex: 0));

  @override
  void changeTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}

class _InMemoryAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => {
    'explore': 'Explore',
    'chat': 'Chat',
    'workouts': 'Workouts',
    'profile': 'Profile',
    'hi': 'Hi {}',
    'lets_start_your_day': 'Lets start your day',
    'category': 'Category',
    'gym': 'Gym',
    'fitness': 'Fitness',
    'yoga': 'Yoga',
    'aerobics': 'Aerobics',
    'trainer': 'Trainer',
    'recommendation_today': 'Recommendation today',
    'upcoming_workouts': 'Upcoming workouts',
    'seeAll': 'See All',
    'recommendationForYou': 'Recommendation for you',
    'popular_training': 'Popular training',
    'editProfile': 'Edit Profile',
    'changePassword': 'Change Password',
    'selectLanguage': 'Select Language',
    'english': 'English',
    'security': 'Security',
    'privacyPolicy': 'Privacy Policy',
    'help': 'Help',
    'logout': 'Logout',
    'selectMuscleGroup': 'Select Muscle Group',
    'connectionTimeout': 'Connection Timeout',
    'unknownError': 'Unknown Error',
    'noInternetConnection': 'No Internet Connection',
    'authFailed': 'Auth Failed',
    'serverError': 'Server Error',
    'requestCancelled': 'Request Cancelled',
    'sendTimeout': 'Send Timeout',
    'receiveTimeout': 'Receive Timeout',
    'unexpectedError': 'Unexpected Error',
    'verificationCodeSentToYourEmail': 'Verification code sent to your email',
    'verificationCodeIsCorrect': 'Verification code is correct',
    'passwordResetSuccessfully': 'Password reset successfully',
    'login_success': 'Login Success',
    'invalid credentials': 'Invalid Credentials',
    'failed': 'Failed',
    'registerSuccess': 'Register Success',
    'Email already exists': 'Email already exists',
    'Network error': 'Network error',
    'Error': 'Error',
    'ingredients': 'Ingredients',
    'description': 'Description',
    'retry': 'Retry',
    'foodRecommendation': 'Food Recommendation',
    'noMealsFound': 'No Meals Found',
    'oops': 'Oops',
    'server error': 'Server Error',
    'not found': 'Not Found',
    'athlete': 'Athlete',
    'smartCoach': 'Smart Coach',
    'howCanIAssistYouToday': 'How can I assist you today?',
    'getStarted': 'Get Started',
  };
}

/// The profile tab pulls its cubit straight from `getIt`, so the layout can't
/// render that tab without one registered.

class FakeGetProfileDataUseCase implements GetProfileDataUseCase {
  @override
  Future<BaseResponse<UserEntity>> call(bool isFromRemote) async =>
      const SuccessBaseResponse(null);
}

class FakeLogoutUseCase implements LogoutUseCase {
  @override
  Future<BaseResponse<void>> call() async => const SuccessBaseResponse(null);
}

class FakeProfileRepo implements ProfileRepoContract {
  @override
  Stream<UserEntity?> get userStream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeWorkoutsCubit fakeWorkoutsCubit;
  late FakeHomeCubit fakeHomeCubit;
  late FakeChatCubit fakeChatCubit;
  late FakeMainLayoutCubit fakeMainLayoutCubit;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    fakeWorkoutsCubit = FakeWorkoutsCubit();
    fakeHomeCubit = FakeHomeCubit();
    fakeChatCubit = FakeChatCubit();
    fakeMainLayoutCubit = FakeMainLayoutCubit();
    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(FakeGetProfileDataUseCase(), FakeLogoutUseCase()),
    );
  });

  tearDown(() => getIt.reset());

  Widget createWidgetUnderTest() {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: _InMemoryAssetLoader(),
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(800, 1200),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: MultiBlocProvider(
                providers: [
                  BlocProvider<WorkoutsCubit>.value(value: fakeWorkoutsCubit),
                  BlocProvider<HomeCubit>.value(value: fakeHomeCubit),
                  BlocProvider<ChatCubit>.value(value: fakeChatCubit),
                  BlocProvider<MainLayoutCubit>.value(
                    value: fakeMainLayoutCubit,
                  ),
                ],
                child: const MainLayoutScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  group('MainLayoutScreen Widget Tests', () {
    testWidgets(
      'Initial State: Should render Custom Navigation Items and initial HomeScreen',
      (WidgetTester tester) async {
        // Set larger surface size to avoid overflow in test environment
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify Home tab is selected by checking Key
        expect(find.byKey(const Key('home_tab')), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      },
    );

    testWidgets('Interaction: Tapping on Workout tab should update UI', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Workouts item using its Key
      await tester.tap(find.byKey(const Key('workouts_tab')));
      await tester.pumpAndSettle();

      // Verify that the WorkoutsScreen is now visible
      expect(find.byType(WorkoutsScreen), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    // Each tab's first load has to run when it is opened, not at launch —
    // otherwise the profile skeleton would be over before anyone saw the tab.
    testWidgets('does not build a tab until it is opened', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsNothing);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Interaction: Tapping on Profile tab should update UI', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Profile item using its Key
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();

      // Verify that the ProfileScreen is now visible
      expect(find.byType(ProfileScreen), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
