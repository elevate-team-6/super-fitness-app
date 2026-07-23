import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/data/data_sources/workout_remote_data_source_contract.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_levels_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercises_by_muscle_difficulty_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@Injectable(as: WorkoutRepoContract)
class WorkoutRepoImpl implements WorkoutRepoContract {
  final WorkoutRemoteDataSourceContract _workoutRemoteDataSourceContract;

  WorkoutRepoImpl(this._workoutRemoteDataSourceContract);

  @override
  Future<BaseResponse<List<DifficultyLevelEntity>>>
  getDifficultyLevelsByPrimeMover(String primeMoverMuscleId) async {
    final response = await _workoutRemoteDataSourceContract
        .getDifficultyLevelsByPrimeMover(primeMoverMuscleId);

    switch (response) {
      case SuccessBaseResponse<DifficultyLevelsResponse>():
        final entityList = response.data?.toEntity() ?? [];
        return SuccessBaseResponse(entityList);
      case ErrorBaseResponse<DifficultyLevelsResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<ExercisesEntity>> getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  ) async {
    final response = await _workoutRemoteDataSourceContract
        .getExercisesByMuscleDifficulty(primeMoverMuscleId, difficultyLevelId);

    switch (response) {
      case SuccessBaseResponse<ExercisesByMuscleDifficultyResponse>():
        final entity = response.data?.toEntity();
        return SuccessBaseResponse(entity);
      case ErrorBaseResponse<ExercisesByMuscleDifficultyResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }
}
