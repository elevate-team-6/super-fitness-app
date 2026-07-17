import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/auth/api/api_client/auth_api_client.dart';
import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';

@Injectable(as: AuthRemoteDataSourceContract)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSourceContract {
  final AuthApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request) {
    return ErrorHandler.handleApiCall(() => _apiClient.signIn(request));
  }
}
