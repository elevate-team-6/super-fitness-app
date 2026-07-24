import 'package:super_fitness/config/base_response/base_response.dart';
import '../models/response/muscle_groups_response.dart';
import '../models/response/muscles_response.dart';

abstract class WorkoutRemoteDataSource {
  Future<BaseResponse<MuscleGroupsResponse>> getMuscleGroups();
  Future<BaseResponse<MusclesResponse>> getMusclesByGroupId(String id);
}
