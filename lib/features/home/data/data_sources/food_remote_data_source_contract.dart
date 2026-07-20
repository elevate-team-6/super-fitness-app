import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_details_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

abstract class FoodRemoteDataSourceContract {
  Future<BaseResponse<MealsResponseModel>> getMealsByCategory(String category);

  Future<BaseResponse<MealDetailsResponseModel>> getMealDetails(String id);
}
