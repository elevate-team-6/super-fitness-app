import '../../../../config/base_response/base_response.dart';
import '../../data/models/request/sign_in_request_model.dart';
import '../../data/models/request/signup_request.dart';
import '../entities/sign_in_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepoContract {
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request);

  Future<BaseResponse<UserEntity>> signup(SignupRequest request);
}
