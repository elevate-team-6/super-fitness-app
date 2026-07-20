import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/data/models/response/meal_details_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

part 'food_api_client.g.dart';

/// TheMealDB client. Takes the @Named('external') Dio because this is a
/// third-party host — the default Dio would attach our auth token to it.
@lazySingleton
@RestApi(baseUrl: AppEndPoints.mealDbBaseUrl)
abstract class FoodApiClient {
  @factoryMethod
  factory FoodApiClient(@Named('external') Dio dio) = _FoodApiClient;

  @GET(AppEndPoints.mealsByCategory)
  Future<MealsResponseModel> getMealsByCategory(
    @Query(ApiParameters.category) String category,
  );

  /// Full record for a single meal — instructions, video and ingredients,
  /// none of which the category listing returns.
  @GET(AppEndPoints.mealDetails)
  Future<MealDetailsResponseModel> getMealDetails(
    @Query(ApiParameters.mealId) String id,
  );
}
