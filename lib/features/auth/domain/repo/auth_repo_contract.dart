import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';

abstract interface class AuthRepoContract {
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request);
}
