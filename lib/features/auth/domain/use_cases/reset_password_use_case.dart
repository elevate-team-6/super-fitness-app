import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepoContract _repository;

  ResetPasswordUseCase(this._repository);

  Future<BaseResponse<ForgetPasswordEntity>> call({
    required String email,
    required String newPassword,
  }) {
    return _repository.resetPassword(email: email, newPassword: newPassword);
  }
}