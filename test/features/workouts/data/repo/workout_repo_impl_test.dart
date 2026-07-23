import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/data/data_sources/workout_remote_data_source_contract.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_level_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_levels_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercise_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercises_by_muscle_difficulty_response.dart';
import 'package:super_fitness/features/workouts/data/repo/workout_repo_impl.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

import 'workout_repo_impl_test.mocks.dart';

@GenerateMocks([WorkoutRemoteDataSourceContract])
void main() {
  late WorkoutRepoImpl repository;
  late MockWorkoutRemoteDataSourceContract mockRemoteDataSource;

  const tMuscleId = '69d982ef85f6bfa972bf2248';
  const tDifficultyId = '69d982f085f6bfa972bf225c';

  const tDifficultyLevelsResponse = DifficultyLevelsResponse(
    message: 'success',
    totalLevels: 2,
    difficultyLevels: [
      DifficultyLevelModel(id: '1', name: 'Beginner'),
      DifficultyLevelModel(id: '2', name: 'Intermediate'),
    ],
  );

  const tExercisesResponse = ExercisesByMuscleDifficultyResponse(
    message: 'success',
    totalExercises: 10,
    totalPages: 1,
    currentPage: 1,
    exercises: [
      ExerciseModel(
        id: 'ex1',
        exercise: 'Bench Press',
        difficultyLevel: 'Beginner',
      ),
    ],
  );

  setUp(() {
    provideDummy<BaseResponse<DifficultyLevelsResponse>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<ExercisesByMuscleDifficultyResponse>>(
      const ErrorBaseResponse('dummy'),
    );

    mockRemoteDataSource = MockWorkoutRemoteDataSourceContract();
    repository = WorkoutRepoImpl(mockRemoteDataSource);
  });

  group('getDifficultyLevelsByPrimeMover', () {
    test(
      'returns SuccessBaseResponse with List<DifficultyLevelEntity> when data source succeeds',
      () async {
        when(
          mockRemoteDataSource.getDifficultyLevelsByPrimeMover(tMuscleId),
        ).thenAnswer(
          (_) async => const SuccessBaseResponse(tDifficultyLevelsResponse),
        );

        final result = await repository.getDifficultyLevelsByPrimeMover(
          tMuscleId,
        );

        expect(result, isA<SuccessBaseResponse<List<DifficultyLevelEntity>>>());
        final data =
            (result as SuccessBaseResponse<List<DifficultyLevelEntity>>).data;
        expect(data?.length, 2);
        expect(data?[0].name, 'Beginner');
        expect(data?[1].name, 'Intermediate');
        verify(
          mockRemoteDataSource.getDifficultyLevelsByPrimeMover(tMuscleId),
        ).called(1);
      },
    );

    test('returns ErrorBaseResponse when data source fails', () async {
      when(
        mockRemoteDataSource.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).thenAnswer((_) async => const ErrorBaseResponse('Server Error'));

      final result = await repository.getDifficultyLevelsByPrimeMover(
        tMuscleId,
      );

      expect(result, isA<ErrorBaseResponse<List<DifficultyLevelEntity>>>());
      final error = result as ErrorBaseResponse<List<DifficultyLevelEntity>>;
      expect(error.errorMessage, 'Server Error');
      verify(
        mockRemoteDataSource.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).called(1);
    });
  });

  group('getExercisesByMuscleDifficulty', () {
    test(
      'returns SuccessBaseResponse with ExercisesEntity when data source succeeds',
      () async {
        when(
          mockRemoteDataSource.getExercisesByMuscleDifficulty(
            tMuscleId,
            tDifficultyId,
          ),
        ).thenAnswer(
          (_) async => const SuccessBaseResponse(tExercisesResponse),
        );

        final result = await repository.getExercisesByMuscleDifficulty(
          tMuscleId,
          tDifficultyId,
        );

        expect(result, isA<SuccessBaseResponse<ExercisesEntity>>());
        final data = (result as SuccessBaseResponse<ExercisesEntity>).data;
        expect(data?.totalExercises, 10);
        expect(data?.exercises.length, 1);
        expect(data?.exercises.first.exercise, 'Bench Press');
        verify(
          mockRemoteDataSource.getExercisesByMuscleDifficulty(
            tMuscleId,
            tDifficultyId,
          ),
        ).called(1);
      },
    );

    test('returns ErrorBaseResponse when data source fails', () async {
      when(
        mockRemoteDataSource.getExercisesByMuscleDifficulty(
          tMuscleId,
          tDifficultyId,
        ),
      ).thenAnswer((_) async => const ErrorBaseResponse('Network Error'));

      final result = await repository.getExercisesByMuscleDifficulty(
        tMuscleId,
        tDifficultyId,
      );

      expect(result, isA<ErrorBaseResponse<ExercisesEntity>>());
      final error = result as ErrorBaseResponse<ExercisesEntity>;
      expect(error.errorMessage, 'Network Error');
      verify(
        mockRemoteDataSource.getExercisesByMuscleDifficulty(
          tMuscleId,
          tDifficultyId,
        ),
      ).called(1);
    });
  });
}
