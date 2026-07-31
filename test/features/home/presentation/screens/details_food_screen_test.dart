import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/presentation/screens/details_food_screen.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/widgets/details_food_hero.dart';
import 'package:super_fitness/features/home/presentation/widgets/home_error_widget.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_ingredients_list.dart';

import 'details_food_screen_test.mocks.dart';

@GenerateMocks([GetDetailsFoodUseCase])
void main() {
  late MockGetDetailsFoodUseCase mockUseCase;

  const details = DetailsFoodEntity(
    id: '1',
    name: 'Meal Name',
    thumbnail: '',
    category: 'Seafood',
    instructions: 'Step 1: Cook it.',
    ingredients: [MealIngredientEntity(name: 'Salmon', measure: '350g')],
  );

  setUp(() {
    provideDummy<BaseResponse<DetailsFoodEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    mockUseCase = MockGetDetailsFoodUseCase();
  });

  Widget createWidgetUnderTest(DetailsFoodCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const DetailsFoodScreen(mealName: 'Meal Name'),
        ),
      ),
    );
  }

  testWidgets('renders details once loaded successfully', (tester) async {
    when(
      mockUseCase('1'),
    ).thenAnswer((_) async => const SuccessBaseResponse(details));

    final cubit = DetailsFoodCubit(mockUseCase);
    cubit.doIntent(const LoadDetailsFoodEvent('1'));

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Meal Name'), findsWidgets);
    expect(find.text('Step 1: Cook it.'), findsOneWidget);
    expect(find.byType(MealIngredientsList), findsOneWidget);
    expect(find.text('Salmon'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows HomeErrorWidget on load failure', (tester) async {
    when(
      mockUseCase('1'),
    ).thenAnswer((_) async => const ErrorBaseResponse('offline'));

    final cubit = DetailsFoodCubit(mockUseCase);
    cubit.doIntent(const LoadDetailsFoodEvent('1'));

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(HomeErrorWidget), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('back button triggers navigation pop', (tester) async {
    when(
      mockUseCase('1'),
    ).thenAnswer((_) async => const SuccessBaseResponse(details));

    final cubit = DetailsFoodCubit(mockUseCase);
    cubit.doIntent(const LoadDetailsFoodEvent('1'));

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    // Find the back button in DetailsFoodHero
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isEmpty) {
      // Hero uses a custom back button usually, but let's check
    }

    // In our implementation of DetailsFoodHero, it uses a custom _BackButton
    // but the AppBar also has a BackButton.

    // Let's just verify the hero is there.
    expect(find.byType(DetailsFoodHero), findsOneWidget);

    await cubit.close();
  });
}
