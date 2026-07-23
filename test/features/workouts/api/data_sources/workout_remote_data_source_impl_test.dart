import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/api/api_client/workout_api_client.dart';
import 'package:super_fitness/features/workouts/api/data_sources/workout_remote_data_source_impl.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_level_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_levels_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercise_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercises_by_muscle_difficulty_response.dart';

import 'workout_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([WorkoutApiClient])
void main() {
  late WorkoutRemoteDataSourceImpl dataSource;
  late MockWorkoutApiClient mockApiClient;

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
    mockApiClient = MockWorkoutApiClient();
    dataSource = WorkoutRemoteDataSourceImpl(mockApiClient);
  });

  group('getDifficultyLevelsByPrimeMover', () {
    test('returns SuccessBaseResponse when API call succeeds', () async {
      when(
        mockApiClient.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).thenAnswer((_) async => tDifficultyLevelsResponse);

      final result = await dataSource.getDifficultyLevelsByPrimeMover(
        tMuscleId,
      );

      expect(result, isA<SuccessBaseResponse<DifficultyLevelsResponse>>());
      final data =
          (result as SuccessBaseResponse<DifficultyLevelsResponse>).data;
      expect(data, tDifficultyLevelsResponse);
      verify(
        mockApiClient.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).called(1);
    });

    test('returns ErrorBaseResponse when API call throws exception', () async {
      when(
        mockApiClient.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getDifficultyLevelsByPrimeMover(
        tMuscleId,
      );

      expect(result, isA<ErrorBaseResponse<DifficultyLevelsResponse>>());
      verify(
        mockApiClient.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).called(1);
    });
  });

  group('getExercisesByMuscleDifficulty', () {
    test('returns SuccessBaseResponse when API call succeeds', () async {
      when(
        mockApiClient.getExercisesByMuscleDifficulty(tMuscleId, tDifficultyId),
      ).thenAnswer((_) async => tExercisesResponse);

      final result = await dataSource.getExercisesByMuscleDifficulty(
        tMuscleId,
        tDifficultyId,
      );

      expect(
        result,
        isA<SuccessBaseResponse<ExercisesByMuscleDifficultyResponse>>(),
      );
      final data =
          (result as SuccessBaseResponse<ExercisesByMuscleDifficultyResponse>)
              .data;
      expect(data, tExercisesResponse);
      verify(
        mockApiClient.getExercisesByMuscleDifficulty(tMuscleId, tDifficultyId),
      ).called(1);
    });

    test('returns ErrorBaseResponse when API call throws exception', () async {
      when(
        mockApiClient.getExercisesByMuscleDifficulty(tMuscleId, tDifficultyId),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getExercisesByMuscleDifficulty(
        tMuscleId,
        tDifficultyId,
      );

      expect(
        result,
        isA<ErrorBaseResponse<ExercisesByMuscleDifficultyResponse>>(),
      );
      verify(
        mockApiClient.getExercisesByMuscleDifficulty(tMuscleId, tDifficultyId),
      ).called(1);
    });
  });
}
