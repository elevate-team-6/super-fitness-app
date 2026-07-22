import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/utils/app_end_points.dart';
import '../../../../core/utils/app_params.dart';
import '../../data/models/response/exercise_response.dart';
import '../../data/models/response/meal_category_response.dart';
import '../../data/models/response/muscle_response.dart';

part 'home_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class HomeApiClient {
  @factoryMethod
  factory HomeApiClient(Dio dio) = _HomeApiClient;

  @GET(AppEndPoints.randomExercises)
  Future<ExerciseResponse> getRandomExercises({
    @Header(ApiParameters.acceptLanguage) required String language,
    @Query(ApiParameters.targetMuscleGroupId) String? targetMuscleGroupId,
    @Query(ApiParameters.difficultyLevelId) String? difficultyLevelId,
    @Query(ApiParameters.limit) int? limit,
  });

  @GET(AppEndPoints.muscles)
  Future<MuscleResponse> getMuscleGroups({
    @Header(ApiParameters.acceptLanguage) required String language,
  });

  @GET(AppEndPoints.mealCategories)
  Future<MealCategoryResponse> getMealsCategories();

  @GET(AppEndPoints.exercises)
  Future<ExerciseResponse> getAllExercises({
    @Header(ApiParameters.acceptLanguage) required String language,
    @Query(ApiParameters.page) int? page,
    @Query(ApiParameters.limit) int? limit,
  });
}
