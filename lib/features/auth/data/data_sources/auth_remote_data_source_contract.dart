import '../../../../config/base_response/base_response.dart';
import '../models/request/signup_request.dart';
import '../models/response/signup_response.dart';

abstract interface class AuthRemoteDataSourceContract {
  Future<BaseResponse<SignupResponse>> signup(SignupRequest request);
}
