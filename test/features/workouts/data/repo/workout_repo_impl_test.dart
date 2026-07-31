import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/data/local/sqlite/catalog_local_data_source.dart';
import 'package:super_fitness/features/home/data/models/response/level_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercise_model.dart';
import 'package:super_fitness/features/workouts/data/repo/workout_repo_impl.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';

import 'workout_repo_impl_test.mocks.dart';

@GenerateMocks([CatalogLocalDataSource])
void main() {
  late WorkoutRepoImpl repository;
  late MockCatalogLocalDataSource mockLocalDataSource;

  const tMuscleId = '69d982ef85f6bfa972bf2248';
  const tDifficultyId = '69d982f085f6bfa972bf225c';

  setUp(() {
    mockLocalDataSource = MockCatalogLocalDataSource();
    repository = WorkoutRepoImpl(mockLocalDataSource);
  });

  group('getMuscleGroups', () {
    const tMuscleModels = [MuscleModel(id: '1', name: 'Abs')];
    const tMuscleGroupEntity = MuscleGroupEntity(id: '1', name: 'Abs');

    test(
      'should return SuccessBaseResponse with List<MuscleGroupEntity> when local data source returns data',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMuscleGroups(),
        ).thenAnswer((_) async => tMuscleModels);

        // act
        final result = await repository.getMuscleGroups();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleGroupEntity>>>());
        expect(
          (result as SuccessBaseResponse<List<MuscleGroupEntity>>).data,
          equals([tMuscleGroupEntity]),
        );
        verify(mockLocalDataSource.getMuscleGroups()).called(1);
      },
    );

    test(
      'should return ErrorBaseResponse when local data source throws error',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMuscleGroups(),
        ).thenThrow(Exception('database error'));

        // act
        final result = await repository.getMuscleGroups();

        // assert
        expect(result, isA<ErrorBaseResponse<List<MuscleGroupEntity>>>());
      },
    );
  });

  group('getMusclesByGroupId', () {
    const tGroupId = '1';
    const tMuscleModels = [
      MuscleModel(id: 'm1', name: 'Biceps', image: 'image.png'),
    ];
    const tMuscleEntity = MuscleEntity(
      id: 'm1',
      name: 'Biceps',
      image: 'image.png',
    );

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when local data source returns data',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMusclesByGroupId(tGroupId),
        ).thenAnswer((_) async => tMuscleModels);

        // act
        final result = await repository.getMusclesByGroupId(tGroupId);

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        expect(
          (result as SuccessBaseResponse<List<MuscleEntity>>).data,
          equals([tMuscleEntity]),
        );
        verify(mockLocalDataSource.getMusclesByGroupId(tGroupId)).called(1);
      },
    );
  });

  group('getDifficultyLevelsByPrimeMover', () {
    final tLevelModels = [
      const LevelModel(id: '1', name: 'Beginner'),
      const LevelModel(id: '2', name: 'Intermediate'),
    ];

    test(
      'returns SuccessBaseResponse with List<DifficultyLevelEntity> when data source succeeds',
      () async {
        // arrange
        when(
          mockLocalDataSource.getDifficultyLevelsByPrimeMover(tMuscleId),
        ).thenAnswer((_) async => tLevelModels);

        // act
        final result = await repository.getDifficultyLevelsByPrimeMover(
          tMuscleId,
        );

        // assert
        expect(result, isA<SuccessBaseResponse<List<DifficultyLevelEntity>>>());
        final data =
            (result as SuccessBaseResponse<List<DifficultyLevelEntity>>).data;
        expect(data?.length, 2);
        expect(data?[0].name, 'Beginner');
        expect(data?[1].name, 'Intermediate');
        verify(
          mockLocalDataSource.getDifficultyLevelsByPrimeMover(tMuscleId),
        ).called(1);
      },
    );
  });

  group('getExercisesByMuscleDifficulty', () {
    final tExerciseModels = [
      const ExerciseModel(
        id: 'ex1',
        exercise: 'Bench Press',
        difficultyLevel: 'Beginner',
      ),
    ];

    test(
      'returns SuccessBaseResponse with List<ExerciseEntity> when data source succeeds',
      () async {
        // arrange
        when(
          mockLocalDataSource.getExercisesByMuscleDifficulty(
            tMuscleId,
            tDifficultyId,
          ),
        ).thenAnswer((_) async => tExerciseModels);

        // act
        final result = await repository.getExercisesByMuscleDifficulty(
          tMuscleId,
          tDifficultyId,
        );

        // assert
        expect(result, isA<SuccessBaseResponse<List<ExerciseEntity>>>());
        final data = (result as SuccessBaseResponse<List<ExerciseEntity>>).data;
        expect(data?.length, 1);
        expect(data?.first.exercise, 'Bench Press');
        verify(
          mockLocalDataSource.getExercisesByMuscleDifficulty(
            tMuscleId,
            tDifficultyId,
          ),
        ).called(1);
      },
    );
  });
}
