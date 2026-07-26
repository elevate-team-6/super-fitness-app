import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_state.dart';
import 'package:super_fitness/features/main_layout/presentation/cubit/main_layout_cubit.dart';
import 'package:super_fitness/features/main_layout/presentation/screens/main_layout_screen.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_state.dart';

import 'main_layout_screen_test.mocks.dart';

@GenerateMocks([MainLayoutCubit, HomeCubit, WorkoutsCubit])
void main() {
  late MockMainLayoutCubit mockMainLayoutCubit;
  late MockHomeCubit mockHomeCubit;
  late MockWorkoutsCubit mockWorkoutsCubit;

  setUp(() {
    mockMainLayoutCubit = MockMainLayoutCubit();
    mockHomeCubit = MockHomeCubit();
    mockWorkoutsCubit = MockWorkoutsCubit();

    // Setup MainLayoutCubit
    when(mockMainLayoutCubit.state).thenReturn(const MainLayoutState());
    when(mockMainLayoutCubit.stream).thenAnswer((_) => const Stream.empty());

    // Setup HomeCubit
    when(mockHomeCubit.state).thenReturn(const HomeState());
    when(mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockHomeCubit.eventStream).thenAnswer((_) => const Stream.empty());
    when(mockHomeCubit.close()).thenAnswer((_) async => {});

    // Setup WorkoutsCubit
    when(mockWorkoutsCubit.state).thenReturn(const WorkoutsState());
    when(mockWorkoutsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockWorkoutsCubit.eventStream).thenAnswer((_) => const Stream.empty());
    when(mockWorkoutsCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<MainLayoutCubit>.value(value: mockMainLayoutCubit),
            BlocProvider<HomeCubit>.value(value: mockHomeCubit),
            BlocProvider<WorkoutsCubit>.value(value: mockWorkoutsCubit),
          ],
          child: const MaterialApp(home: MainLayoutScreen()),
        );
      },
    );
  }

  group('MainLayoutScreen Widget Tests', () {
    testWidgets(
      'Initial State: Should render Custom Bottom NavBar and initial HomeScreen',
      (WidgetTester tester) async {
        final originalOnError = FlutterError.onError;
        addTearDown(() => FlutterError.onError = originalOnError);
        FlutterError.onError = (details) {
          if (details.exception.toString().contains('overflowed')) return;
          FlutterError.presentError(details);
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Verify custom navbar items exist by key
        expect(find.byKey(const Key('home_tab')), findsOneWidget);
        expect(find.byKey(const Key('chat_tab')), findsOneWidget);
        expect(find.byKey(const Key('workouts_tab')), findsOneWidget);
        expect(find.byKey(const Key('profile_tab')), findsOneWidget);

        // Verify labels (since they are in FittedBox/Row, they should be found)
        expect(find.text(AppStrings.explore), findsOneWidget);
      },
    );

    testWidgets('Interaction: Tapping on Workout tab should call changeTab', (
      WidgetTester tester,
    ) async {
      final originalOnError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = originalOnError);
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('overflowed')) return;
        FlutterError.presentError(details);
      };

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final workoutsTab = find.byKey(const Key('workouts_tab'));
      await tester.tap(workoutsTab);
      await tester.pump();

      verify(mockMainLayoutCubit.changeTab(2)).called(1);
    });
  });
}
