import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meal_details_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_state.dart';

import 'meal_details_cubit_test.mocks.dart';

@GenerateMocks([GetMealDetailsUseCase])
void main() {
  late MockGetMealDetailsUseCase useCase;

  const details = MealDetailsEntity(
    id: '52959',
    name: 'Baked salmon',
    thumbnail: '',
    category: 'Seafood',
    instructions: 'Heat oven to 180C.',
    ingredients: [MealIngredientEntity(name: 'Salmon', measure: '350g')],
  );

  setUp(() {
    provideDummy<BaseResponse<MealDetailsEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    useCase = MockGetMealDetailsUseCase();
  });

  group('MealDetailsCubit', () {
    blocTest<MealDetailsCubit, MealDetailsState>(
      'emits loading then success on LoadMealDetailsEvent',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        return MealDetailsCubit(useCase)..setMealId('52959');
      },
      act: (cubit) => cubit.doIntent(const LoadMealDetailsEvent()),
      expect: () => [
        const MealDetailsState(status: MealDetailsStatus.loading),
        const MealDetailsState(
          status: MealDetailsStatus.success,
          details: details,
        ),
      ],
    );

    blocTest<MealDetailsCubit, MealDetailsState>(
      'fetches the meal id the route was opened with',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(details));
        return MealDetailsCubit(useCase)..setMealId('52959');
      },
      act: (cubit) => cubit.doIntent(const LoadMealDetailsEvent()),
      verify: (_) => verify(useCase('52959')).called(1),
    );

    blocTest<MealDetailsCubit, MealDetailsState>(
      'emits error with the failure message',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const ErrorBaseResponse('offline'));
        return MealDetailsCubit(useCase)..setMealId('52959');
      },
      act: (cubit) => cubit.doIntent(const LoadMealDetailsEvent()),
      expect: () => [
        const MealDetailsState(status: MealDetailsStatus.loading),
        const MealDetailsState(
          status: MealDetailsStatus.error,
          errorMessage: 'offline',
        ),
      ],
    );

    // Guards the `state.details!` the screen does on success — without this
    // downgrade a null payload would render as a success with nothing in it.
    blocTest<MealDetailsCubit, MealDetailsState>(
      'downgrades a success with no payload to an error',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const SuccessBaseResponse(null));
        return MealDetailsCubit(useCase)..setMealId('52959');
      },
      act: (cubit) => cubit.doIntent(const LoadMealDetailsEvent()),
      expect: () => [
        const MealDetailsState(status: MealDetailsStatus.loading),
        const MealDetailsState(status: MealDetailsStatus.error),
      ],
    );

    blocTest<MealDetailsCubit, MealDetailsState>(
      'refetches when the retry button fires the event again',
      build: () {
        when(useCase(any))
            .thenAnswer((_) async => const ErrorBaseResponse('offline'));
        return MealDetailsCubit(useCase)..setMealId('52959');
      },
      act: (cubit) async {
        cubit.doIntent(const LoadMealDetailsEvent());
        await Future.delayed(Duration.zero);
        cubit.doIntent(const LoadMealDetailsEvent());
        await Future.delayed(Duration.zero);
      },
      verify: (_) => verify(useCase('52959')).called(2),
    );
  });
}
