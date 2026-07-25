import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@injectable
class GetMusclesByGroupIdUseCase {
  final WorkoutRepoContract _repository;

  GetMusclesByGroupIdUseCase(this._repository);

  Future<BaseResponse<List<MuscleEntity>>> call({required String id}) {
    return _repository.getMusclesByGroupId(id);
  }
}
