import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/home/api/api_client/food_api_client.dart';
import 'package:super_fitness/features/home/data/data_sources/food_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

@Injectable(as: FoodRemoteDataSourceContract)
class FoodRemoteDataSourceImpl implements FoodRemoteDataSourceContract {
  final FoodApiClient _apiClient;

  const FoodRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<MealsResponseModel>> getMealsByCategory(String category) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getMealsByCategory(category),
    );
  }

  @override
  Future<BaseResponse<DetailsFoodResponseModel>> getDetailsFood(String id) {
    return ErrorHandler.handleApiCall(() => _apiClient.getDetailsFood(id));
  }
}
