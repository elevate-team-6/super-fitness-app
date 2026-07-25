import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

abstract class HomeRemoteDataSourceContract {
  Future<BaseResponse<MealsResponseModel>> getMealsByCategory(String category);

  Future<BaseResponse<DetailsFoodResponseModel>> getDetailsFood(String id);
}
