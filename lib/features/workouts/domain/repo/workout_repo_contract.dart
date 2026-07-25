import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';

abstract interface class WorkoutRepoContract {
  Future<BaseResponse<List<DifficultyLevelEntity>>>
  getDifficultyLevelsByPrimeMover(String primeMoverMuscleId);

  Future<BaseResponse<List<ExerciseEntity>>> getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  );
  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups();
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(String id);
}
