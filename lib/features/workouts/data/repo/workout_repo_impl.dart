import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/data/data_sources/workout_remote_data_source_contract.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_groups_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscles_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@Injectable(as: WorkoutRepoContract)
class WorkoutRepoImpl implements WorkoutRepoContract {
  final WorkoutRemoteDataSource _remoteDataSource;

  const WorkoutRepoImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups() async {
    final response = await _remoteDataSource.getMuscleGroups();

    switch (response) {
      case SuccessBaseResponse<MuscleGroupsResponse>():
        final entities = response.data?.musclesGroup
                ?.map((e) => e.toEntity())
                .toList() ??
            [];
        return SuccessBaseResponse(entities);
      case ErrorBaseResponse<MuscleGroupsResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(String id) async {
    final response = await _remoteDataSource.getMusclesByGroupId(id);

    switch (response) {
      case SuccessBaseResponse<MusclesResponse>():
        final entities = response.data?.muscles
                ?.map((e) => e.toEntity())
                .toList() ??
            [];
        return SuccessBaseResponse(entities);
      case ErrorBaseResponse<MusclesResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }
}
