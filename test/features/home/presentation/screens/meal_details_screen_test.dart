import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meal_details_use_case.dart';
import 'package:super_fitness/features/home/presentation/screens/meal_details_screen.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_event.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_ingredients_list.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_tags_wrap.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_video_preview.dart';

import 'meal_details_screen_test.mocks.dart';

// easy_localization isn't initialized here, so `.tr()` returns the raw key —
// same convention the other widget tests in this repo rely on.
@GenerateMocks([GetMealDetailsUseCase])
void main() {
  late MockGetMealDetailsUseCase useCase;

  const details = MealDetailsEntity(
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
    provideDummy<BaseResponse<MealDetailsEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetMealDetailsUseCase();
  });

  Widget createWidgetUnderTest(MealDetailsCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const MealDetailsScreen(mealName: 'Baked salmon with fennel'),
        ),
      ),
    );
  }

  MealDetailsCubit buildCubit() =>
      MealDetailsCubit(useCase)..setMealId('52959');

  testWidgets('renders the description and ingredients once loaded', (
    tester,
  ) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadMealDetailsEvent());

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

  testWidgets('shows the category and area alongside the recipe tags', (
    tester,
  ) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadMealDetailsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(MealTagsWrap), findsOneWidget);
    expect(find.text('Seafood'), findsOneWidget);
    expect(find.text('British'), findsOneWidget);
    expect(find.text('Paleo'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('offers the video when the recipe has one', (tester) async {
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(details));
    final cubit = buildCubit()..doIntent(const LoadMealDetailsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    final preview = tester.widget<MealVideoPreview>(
      find.byType(MealVideoPreview),
    );
    expect(preview.onPlay, isNotNull);

    await cubit.close();
  });

  // Plenty of TheMealDB recipes have a blank `strYoutube`, so the play button
  // has to disappear rather than open a dead page.
  testWidgets('hides the play button when the recipe has no video', (
    tester,
  ) async {
    const noVideo = MealDetailsEntity(
      id: '1',
      name: 'No video meal',
      thumbnail: '',
      instructions: 'Cook it.',
    );
    when(useCase(any))
        .thenAnswer((_) async => const SuccessBaseResponse(noVideo));
    final cubit = buildCubit()..doIntent(const LoadMealDetailsEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    final preview = tester.widget<MealVideoPreview>(
      find.byType(MealVideoPreview),
    );
    expect(preview.onPlay, isNull);

    await cubit.close();
  });

  testWidgets('shows the retry view on failure and refetches when tapped', (
    tester,
  ) async {
    when(useCase(any))
        .thenAnswer((_) async => const ErrorBaseResponse('offline'));
    final cubit = buildCubit()..doIntent(const LoadMealDetailsEvent());

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
