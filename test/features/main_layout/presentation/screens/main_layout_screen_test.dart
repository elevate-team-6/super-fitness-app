import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/home/presentation/screens/home_screen.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/main_layout/presentation/screens/main_layout_screen.dart';
import 'package:super_fitness/features/workouts/presentation/screens/workouts_screen.dart';
import 'package:super_fitness/features/profile/presentation/screens/profile_screen.dart';
import 'package:super_fitness/features/workouts/presentation/view_model/workouts_view_model/workouts_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_model/workouts_view_model/workouts_state.dart';
import 'package:super_fitness/features/workouts/presentation/view_model/workouts_view_model/workouts_events.dart';

class FakeWorkoutsCubit extends Cubit<WorkoutsState> implements WorkoutsCubit {
  FakeWorkoutsCubit() : super(const WorkoutsState());

  @override
  Stream<BaseUiEvent> get eventStream => const Stream.empty();

  @override
  void doEvent(WorkoutsEvents event) {}

  @override
  void emitUiEvent(BaseUiEvent event) {}
}

class FakeGetCachedUserUseCase implements GetCachedUserUseCase {
  @override
  Future<UserEntity?> call() async => null;
}

class FakeLogoutUseCase implements LogoutUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<BaseResponse<void>> call() async => const SuccessBaseResponse(null);
}

void main() {
  late FakeWorkoutsCubit fakeWorkoutsCubit;

  setUp(() {
    fakeWorkoutsCubit = FakeWorkoutsCubit();
    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(FakeGetCachedUserUseCase(), FakeLogoutUseCase()),
    );
  });

  tearDown(() => getIt.reset());

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<WorkoutsCubit>.value(
            value: fakeWorkoutsCubit,
            child: const MainLayoutScreen(),
          ),
        );
      },
    );
  }

  group('MainLayoutScreen Widget Tests', () {
    testWidgets(
      'Initial State: Should render Custom Navigation Items and initial HomeScreen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1125, 2436);
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

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
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('workouts_tab')));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutsScreen), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Interaction: Tapping on Profile tab should update UI', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
