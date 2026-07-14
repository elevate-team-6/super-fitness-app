import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

abstract interface class AuthRepoContract {
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
