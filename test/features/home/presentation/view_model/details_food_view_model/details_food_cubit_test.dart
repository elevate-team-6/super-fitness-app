import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_state.dart';

import 'details_food_cubit_test.mocks.dart';

@GenerateMocks([GetDetailsFoodUseCase])
void main() {
  late MockGetDetailsFoodUseCase useCase;

  const details = DetailsFoodEntity(
    id: '52959',
    name: 'Baked salmon',
    thumbnail: '',
    category: 'Seafood',
    instructions: 'Heat oven to 180C.',
    ingredients: [MealIngredientEntity(name: 'Salmon', measure: '350g')],
  );

  setUp(() {
    provideDummy<BaseResponse<DetailsFoodEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetDetailsFoodUseCase();
  });

  group('DetailsFoodCubit', () {
    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits loading then success on LoadDetailsFoodEvent',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        return DetailsFoodCubit(useCase)..setMealId('52959');
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      expect: () => [
        const DetailsFoodState(status: DetailsFoodStatus.loading),
        const DetailsFoodState(
          status: DetailsFoodStatus.success,
          details: details,
        ),
      ],
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'fetches the meal id the route was opened with',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        return DetailsFoodCubit(useCase)..setMealId('52959');
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent()),
      verify: (_) => verify(useCase('52959')).called(1),
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits error with the failure message',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const ErrorBaseResponse('offline'));
        return DetailsFoodCubit(useCase)..setMealId('52959');
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
        return DetailsFoodCubit(useCase)..setMealId('52959');
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
        return DetailsFoodCubit(useCase)..setMealId('52959');
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
