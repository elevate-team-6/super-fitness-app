import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/presentation/screens/details_food_screen.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/widgets/details_food_hero.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_ingredients_list.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_nutrition_bar.dart';

import 'details_food_screen_test.mocks.dart';

// easy_localization isn't initialized here, so `.tr()` returns the raw key —
// same convention the other widget tests in this repo rely on.
@GenerateMocks([GetDetailsFoodUseCase])
void main() {
  late MockGetDetailsFoodUseCase useCase;

  const details = DetailsFoodEntity(
    id: '52959',
    name: 'Baked salmon with fennel',
    thumbnail: '',
    category: 'Seafood',
    area: 'British',
    instructions: 'Heat oven to 180C and bake for 15 mins.',
    youtubeUrl: 'https://www.youtube.com/watch?v=xvPR2Tfw5k0',
    tags: ['Paleo', 'Keto'],
    ingredients: [
      MealIngredientEntity(name: 'Salmon', measure: '350g'),
      MealIngredientEntity(name: 'Fennel', measure: '2 medium'),
    ],
  );

  setUp(() {
    provideDummy<BaseResponse<DetailsFoodEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetDetailsFoodUseCase();
  });

  Widget createWidgetUnderTest(DetailsFoodCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const DetailsFoodScreen(mealName: 'Baked salmon with fennel'),
        ),
      ),
    );
  }

  DetailsFoodCubit buildCubit() =>
      DetailsFoodCubit(useCase)..setMealId('52959');

  testWidgets('renders the description and ingredients once loaded', (
    tester,
  ) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.description), findsOneWidget);
    expect(
      find.text('Heat oven to 180C and bake for 15 mins.'),
      findsOneWidget,
    );

    expect(find.text(AppStrings.ingredients), findsOneWidget);
    expect(find.byType(MealIngredientsList), findsOneWidget);
    expect(find.text('Salmon'), findsOneWidget);
    expect(find.text('350g'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows the nutrition bar with all four macros', (tester) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(MealNutritionBar), findsOneWidget);
    expect(find.text(AppStrings.energy), findsOneWidget);
    expect(find.text(AppStrings.protein), findsOneWidget);
    expect(find.text(AppStrings.carbs), findsOneWidget);
    expect(find.text(AppStrings.fat), findsOneWidget);

    await cubit.close();
  });

  testWidgets('offers the video when the recipe has one', (tester) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    final hero = tester.widget<DetailsFoodHero>(find.byType(DetailsFoodHero));
    expect(hero.onPlay, isNotNull);

    await cubit.close();
  });

  // Plenty of TheMealDB recipes have a blank `strYoutube`, so the play button
  // has to disappear rather than open a dead page.
  testWidgets('hides the play button when the recipe has no video', (
    tester,
  ) async {
    const noVideo = DetailsFoodEntity(
      id: '1',
      name: 'No video meal',
      thumbnail: '',
      instructions: 'Cook it.',
    );
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(noVideo));
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    final hero = tester.widget<DetailsFoodHero>(find.byType(DetailsFoodHero));
    expect(hero.onPlay, isNull);

    await cubit.close();
  });

  // The hero replaced the app bar, so it owns the only way back out of a
  // loaded screen.
  testWidgets('the hero back button pops the route', (tester) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    final hero = tester.widget<DetailsFoodHero>(find.byType(DetailsFoodHero));
    expect(hero.onBack, isNotNull);

    await cubit.close();
  });

  testWidgets('shows the meal name passed in while the record loads', (
    tester,
  ) async {
    when(useCase(any)).thenAnswer(
      (_) async => await Future.delayed(
        const Duration(milliseconds: 50),
        () => const SuccessBaseResponse(details),
      ),
    );
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pump();

    final hero = tester.widget<DetailsFoodHero>(find.byType(DetailsFoodHero));
    expect(hero.name, 'Baked salmon with fennel');

    await tester.pumpAndSettle();
    await cubit.close();
  });

  testWidgets('shows the retry view on failure and refetches when tapped', (
    tester,
  ) async {
    when(useCase(any))
        .thenAnswer((_) async => const ErrorBaseResponse('offline'));
    final cubit = buildCubit()..doIntent(const LoadDetailsFoodEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(CustomErrorStateView), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);

    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.byType(CustomErrorStateView), findsNothing);
    expect(find.byType(MealIngredientsList), findsOneWidget);

    await cubit.close();
  });
}
