import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/workouts/api/api_client/workout_api_client.dart';
import 'package:super_fitness/features/workouts/data/data_sources/workout_remote_data_source_contract.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_groups_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscles_response.dart';

@Injectable(as: WorkoutRemoteDataSource)
class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final WorkoutApiClient _apiClient;

  const WorkoutRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<MuscleGroupsResponse>> getMuscleGroups() {
    return ErrorHandler.handleApiCall(() => _apiClient.getMuscleGroups());
  }

  @override
  Future<BaseResponse<MusclesResponse>> getMusclesByGroupId(String id) {
    return ErrorHandler.handleApiCall(() => _apiClient.getMusclesByGroupId(id));
  }
}
