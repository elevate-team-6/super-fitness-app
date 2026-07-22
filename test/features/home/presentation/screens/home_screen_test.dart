import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/home/presentation/screens/home_screen.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_cubit.dart';
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
  });

  tearDown(() {
    eventController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const HomeScreen(),
        ),
      ),
    );
  }

  testWidgets('should render all sections on HomeScreen', (WidgetTester tester) async {
    // Easy Localization might need mock or initialization in tests if it uses context
    // For now, let's assume it works or we wrap it in a mock if it fails.

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(RecommendationTodaySection), findsOneWidget);
    expect(find.byType(UpcomingWorkoutsSection), findsOneWidget);
    expect(find.byType(RecommendationForYouSection), findsOneWidget);
    expect(find.byType(PopularTrainingSection), findsOneWidget);
  });
}
