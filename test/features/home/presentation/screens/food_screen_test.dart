import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_category_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_categories_use_case.dart';
import 'package:super_fitness/features/home/presentation/screens/food_screen.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/widgets/home_error_widget.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_card.dart';

import 'food_screen_test.mocks.dart';

@GenerateMocks([GetMealsCategoriesUseCase, GetMealsByCategoryUseCase])
void main() {
  late MockGetMealsCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetMealsByCategoryUseCase mockGetByCategoryUseCase;

  const categories = [
    MealCategoryEntity(id: '1', name: 'Beef', image: ''),
    MealCategoryEntity(id: '2', name: 'Chicken', image: ''),
  ];

  const meals = [MealEntity(id: '1', name: 'Steak', thumbnail: '')];

  setUp(() {
    provideDummy<BaseResponse<List<MealCategoryEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<List<MealEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    mockGetCategoriesUseCase = MockGetMealsCategoriesUseCase();
    mockGetByCategoryUseCase = MockGetMealsByCategoryUseCase();
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

  testWidgets('renders category tabs and meal cards once loaded', (
    tester,
  ) async {
    when(
      mockGetCategoriesUseCase(),
    ).thenAnswer((_) async => const SuccessBaseResponse(categories));
    when(
      mockGetByCategoryUseCase('Beef'),
    ).thenAnswer((_) async => const SuccessBaseResponse(meals));

    final cubit = FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    // Initial events are fired via router in app but here we can rely on cubit logic
    // Actually the FoodScreen doesn't fire event in initState anymore as per our previous fix.
    // So we manually fire it or rely on the fact that we're testing the widget's reaction to state.

    // In our implementation of FoodScreen, we removed the initState call.
    // So we need to trigger the event manually or pass a cubit that is already loaded.
    cubit.doIntent(const GetMealsCategoriesEvent());

    await tester.pumpAndSettle();

    expect(find.text('Beef'), findsWidgets);
    expect(find.text('Chicken'), findsWidgets);
    expect(find.byType(MealCard), findsOneWidget);
    expect(find.text('Steak'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows HomeErrorWidget on category load failure', (tester) async {
    when(
      mockGetCategoriesUseCase(),
    ).thenAnswer((_) async => const ErrorBaseResponse('network error'));

    final cubit = FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
    cubit.doIntent(const GetMealsCategoriesEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(HomeErrorWidget), findsOneWidget);
    expect(find.text('network error'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('tapping a tab switches category and fetches new meals', (
    tester,
  ) async {
    when(
      mockGetCategoriesUseCase(),
    ).thenAnswer((_) async => const SuccessBaseResponse(categories));
    when(
      mockGetByCategoryUseCase('Beef'),
    ).thenAnswer((_) async => const SuccessBaseResponse(meals));
    when(
      mockGetByCategoryUseCase('Chicken'),
    ).thenAnswer((_) async => const SuccessBaseResponse([]));

    final cubit = FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
    cubit.doIntent(const GetMealsCategoriesEvent());

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pumpAndSettle();

    // Tap Chicken tab
    await tester.tap(find.text('Chicken').last);
    await tester.pumpAndSettle();

    verify(mockGetByCategoryUseCase('Chicken')).called(1);
    expect(find.text(AppStrings.noMealsFound), findsOneWidget);

    await cubit.close();
  });
}
