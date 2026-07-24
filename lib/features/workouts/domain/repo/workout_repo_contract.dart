import 'package:super_fitness/config/base_response/base_response.dart';
import '../entities/muscle_entity.dart';
import '../entities/muscle_group_entity.dart';

abstract interface class WorkoutRepoContract {
  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups();
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(String id);
}
