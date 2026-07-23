import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

abstract interface class WorkoutRepoContract {
  Future<BaseResponse<List<DifficultyLevelEntity>>>
  getDifficultyLevelsByPrimeMover(String primeMoverMuscleId);

  Future<BaseResponse<ExercisesEntity>> getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  );
}
