import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@injectable
class GetMuscleGroupsUseCase {
  final WorkoutRepoContract _repository;

  GetMuscleGroupsUseCase(this._repository);

  Future<BaseResponse<List<MuscleGroupEntity>>> call() {
    return _repository.getMuscleGroups();
  }
}
