import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';
import 'package:super_fitness/features/home/data/models/response/level_response.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscles_by_group_response.dart';

import '../../../../core/utils/app_params.dart';
import '../../data/models/response/meal_category_response.dart';

part 'home_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class HomeApiClient {
  @factoryMethod
  factory HomeApiClient(Dio dio) = _HomeApiClient;

  // ===========================================================================
  // Internal Backend Endpoints
  // ===========================================================================

  @GET(AppEndPoints.exercisesByMuscleDifficulty)
  Future<ExerciseResponse> getRandomExercises({
    @Header(ApiParameters.acceptLanguage) required String language,
    @Query(ApiParameters.primeMoverMuscleId) String? primeMoverMuscleId,
    @Query(ApiParameters.difficultyLevelId) String? difficultyLevelId,
    @Query(ApiParameters.limit) int? limit,
  });

  @GET(AppEndPoints.muscles)
  Future<MuscleResponse> getMuscleGroups({
    @Header(ApiParameters.acceptLanguage) required String language,
  });

  @GET(AppEndPoints.randomMuscles)
  Future<MuscleResponse> getRandomMuscles({
    @Header(ApiParameters.acceptLanguage) required String language,
  });

  @GET("${AppEndPoints.musclesGroup}/{id}")
  Future<MusclesByGroupResponse> getMusclesByGroupId({
    @Header(ApiParameters.acceptLanguage) required String language,
    @Path("id") required String id,
  });

  @GET(AppEndPoints.levels)
  Future<LevelResponse> getLevels({
    @Header(ApiParameters.acceptLanguage) required String language,
  });

  @GET(AppEndPoints.mealCategories)
  Future<MealCategoryResponse> getMealsCategories();

  @GET(AppEndPoints.mealsByCategory)
  Future<MealsResponseModel> getMealsByCategory(
    @Query(ApiParameters.category) String category,
  );

  @GET(AppEndPoints.detailsFood)
  Future<DetailsFoodResponseModel> getDetailsFood(
    @Query(ApiParameters.mealId) String id,
  );
}
