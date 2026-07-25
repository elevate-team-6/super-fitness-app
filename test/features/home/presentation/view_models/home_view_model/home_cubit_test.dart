import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/home/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/home/domain/entities/home_user_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_cached_user_data_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_categories_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_popular_training_exercises_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_random_muscles_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/home_view_model/home_state.dart';

import 'home_cubit_test.mocks.dart';

@GenerateMocks([
  GetRandomMusclesUseCase,
  GetMuscleGroupsUseCase,
  GetMusclesByGroupIdUseCase,
  GetMealsCategoriesUseCase,
  GetPopularTrainingExercisesUseCase,
  GetCachedUserDataUseCase,
])
void main() {
  provideDummy<BaseResponse<HomeUserEntity>>(
    const SuccessBaseResponse(HomeUserEntity.empty),
  );
  provideDummy<BaseResponse<List<MuscleEntity>>>(const SuccessBaseResponse([]));
  provideDummy<BaseResponse<List<ExerciseEntity>>>(
    const SuccessBaseResponse([]),
  );
  provideDummy<BaseResponse<List<MealCategoryEntity>>>(
    const SuccessBaseResponse([]),
  );

  late HomeCubit cubit;
  late MockGetRandomMusclesUseCase mockGetRandomMuscles;
  late MockGetMuscleGroupsUseCase mockGetMuscleGroups;
  late MockGetMusclesByGroupIdUseCase mockGetMusclesByGroupId;
  late MockGetMealsCategoriesUseCase mockGetMealsCategories;
  late MockGetPopularTrainingExercisesUseCase mockGetPopularExercises;
  late MockGetCachedUserDataUseCase mockGetCachedUserData;

  setUp(() {
    mockGetRandomMuscles = MockGetRandomMusclesUseCase();
    mockGetMuscleGroups = MockGetMuscleGroupsUseCase();
    mockGetMusclesByGroupId = MockGetMusclesByGroupIdUseCase();
    mockGetMealsCategories = MockGetMealsCategoriesUseCase();
    mockGetPopularExercises = MockGetPopularTrainingExercisesUseCase();
    mockGetCachedUserData = MockGetCachedUserDataUseCase();

    cubit = HomeCubit(
      mockGetRandomMuscles,
      mockGetMuscleGroups,
      mockGetMusclesByGroupId,
      mockGetMealsCategories,
      mockGetPopularExercises,
      mockGetCachedUserData,
    );
  });

  group('FetchHomeUserEvent', () {
    const tUser = HomeUserEntity(name: 'Test', image: '');
    blocTest<HomeCubit, HomeState>(
      'emits [loading, success] when data is fetched successfully',
      build: () {
        when(
          mockGetCachedUserData(),
        ).thenAnswer((_) async => const SuccessBaseResponse(tUser));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(FetchHomeUserEvent()),
      expect: () => [
        const HomeState(homeUserStatus: BaseState(isLoading: true)),
        const HomeState(homeUserStatus: BaseState(data: tUser)),
      ],
    );
  });

  group('FetchRandomExercisesEvent (Random Muscles)', () {
    const tErrorMessage = 'Connection Error';
    blocTest<HomeCubit, HomeState>(
      'emits [loading, error] and UI error event when fetch fails',
      build: () {
        when(
          mockGetRandomMuscles(),
        ).thenAnswer((_) async => const ErrorBaseResponse(tErrorMessage));
        return cubit;
      },
      act: (cubit) {
        cubit.eventStream.listen(
          expectAsync1((event) {
            expect(event, isA<DisplayErrorEvent>());
            expect((event as DisplayErrorEvent).errorMessage, tErrorMessage);
          }),
        );
        cubit.doEvent(const FetchRandomExercisesEvent());
      },
      expect: () => [
        const HomeState(recommendationTodayStatus: BaseState(isLoading: true)),
        const HomeState(
          recommendationTodayStatus: BaseState(errorMessage: tErrorMessage),
        ),
      ],
    );
  });

  group('FetchAllHomeDataEvent', () {
    const tMuscles = [MuscleEntity(id: '1', name: 'Abs')];

    blocTest<HomeCubit, HomeState>(
      'triggers all sub-fetch methods',
      build: () {
        when(mockGetCachedUserData()).thenAnswer(
          (_) async => const SuccessBaseResponse(HomeUserEntity.empty),
        );
        when(
          mockGetRandomMuscles(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        when(
          mockGetMuscleGroups(),
        ).thenAnswer((_) async => const SuccessBaseResponse(tMuscles));
        when(
          mockGetMusclesByGroupId(any),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        when(
          mockGetMealsCategories(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        when(
          mockGetPopularExercises(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(const FetchAllHomeDataEvent()),
      verify: (_) {
        verify(mockGetCachedUserData()).called(1);
        verify(mockGetRandomMuscles()).called(1);
        verify(mockGetMuscleGroups()).called(1);
        verify(mockGetMusclesByGroupId(any)).called(1);
        verify(mockGetMealsCategories()).called(1);
        verify(mockGetPopularExercises()).called(1);
      },
    );
  });
}
