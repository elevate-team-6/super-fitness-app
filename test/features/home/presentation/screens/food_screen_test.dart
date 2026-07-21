import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_meal_time_use_case.dart';
import 'package:super_fitness/features/home/presentation/screens/food_screen.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_event.dart';
import 'package:super_fitness/core/widgets/custom_card.dart';

import 'food_screen_test.mocks.dart';

// easy_localization isn't initialized here, so `.tr()` returns the raw key —
// same convention the other widget tests in this repo rely on.
@GenerateMocks([GetMealsByMealTimeUseCase])
void main() {
  late MockGetMealsByMealTimeUseCase useCase;

  // Blank thumbnails on purpose: CustomCard renders those as a flat box, while
  // a real URL would sit on CustomCachedImage's spinner and hang pumpAndSettle.
  const meals = [
    MealEntity(id: '1', name: 'Brown Stew Chicken', thumbnail: ''),
    MealEntity(id: '2', name: 'Chicken Alfredo', thumbnail: ''),
  ];

  setUp(() {
    provideDummy<BaseResponse<List<MealEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetMealsByMealTimeUseCase();
  });

  Widget createWidgetUnderTest(FoodCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(value: cubit, child: const FoodScreen()),
      ),
    );
  }

  testWidgets('renders a card per meal once loaded', (tester) async {
    when(
      useCase(any),
    ).thenAnswer((_) async => const SuccessBaseResponse(meals));
    final cubit = FoodCubit(useCase)..doIntent(const LoadMealsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsNWidgets(2));
    expect(find.text('Brown Stew Chicken'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('shows the retry view on failure and refetches when tapped', (
    tester,
  ) async {
    when(useCase(any)).thenAnswer((_) async => const ErrorBaseResponse('boom'));
    final cubit = FoodCubit(useCase)..doIntent(const LoadMealsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(CustomErrorStateView), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);

    when(
      useCase(any),
    ).thenAnswer((_) async => const SuccessBaseResponse(meals));
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.byType(CustomErrorStateView), findsNothing);
    expect(find.byType(CustomCard), findsNWidgets(2));
    await cubit.close();
  });

  testWidgets('shows the empty message when the meal time has no meals', (
    tester,
  ) async {
    when(
      useCase(any),
    ).thenAnswer((_) async => const SuccessBaseResponse(<MealEntity>[]));
    final cubit = FoodCubit(useCase)..doIntent(const LoadMealsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noMealsFound), findsOneWidget);
    expect(find.byType(CustomCard), findsNothing);
    await cubit.close();
  });

  testWidgets('tapping a tab loads that meal time', (tester) async {
    when(
      useCase(any),
    ).thenAnswer((_) async => const SuccessBaseResponse(meals));
    final cubit = FoodCubit(useCase)..doIntent(const LoadMealsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    // The tabs scroll horizontally, so Dinner may sit outside the viewport.
    await tester.ensureVisible(find.text(AppStrings.dinner));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.dinner));
    await tester.pumpAndSettle();

    expect(cubit.state.selectedMealTime, MealTime.dinner);
    verify(useCase(MealTime.dinner)).called(1);
    await cubit.close();
  });
}
