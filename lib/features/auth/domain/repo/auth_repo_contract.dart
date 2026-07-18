import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import '../../data/models/request/signup_request.dart';

import '../entities/user_entity.dart';

abstract interface class AuthRepoContract {
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request);

  Future<BaseResponse<UserEntity>> signup(SignupRequest request);

  Future<BaseResponse<ForgetPasswordEntity>> forgotPassword({
    required String email,
  });

  Future<BaseResponse<ForgetPasswordEntity>> verifyResetCode({
    required String resetCode,
  });

  Future<BaseResponse<ForgetPasswordEntity>> resetPassword({
    required String email,
    required String newPassword,
  });
}
