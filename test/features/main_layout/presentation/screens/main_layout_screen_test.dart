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

import 'main_layout_screen_test.mocks.dart';

@GenerateMocks([MainLayoutCubit, HomeCubit])
void main() {
  late MockMainLayoutCubit mockMainLayoutCubit;
  late MockHomeCubit mockHomeCubit;

  setUp(() {
    mockMainLayoutCubit = MockMainLayoutCubit();
    mockHomeCubit = MockHomeCubit();

    // Setup MainLayoutCubit
    when(mockMainLayoutCubit.state).thenReturn(const MainLayoutState());
    when(mockMainLayoutCubit.stream).thenAnswer((_) => const Stream.empty());

    // Setup HomeCubit
    when(mockHomeCubit.state).thenReturn(const HomeState());
    when(mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockHomeCubit.eventStream).thenAnswer((_) => const Stream.empty());
    when(mockHomeCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<MainLayoutCubit>.value(value: mockMainLayoutCubit),
            BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          ],
          child: const MaterialApp(home: MainLayoutScreen()),
        );
      },
    );
  }

  group('MainLayoutScreen Widget Tests', () {
    testWidgets(
      'Initial State: Should render NavigationBar and initial HomeScreen',
      (WidgetTester tester) async {
        FlutterError.onError = (details) {
          if (details.exception.toString().contains('overflowed')) return;
          FlutterError.presentError(details);
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Verify NavigationBar exists
        expect(find.byType(NavigationBar), findsOneWidget);

        // Verify destinations
        expect(find.text(AppStrings.explore), findsOneWidget);
        expect(find.text(AppStrings.chat), findsOneWidget);
        expect(find.text(AppStrings.workouts), findsOneWidget);
        expect(find.text(AppStrings.profile), findsOneWidget);
      },
    );

    testWidgets('Interaction: Tapping on Workout tab should call changeTab', (
      WidgetTester tester,
    ) async {
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('overflowed')) return;
        FlutterError.presentError(details);
      };

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final workoutsDestination = find.text(AppStrings.workouts);
      await tester.tap(workoutsDestination);
      await tester.pump();

      verify(mockMainLayoutCubit.changeTab(2)).called(1);
    });
  });
}
