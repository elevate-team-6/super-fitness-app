import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';

abstract interface class AuthRemoteDataSourceContract {
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request);
}
