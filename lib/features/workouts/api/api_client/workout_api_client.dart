import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_levels_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercises_by_muscle_difficulty_response.dart';

part 'workout_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class WorkoutApiClient {
  @factoryMethod
  factory WorkoutApiClient(Dio dio) = _WorkoutApiClient;

  @GET(AppEndPoints.getDifficultyLevelsByPrimeMover)
  Future<DifficultyLevelsResponse> getDifficultyLevelsByPrimeMover(
    @Query(ApiParameters.primeMoverMuscleId) String primeMoverMuscleId,
  );

  @GET(AppEndPoints.getExercisesByMuscleDifficulty)
  Future<ExercisesByMuscleDifficultyResponse> getExercisesByMuscleDifficulty(
    @Query(ApiParameters.primeMoverMuscleId) String primeMoverMuscleId,
    @Query(ApiParameters.difficultyLevelId) String difficultyLevelId,
  );
}
