import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/home/api/api_client/home_api_client.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

@Injectable(as: HomeRemoteDataSourceContract)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSourceContract {
  final HomeApiClient _apiClient;

  const HomeRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<MealsResponseModel>> getMealsByCategory(String category) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getMealsByCategory(category),
    );
  }
}
