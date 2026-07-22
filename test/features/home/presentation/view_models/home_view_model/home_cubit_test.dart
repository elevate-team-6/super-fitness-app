import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/home/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/home/domain/entities/home_user_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_all_exercises_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_cached_user_data_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_categories_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_random_exercises_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_state.dart';

import 'home_cubit_test.mocks.dart';

@GenerateMocks([
  GetRandomExercisesUseCase,
  GetMuscleGroupsUseCase,
  GetMealsCategoriesUseCase,
  GetAllExercisesUseCase,
  GetCachedUserDataUseCase,
])
void main() {
  late HomeCubit cubit;
  late MockGetRandomExercisesUseCase mockGetRandomExercises;
  late MockGetMuscleGroupsUseCase mockGetMuscleGroups;
  late MockGetMealsCategoriesUseCase mockGetMealsCategories;
  late MockGetAllExercisesUseCase mockGetAllExercises;
  late MockGetCachedUserDataUseCase mockGetCachedUserData;

  setUp(() {
    mockGetRandomExercises = MockGetRandomExercisesUseCase();
    mockGetMuscleGroups = MockGetMuscleGroupsUseCase();
    mockGetMealsCategories = MockGetMealsCategoriesUseCase();
    mockGetAllExercises = MockGetAllExercisesUseCase();
    mockGetCachedUserData = MockGetCachedUserDataUseCase();

    cubit = HomeCubit(
      mockGetRandomExercises,
      mockGetMuscleGroups,
      mockGetMealsCategories,
      mockGetAllExercises,
      mockGetCachedUserData,
    );
  });

  group('FetchHomeUserEvent', () {
    const tUser = HomeUserEntity(name: 'Test', image: '');
    blocTest<HomeCubit, HomeState>(
      'emits [loading, success] when data is fetched successfully',
      build: () {
        when(mockGetCachedUserData()).thenAnswer((_) async => const SuccessBaseResponse(tUser));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(FetchHomeUserEvent()),
      expect: () => [
        const HomeState(homeUserStatus: BaseState(isLoading: true)),
        const HomeState(homeUserStatus: BaseState(data: tUser)),
      ],
    );
  });

  group('FetchMuscleGroupsEvent', () {
    const tMuscles = [MuscleEntity(id: '1', name: 'Abs')];
    blocTest<HomeCubit, HomeState>(
      'emits [loading, success] and triggers exercise fetch when muscles found',
      build: () {
        when(mockGetMuscleGroups()).thenAnswer((_) async => const SuccessBaseResponse(tMuscles));
        when(mockGetAllExercises(limit: anyNamed('limit'))).thenAnswer((_) async => const SuccessBaseResponse([]));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(FetchMuscleGroupsEvent()),
      expect: () => [
        const HomeState(upcomingWorkoutsTabsStatus: BaseState(isLoading: true)),
        const HomeState(
          upcomingWorkoutsTabsStatus: BaseState(data: tMuscles),
          activeMuscleId: '1',
        ),
        const HomeState(
          upcomingWorkoutsTabsStatus: BaseState(data: tMuscles),
          activeMuscleId: '1',
          upcomingWorkoutsStatus: BaseState(isLoading: true),
        ),
        const HomeState(
          upcomingWorkoutsTabsStatus: BaseState(data: tMuscles),
          activeMuscleId: '1',
          upcomingWorkoutsStatus: BaseState(data: []),
        ),
      ],
    );
  });

  group('ChangeMuscleTabEvent', () {
    blocTest<HomeCubit, HomeState>(
      'emits new activeMuscleId and triggers fetch',
      build: () {
        when(mockGetAllExercises(limit: anyNamed('limit'))).thenAnswer((_) async => const SuccessBaseResponse([]));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(const ChangeMuscleTabEvent('2')),
      expect: () => [
        const HomeState(activeMuscleId: '2'),
        const HomeState(activeMuscleId: '2', upcomingWorkoutsStatus: BaseState(isLoading: true)),
        const HomeState(activeMuscleId: '2', upcomingWorkoutsStatus: BaseState(data: [])),
      ],
    );
  });
}
