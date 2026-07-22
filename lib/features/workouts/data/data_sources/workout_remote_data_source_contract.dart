import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_levels_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercises_by_muscle_difficulty_response.dart';

abstract interface class WorkoutRemoteDataSourceContract {
  Future<BaseResponse<DifficultyLevelsResponse>> getDifficultyLevelsByPrimeMover(
    String primeMoverMuscleId,
  );

  Future<BaseResponse<ExercisesByMuscleDifficultyResponse>>
      getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  );
}
