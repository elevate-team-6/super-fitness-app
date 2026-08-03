import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/profile/api/api_client/profile_api_client.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/models/response/profile_data_response.dart';

@Injectable(as: ProfileRemoteDataSourceContract)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSourceContract {
  final ProfileApiClient _apiClient;

  const ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<ProfileDataResponse>> getProfileData() {
    return ErrorHandler.handleApiCall(() => _apiClient.getProfileData());
  }
}
