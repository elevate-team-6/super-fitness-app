import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_nutrition_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meal_nutrition_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_state.dart';

import 'details_food_cubit_test.mocks.dart';

@GenerateMocks([GetDetailsFoodUseCase, GetMealNutritionUseCase])
void main() {
  late MockGetDetailsFoodUseCase useCase;
  late MockGetMealNutritionUseCase nutritionUseCase;

  const details = DetailsFoodEntity(
    id: '52959',
    name: 'Baked salmon',
    thumbnail: '',
    category: 'Seafood',
    instructions: 'Heat oven to 180C.',
    ingredients: [MealIngredientEntity(name: 'Salmon', measure: '350g')],
  );

  const nutrition = MealNutritionEntity(
    calories: 1250,
    protein: 88,
    carbs: 42,
    fat: 71,
  );

  setUp(() {
    provideDummy<BaseResponse<DetailsFoodEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<MealNutritionEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetDetailsFoodUseCase();
    nutritionUseCase = MockGetMealNutritionUseCase();
  });

  /// Every load chains into the nutrition request, so the tests that don't care
  /// about macros still have to stub it.
  void stubNutrition([BaseResponse<MealNutritionEntity>? response]) {
    when(nutritionUseCase(any)).thenAnswer(
      (_) async => response ?? const SuccessBaseResponse(nutrition),
    );
  }

  DetailsFoodCubit buildCubit() =>
      DetailsFoodCubit(useCase, nutritionUseCase)..setMealId('52959');

  group('DetailsFoodCubit', () {
    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits loading then success on LoadDetailsFoodEvent',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        stubNutrition();
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      // The trailing pair is the macros request the details success kicks off.
      expect: () => [
        const DetailsFoodState(status: DetailsFoodStatus.loading),
        const DetailsFoodState(
          status: DetailsFoodStatus.success,
          details: details,
        ),
        const DetailsFoodState(
          status: DetailsFoodStatus.success,
          details: details,
          nutritionStatus: DetailsFoodStatus.loading,
        ),
        const DetailsFoodState(
          status: DetailsFoodStatus.success,
          details: details,
          nutritionStatus: DetailsFoodStatus.success,
          nutrition: nutrition,
        ),
      ],
    );

    // The recipe has to stay on screen when only the estimate fails — the
    // screen drops the nutrition bar rather than showing an error.
    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'keeps the details on a nutrition failure',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        stubNutrition(const ErrorBaseResponse('quota exceeded'));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      skip: 2,
      expect: () => [
        const DetailsFoodState(
          status: DetailsFoodStatus.success,
          details: details,
          nutritionStatus: DetailsFoodStatus.loading,
        ),
        const DetailsFoodState(
          status: DetailsFoodStatus.success,
          details: details,
          nutritionStatus: DetailsFoodStatus.error,
        ),
      ],
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'estimates the macros from the loaded recipe',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        stubNutrition();
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      verify: (_) => verify(nutritionUseCase(details)).called(1),
    );

    // Nothing to estimate from, and the screen is showing the retry view.
    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'skips the macros when the recipe fails to load',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const ErrorBaseResponse('offline'));
        stubNutrition();
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      verify: (_) => verifyNever(nutritionUseCase(any)),
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'fetches the meal id the route was opened with',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        stubNutrition();
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      verify: (_) => verify(useCase('52959')).called(1),
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits error with the failure message',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const ErrorBaseResponse('offline'));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      expect: () => [
        const DetailsFoodState(status: DetailsFoodStatus.loading),
        const DetailsFoodState(
          status: DetailsFoodStatus.error,
          errorMessage: 'offline',
        ),
      ],
    );

    // Guards the `state.details!` the screen does on success — without this
    // downgrade a null payload would render as a success with nothing in it.
    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'downgrades a success with no payload to an error',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(null));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      expect: () => [
        const DetailsFoodState(status: DetailsFoodStatus.loading),
        const DetailsFoodState(status: DetailsFoodStatus.error),
      ],
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'refetches when the retry button fires the event again',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const ErrorBaseResponse('offline'));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.doIntent(const LoadDetailsFoodEvent());
        await Future.delayed(Duration.zero);
        cubit.doIntent(const LoadDetailsFoodEvent());
        await Future.delayed(Duration.zero);
      },
      verify: (_) => verify(useCase('52959')).called(2),
    );
  });
}
