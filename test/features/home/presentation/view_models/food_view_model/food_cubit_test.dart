import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_category_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_categories_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_state.dart';

import 'food_cubit_test.mocks.dart';

@GenerateMocks([GetMealsCategoriesUseCase, GetMealsByCategoryUseCase])
void main() {
  late MockGetMealsCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetMealsByCategoryUseCase mockGetByCategoryUseCase;

  const categories = [
    MealCategoryEntity(id: '1', name: 'Beef', image: ''),
    MealCategoryEntity(id: '2', name: 'Chicken', image: ''),
  ];

  const meals = [MealEntity(id: '1', name: 'Meal', thumbnail: '')];

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

  group('FoodCubit', () {
    blocTest<FoodCubit, FoodState>(
      'emits loading then success for categories and triggers first category meals',
      build: () {
        when(
          mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(categories));
        when(
          mockGetByCategoryUseCase('Beef'),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
      },
      act: (cubit) => cubit.doIntent(const GetMealsCategoriesEvent()),
      expect: () => [
        const FoodState(
          categoriesState: BaseState(isLoading: true),
          mealsState: BaseState(isLoading: true),
        ),
        const FoodState(
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Beef',
          mealsState: BaseState(isLoading: true),
        ),
        const FoodState(
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Beef',
          mealsState: BaseState(data: meals),
        ),
      ],
    );

    blocTest<FoodCubit, FoodState>(
      'respects initialCategory when provided in GetMealsCategoriesEvent',
      build: () {
        when(
          mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(categories));
        when(
          mockGetByCategoryUseCase('Chicken'),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
      },
      act: (cubit) => cubit.doIntent(
        const GetMealsCategoriesEvent(initialCategory: 'Chicken'),
      ),
      expect: () => [
        const FoodState(
          initialCategory: 'Chicken',
          categoriesState: BaseState(isLoading: true),
          mealsState: BaseState(isLoading: true),
        ),
        const FoodState(
          initialCategory: 'Chicken',
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Chicken',
          mealsState: BaseState(isLoading: true),
        ),
        const FoodState(
          initialCategory: 'Chicken',
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Chicken',
          mealsState: BaseState(data: meals),
        ),
      ],
    );

    blocTest<FoodCubit, FoodState>(
      'unified error reporting when categories fetch fails',
      build: () {
        when(
          mockGetCategoriesUseCase(),
        ).thenAnswer((_) async => const ErrorBaseResponse('network error'));
        return FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
      },
      act: (cubit) => cubit.doIntent(const GetMealsCategoriesEvent()),
      expect: () => [
        const FoodState(
          categoriesState: BaseState(isLoading: true),
          mealsState: BaseState(isLoading: true),
        ),
        const FoodState(
          categoriesState: BaseState(errorMessage: 'network error'),
          mealsState: BaseState(errorMessage: 'network error'),
        ),
      ],
    );

    blocTest<FoodCubit, FoodState>(
      'change category emits new selected category and fetches meals',
      build: () {
        when(
          mockGetByCategoryUseCase('Chicken'),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
      },
      seed: () => const FoodState(
        categoriesState: BaseState(data: categories),
        selectedCategory: 'Beef',
      ),
      act: (cubit) => cubit.doIntent(const ChangeCategoryEvent('Chicken')),
      expect: () => [
        const FoodState(
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Chicken',
        ),
        const FoodState(
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Chicken',
          mealsState: BaseState(isLoading: true),
        ),
        const FoodState(
          categoriesState: BaseState(data: categories),
          selectedCategory: 'Chicken',
          mealsState: BaseState(data: meals),
        ),
      ],
    );

    group('Retries', () {
      blocTest<FoodCubit, FoodState>(
        'retries full fetch if categories had failed',
        build: () {
          when(
            mockGetCategoriesUseCase(),
          ).thenAnswer((_) async => const SuccessBaseResponse(categories));
          when(
            mockGetByCategoryUseCase('Beef'),
          ).thenAnswer((_) async => const SuccessBaseResponse(meals));
          return FoodCubit(mockGetCategoriesUseCase, mockGetByCategoryUseCase);
        },
        seed: () => const FoodState(
          categoriesState: BaseState(errorMessage: 'fail'),
          mealsState: BaseState(errorMessage: 'fail'),
        ),
        act: (cubit) => cubit.doIntent(const GetMealsCategoriesEvent()),
        verify: (_) {
          verify(mockGetCategoriesUseCase()).called(1);
          verify(mockGetByCategoryUseCase('Beef')).called(1);
        },
      );
    });
  });
}
