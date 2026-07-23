import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@injectable
class GetDifficultyLevelsByPrimeMoverUseCase {
  final WorkoutRepoContract _repository;

  GetDifficultyLevelsByPrimeMoverUseCase(this._repository);

  Future<BaseResponse<List<DifficultyLevelEntity>>> call({
    required String primeMoverMuscleId,
  }) {
    return _repository.getDifficultyLevelsByPrimeMover(primeMoverMuscleId);
  }
}
