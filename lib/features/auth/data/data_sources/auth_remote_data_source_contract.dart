import '../../../../config/base_response/base_response.dart';
import '../models/request/sign_in_request_model.dart';
import '../models/request/signup_request.dart';
import '../models/response/sign_in_response_model.dart';
import '../models/response/signup_response.dart';

abstract interface class AuthRemoteDataSourceContract {
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request);

  Future<BaseResponse<SignupResponse>> signup(SignupRequest request);
}
