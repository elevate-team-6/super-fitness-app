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
import 'package:super_fitness/features/workouts/data/models/response/muscle_group_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_groups_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscles_response.dart';

import 'workout_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([WorkoutApiClient])
void main() {
  late WorkoutRemoteDataSourceImpl dataSource;
  late MockWorkoutApiClient mockApiClient;

  const tGroupId = '1';
  const tMuscleId = '69d982ef85f6bfa972bf2248';
  const tDifficultyId = '69d982f085f6bfa972bf225c';

  setUp(() {
    mockApiClient = MockWorkoutApiClient();
    dataSource = WorkoutRemoteDataSourceImpl(mockApiClient);

    provideDummy<BaseResponse<MuscleGroupsResponse>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<MusclesResponse>>(
      const ErrorBaseResponse('dummy'),
    );

    provideDummy<BaseResponse<DifficultyLevelsResponse>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<ExercisesByMuscleDifficultyResponse>>(
      const ErrorBaseResponse('dummy'),
    );
  });

  group('getMuscleGroups', () {
    const tMuscleGroupModel = MuscleGroupModel(id: '1', name: 'Abs');

    const tMuscleGroupsResponse = MuscleGroupsResponse(
      message: 'success',
      musclesGroup: [tMuscleGroupModel],
    );

    test(
      'should return SuccessBaseResponse when API call is successful',
      () async {
        when(
          mockApiClient.getMuscleGroups(),
        ).thenAnswer((_) async => tMuscleGroupsResponse);

        final result = await dataSource.getMuscleGroups();

        expect(result, isA<SuccessBaseResponse<MuscleGroupsResponse>>());
        expect(
          (result as SuccessBaseResponse).data,
          equals(tMuscleGroupsResponse),
        );
        verify(mockApiClient.getMuscleGroups()).called(1);
      },
    );

    test(
      'should return ErrorBaseResponse when API call fails with DioException',
      () async {
        when(mockApiClient.getMuscleGroups()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await dataSource.getMuscleGroups();

        expect(result, isA<ErrorBaseResponse<MuscleGroupsResponse>>());
        verify(mockApiClient.getMuscleGroups()).called(1);
      },
    );

    test(
      'should return ErrorBaseResponse when API call throws Exception',
      () async {
        when(mockApiClient.getMuscleGroups()).thenThrow(Exception());

        final result = await dataSource.getMuscleGroups();

        expect(result, isA<ErrorBaseResponse<MuscleGroupsResponse>>());
        verify(mockApiClient.getMuscleGroups()).called(1);
      },
    );
  });

  group('getMusclesByGroupId', () {
    const tMuscleModel = MuscleModel(
      id: 'm1',
      name: 'Biceps',
      image: 'image.png',
    );

    const tMusclesResponse = MusclesResponse(
      message: 'success',
      muscles: [tMuscleModel],
    );

    test(
      'should return SuccessBaseResponse when API call is successful',
      () async {
        when(
          mockApiClient.getMusclesByGroupId(tGroupId),
        ).thenAnswer((_) async => tMusclesResponse);

        final result = await dataSource.getMusclesByGroupId(tGroupId);

        expect(result, isA<SuccessBaseResponse<MusclesResponse>>());
        expect((result as SuccessBaseResponse).data, equals(tMusclesResponse));

        verify(mockApiClient.getMusclesByGroupId(tGroupId)).called(1);
      },
    );

    test('should return ErrorBaseResponse when API call fails', () async {
      when(mockApiClient.getMusclesByGroupId(tGroupId)).thenThrow(Exception());

      final result = await dataSource.getMusclesByGroupId(tGroupId);

      expect(result, isA<ErrorBaseResponse<MusclesResponse>>());

      verify(mockApiClient.getMusclesByGroupId(tGroupId)).called(1);
    });
  });

  group('getDifficultyLevelsByPrimeMover', () {
    const tDifficultyLevelsResponse = DifficultyLevelsResponse(
      message: 'success',
      totalLevels: 2,
      difficultyLevels: [
        DifficultyLevelModel(id: '1', name: 'Beginner'),
        DifficultyLevelModel(id: '2', name: 'Intermediate'),
      ],
    );

    test('returns SuccessBaseResponse when API call succeeds', () async {
      when(
        mockApiClient.getDifficultyLevelsByPrimeMover(tMuscleId),
      ).thenAnswer((_) async => tDifficultyLevelsResponse);

      final result = await dataSource.getDifficultyLevelsByPrimeMover(
        tMuscleId,
      );

      expect(result, isA<SuccessBaseResponse<DifficultyLevelsResponse>>());

      expect(
        (result as SuccessBaseResponse<DifficultyLevelsResponse>).data,
        tDifficultyLevelsResponse,
      );

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

      expect(
        (result as SuccessBaseResponse<ExercisesByMuscleDifficultyResponse>)
            .data,
        tExercisesResponse,
      );

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
