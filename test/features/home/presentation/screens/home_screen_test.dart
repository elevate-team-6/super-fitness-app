import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/widgets/app_shimmer.dart';
import 'package:super_fitness/features/home/presentation/screens/home_screen.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_state.dart';
import 'package:super_fitness/features/home/presentation/widgets/popular_training_section.dart';
import 'package:super_fitness/features/home/presentation/widgets/recommendation_for_you_section.dart';
import 'package:super_fitness/features/home/presentation/widgets/recommendation_today_section.dart';
import 'package:super_fitness/features/home/presentation/widgets/upcoming_workouts_section.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([HomeCubit])
void main() {
  late MockHomeCubit mockHomeCubit;
  late StreamController<BaseUiEvent> eventController;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();

    when(mockHomeCubit.state).thenReturn(const HomeState());
    when(mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockHomeCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockHomeCubit.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    eventController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        home: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const HomeScreen(),
        ),
      ),
    );
  }

  group('HomeScreen Senior Level Tests', () {
    void setupOverflowHandler() {
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('overflowed')) return;
        FlutterError.presentError(details);
      };
    }

    testWidgets('should render all sections on HomeScreen', (
      WidgetTester tester,
    ) async {
      setupOverflowHandler();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(RecommendationTodaySection), findsOneWidget);
      expect(find.byType(UpcomingWorkoutsSection), findsOneWidget);
      expect(find.byType(RecommendationForYouSection), findsOneWidget);
      expect(find.byType(PopularTrainingSection), findsOneWidget);
    });

    testWidgets('should show shimmers when state is loading', (
      WidgetTester tester,
    ) async {
      setupOverflowHandler();
      when(
        mockHomeCubit.state,
      ).thenReturn(const HomeState(homeUserStatus: BaseState(isLoading: true)));

      await tester.pumpWidget(createWidgetUnderTest());

      // Check for AppShimmer which is returned by HomeSectionsShimmer static methods
      expect(find.byType(AppShimmer), findsWidgets);
    });

    testWidgets('should trigger FetchAllHomeDataEvent on pull-to-refresh', (
      WidgetTester tester,
    ) async {
      setupOverflowHandler();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Wait for animation

      verify(mockHomeCubit.doEvent(const FetchAllHomeDataEvent())).called(1);
    });

    testWidgets('should react to DisplayErrorEvent from Cubit', (
      WidgetTester tester,
    ) async {
      setupOverflowHandler();
      await tester.pumpWidget(createWidgetUnderTest());

      // Emit error event
      eventController.add(DisplayErrorEvent('Test Error Message'));

      // BotToast might take some time to show
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // BotToast doesn't use standard SnackBar, it adds to overlay.
      // We check if the text is found on screen.
      expect(find.text('Test Error Message'), findsOneWidget);
    });
  });
}
