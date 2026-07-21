import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/data/models/response/chat_completion_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

part 'home_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.mealDbBaseUrl)
abstract class HomeApiClient {
  @factoryMethod
  factory HomeApiClient(@Named('external') Dio dio) = _HomeApiClient;

  @GET(AppEndPoints.mealsByCategory)
  Future<MealsResponseModel> getMealsByCategory(
    @Query(ApiParameters.category) String category,
  );

  @GET(AppEndPoints.detailsFood)
  Future<DetailsFoodResponseModel> getDetailsFood(
    @Query(ApiParameters.mealId) String id,
  );

  @POST(AppEndPoints.groqChatCompletions)
  Future<ChatCompletionResponseModel> generateNutrition(
    @Header(AppKeys.authorizationKey) String bearerToken,
    @Body() Map<String, dynamic> body,
  );
}
