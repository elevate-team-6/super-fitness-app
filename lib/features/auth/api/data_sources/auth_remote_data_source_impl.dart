import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/error_handler/error_handler.dart';
import '../../data/data_sources/auth_remote_data_source_contract.dart';
import '../../data/models/request/signup_request.dart';
import '../../data/models/response/signup_response.dart';
import '../api_client/auth_api_client.dart';

@Injectable(as: AuthRemoteDataSourceContract)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSourceContract {
  final AuthApiClient _apiClient;
  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<SignupResponse>> signup(SignupRequest request) async {
    return ErrorHandler.handleApiCall(() {
      return _apiClient.signup(request);
    });
  }
}
