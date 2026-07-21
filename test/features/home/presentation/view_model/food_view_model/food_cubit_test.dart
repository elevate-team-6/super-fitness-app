import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_meal_time_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_state.dart';

import 'food_cubit_test.mocks.dart';

@GenerateMocks([GetMealsByMealTimeUseCase])
void main() {
  late MockGetMealsByMealTimeUseCase useCase;

  const meals = [MealEntity(id: '1', name: 'Meal', thumbnail: '')];

  setUp(() {
    provideDummy<BaseResponse<List<MealEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetMealsByMealTimeUseCase();
  });

  group('FoodCubit', () {
    blocTest<FoodCubit, FoodState>(
      'emits loading then success on LoadMealsEvent',
      build: () {
        when(
          useCase(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(useCase);
      },
      act: (cubit) => cubit.doIntent(const LoadMealsEvent()),
      expect: () => [
        const FoodState(status: FoodStatus.loading),
        const FoodState(status: FoodStatus.success, meals: meals),
      ],
    );

    blocTest<FoodCubit, FoodState>(
      'emits error with the failure message',
      build: () {
        when(
          useCase(any),
        ).thenAnswer((_) async => const ErrorBaseResponse('boom'));
        return FoodCubit(useCase);
      },
      act: (cubit) => cubit.doIntent(const LoadMealsEvent()),
      expect: () => [
        const FoodState(status: FoodStatus.loading),
        const FoodState(status: FoodStatus.error, errorMessage: 'boom'),
      ],
    );

    blocTest<FoodCubit, FoodState>(
      'loads the meal time the screen opens on, even though it matches the '
      'default selection',
      build: () {
        when(
          useCase(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(useCase);
      },
      act: (cubit) =>
          cubit.doIntent(const SelectMealTimeEvent(MealTime.breakfast)),
      verify: (_) => verify(useCase(MealTime.breakfast)).called(1),
    );

    blocTest<FoodCubit, FoodState>(
      'switches meal time and fetches the new one',
      build: () {
        when(
          useCase(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(useCase);
      },
      act: (cubit) =>
          cubit.doIntent(const SelectMealTimeEvent(MealTime.dinner)),
      expect: () => [
        const FoodState(selectedMealTime: MealTime.dinner),
        const FoodState(
          selectedMealTime: MealTime.dinner,
          status: FoodStatus.loading,
        ),
        const FoodState(
          selectedMealTime: MealTime.dinner,
          status: FoodStatus.success,
          meals: meals,
        ),
      ],
    );

    blocTest<FoodCubit, FoodState>(
      'serves an already-loaded meal time from cache instead of refetching',
      build: () {
        when(
          useCase(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(meals));
        return FoodCubit(useCase);
      },
      act: (cubit) async {
        cubit.doIntent(const LoadMealsEvent());
        await Future.delayed(Duration.zero);
        cubit.doIntent(const SelectMealTimeEvent(MealTime.dinner));
        await Future.delayed(Duration.zero);
        cubit.doIntent(const SelectMealTimeEvent(MealTime.breakfast));
        await Future.delayed(Duration.zero);
      },
      verify: (_) {
        verify(useCase(MealTime.breakfast)).called(1);
        verify(useCase(MealTime.dinner)).called(1);
      },
    );
  });
}
