import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/api/api_client/workout_api_client.dart';
import 'package:super_fitness/features/workouts/api/data_sources/workout_remote_data_source_impl.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_group_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_groups_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscles_response.dart';

import 'workout_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([WorkoutApiClient])
void main() {
  late WorkoutRemoteDataSourceImpl dataSource;
  late MockWorkoutApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockWorkoutApiClient();
    dataSource = WorkoutRemoteDataSourceImpl(mockApiClient);

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

    test('should return SuccessBaseResponse when API call is successful', () async {
      // arrange
      when(mockApiClient.getMuscleGroups()).thenAnswer((_) async => tMuscleGroupsResponse);

      // act
      final result = await dataSource.getMuscleGroups();

      // assert
      expect(result, isA<SuccessBaseResponse<MuscleGroupsResponse>>());
      expect((result as SuccessBaseResponse).data, equals(tMuscleGroupsResponse));
      verify(mockApiClient.getMuscleGroups()).called(1);
    });

    test('should return ErrorBaseResponse when API call fails with DioException', () async {
      // arrange
      when(mockApiClient.getMuscleGroups()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // act
      final result = await dataSource.getMuscleGroups();

      // assert
      expect(result, isA<ErrorBaseResponse<MuscleGroupsResponse>>());
      verify(mockApiClient.getMuscleGroups()).called(1);
    });

    test('should return ErrorBaseResponse when API call throws Exception', () async {
      // arrange
      when(mockApiClient.getMuscleGroups()).thenThrow(Exception());

      // act
      final result = await dataSource.getMuscleGroups();

      // assert
      expect(result, isA<ErrorBaseResponse<MuscleGroupsResponse>>());
      verify(mockApiClient.getMuscleGroups()).called(1);
    });
  });

  group('getMusclesByGroupId', () {
    const tGroupId = '1';
    const tMuscleModel = MuscleModel(id: 'm1', name: 'Biceps', image: 'image.png');
    const tMusclesResponse = MusclesResponse(
      message: 'success',
      muscles: [tMuscleModel],
    );

    test('should return SuccessBaseResponse when API call is successful', () async {
      // arrange
      when(mockApiClient.getMusclesByGroupId(any)).thenAnswer((_) async => tMusclesResponse);

      // act
      final result = await dataSource.getMusclesByGroupId(tGroupId);

      // assert
      expect(result, isA<SuccessBaseResponse<MusclesResponse>>());
      expect((result as SuccessBaseResponse).data, equals(tMusclesResponse));
      verify(mockApiClient.getMusclesByGroupId(tGroupId)).called(1);
    });

    test('should return ErrorBaseResponse when API call fails', () async {
      // arrange
      when(mockApiClient.getMusclesByGroupId(any)).thenThrow(Exception());

      // act
      final result = await dataSource.getMusclesByGroupId(tGroupId);

      // assert
      expect(result, isA<ErrorBaseResponse<MusclesResponse>>());
      verify(mockApiClient.getMusclesByGroupId(tGroupId)).called(1);
    });
  });
}
