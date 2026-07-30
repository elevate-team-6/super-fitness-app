import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_state.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_cubit.dart';

import 'details_food_cubit_test.mocks.dart';

@GenerateMocks([GetDetailsFoodUseCase])
void main() {
  late MockGetDetailsFoodUseCase mockUseCase;

  const details = DetailsFoodEntity(
    id: '1',
    name: 'Meal',
    thumbnail: '',
    category: 'Beef',
    instructions: 'Cook it',
    ingredients: [MealIngredientEntity(name: 'Ingredient', measure: '1')],
  );

  setUp(() {
    provideDummy<BaseResponse<DetailsFoodEntity>>(
      const ErrorBaseResponse('dummy'),
    );
    mockUseCase = MockGetDetailsFoodUseCase();
  });

  group('DetailsFoodCubit', () {
    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits loading then success with meal details',
      build: () {
        when(
          mockUseCase('1'),
        ).thenAnswer((_) async => const SuccessBaseResponse(details));
        return DetailsFoodCubit(mockUseCase);
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent('1')),
      expect: () => [
        const DetailsFoodState(
          mealId: '1',
          detailsState: BaseState(isLoading: true),
        ),
        const DetailsFoodState(
          mealId: '1',
          detailsState: BaseState(data: details),
        ),
      ],
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits error state with not found message when data is null',
      build: () {
        when(
          mockUseCase('1'),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        return DetailsFoodCubit(mockUseCase);
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent('1')),
      expect: () => [
        const DetailsFoodState(
          mealId: '1',
          detailsState: BaseState(isLoading: true),
        ),
        const DetailsFoodState(
          mealId: '1',
          detailsState: BaseState(errorMessage: AppStrings.detailsFoodNotFound),
        ),
      ],
    );

    blocTest<DetailsFoodCubit, DetailsFoodState>(
      'emits error state when use case returns error',
      build: () {
        when(
          mockUseCase('1'),
        ).thenAnswer((_) async => const ErrorBaseResponse('server error'));
        return DetailsFoodCubit(mockUseCase);
      },
      act: (cubit) => cubit.doIntent(const LoadDetailsFoodEvent('1')),
      expect: () => [
        const DetailsFoodState(
          mealId: '1',
          detailsState: BaseState(isLoading: true),
        ),
        const DetailsFoodState(
          mealId: '1',
          detailsState: BaseState(errorMessage: 'server error'),
        ),
      ],
    );
  });
}
