import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/workouts/api/api_client/workout_api_client.dart';
import 'package:super_fitness/features/workouts/data/data_sources/workout_remote_data_source_contract.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_levels_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercises_by_muscle_difficulty_response.dart';

@Injectable(as: WorkoutRemoteDataSourceContract)
class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSourceContract {
  final WorkoutApiClient _apiClient;

  const WorkoutRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<DifficultyLevelsResponse>> getDifficultyLevelsByPrimeMover(
    String primeMoverMuscleId,
  ) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getDifficultyLevelsByPrimeMover(primeMoverMuscleId),
    );
  }

  @override
  Future<BaseResponse<ExercisesByMuscleDifficultyResponse>>
      getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  ) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getExercisesByMuscleDifficulty(
        primeMoverMuscleId,
        difficultyLevelId,
      ),
    );
  }
}
