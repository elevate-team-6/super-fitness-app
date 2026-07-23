import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@injectable
class GetExercisesByMuscleDifficultyUseCase {
  final WorkoutRepoContract _repository;

  GetExercisesByMuscleDifficultyUseCase(this._repository);

  Future<BaseResponse<ExercisesEntity>> call({
    required String primeMoverMuscleId,
    required String difficultyLevelId,
  }) {
    return _repository.getExercisesByMuscleDifficulty(
      primeMoverMuscleId,
      difficultyLevelId,
    );
  }
}
