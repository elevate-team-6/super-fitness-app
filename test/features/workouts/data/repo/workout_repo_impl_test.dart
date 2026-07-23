import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/data/data_sources/workout_remote_data_source_contract.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_group_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_groups_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscles_response.dart';
import 'package:super_fitness/features/workouts/data/repo/workout_repo_impl.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';

import 'workout_repo_impl_test.mocks.dart';

@GenerateMocks([WorkoutRemoteDataSource])
void main() {
  late MockWorkoutRemoteDataSource mockRemoteDataSource;
  late WorkoutRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockWorkoutRemoteDataSource();
    repo = WorkoutRepoImpl(mockRemoteDataSource);

    provideDummy<BaseResponse<List<MuscleGroupEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<List<MuscleEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<MuscleGroupsResponse>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<MusclesResponse>>(
      const ErrorBaseResponse('dummy'),
    );
  });

  group('getMuscleGroups', () {
    const tMuscleGroupModel = MuscleGroupModel(id: '1', name: 'Abs');
    const tMuscleGroupsResponse = MuscleGroupsResponse(
      message: 'success',
      musclesGroup: [tMuscleGroupModel],
    );
    const tMuscleGroupEntity = MuscleGroupEntity(id: '1', name: 'Abs');

    test('should return SuccessBaseResponse with List<MuscleGroupEntity> when remote data source returns SuccessBaseResponse', () async {
      // arrange
      when(mockRemoteDataSource.getMuscleGroups()).thenAnswer(
        (_) async => const SuccessBaseResponse(tMuscleGroupsResponse),
      );

      // act
      final result = await repo.getMuscleGroups();

      // assert
      expect(result, isA<SuccessBaseResponse<List<MuscleGroupEntity>>>());
      expect((result as SuccessBaseResponse).data, equals([tMuscleGroupEntity]));
      verify(mockRemoteDataSource.getMuscleGroups()).called(1);
    });

    test('should return ErrorBaseResponse when remote data source returns ErrorBaseResponse', () async {
      // arrange
      const tErrorMessage = 'Something went wrong';
      when(mockRemoteDataSource.getMuscleGroups()).thenAnswer(
        (_) async => const ErrorBaseResponse(tErrorMessage),
      );

      // act
      final result = await repo.getMuscleGroups();

      // assert
      expect(result, isA<ErrorBaseResponse<List<MuscleGroupEntity>>>());
      expect((result as ErrorBaseResponse).errorMessage, equals(tErrorMessage));
      verify(mockRemoteDataSource.getMuscleGroups()).called(1);
    });
  });

  group('getMusclesByGroupId', () {
    const tGroupId = '1';
    const tMuscleModel = MuscleModel(id: 'm1', name: 'Biceps', image: 'image.png');
    const tMusclesResponse = MusclesResponse(
      message: 'success',
      muscles: [tMuscleModel],
    );
    const tMuscleEntity = MuscleEntity(id: 'm1', name: 'Biceps', image: 'image.png');

    test('should return SuccessBaseResponse with List<MuscleEntity> when remote data source returns SuccessBaseResponse', () async {
      // arrange
      when(mockRemoteDataSource.getMusclesByGroupId(tGroupId)).thenAnswer(
        (_) async => const SuccessBaseResponse(tMusclesResponse),
      );

      // act
      final result = await repo.getMusclesByGroupId(tGroupId);

      // assert
      expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
      expect((result as SuccessBaseResponse).data, equals([tMuscleEntity]));
      verify(mockRemoteDataSource.getMusclesByGroupId(tGroupId)).called(1);
    });

    test('should return ErrorBaseResponse when remote data source returns ErrorBaseResponse', () async {
      // arrange
      const tErrorMessage = 'Something went wrong';
      when(mockRemoteDataSource.getMusclesByGroupId(tGroupId)).thenAnswer(
        (_) async => const ErrorBaseResponse(tErrorMessage),
      );

      // act
      final result = await repo.getMusclesByGroupId(tGroupId);

      // assert
      expect(result, isA<ErrorBaseResponse<List<MuscleEntity>>>());
      expect((result as ErrorBaseResponse).errorMessage, equals(tErrorMessage));
      verify(mockRemoteDataSource.getMusclesByGroupId(tGroupId)).called(1);
    });
  });
}
