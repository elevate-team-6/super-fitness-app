import '../../../../config/base_response/base_response.dart';
import '../../data/models/request/signup_request.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepoContract {
  Future<BaseResponse<UserEntity>> signup(SignupRequest request);
}
