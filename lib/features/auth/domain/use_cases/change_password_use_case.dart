import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@injectable
class ChangePasswordUseCase {
  final AuthRepoContract _repository;

  ChangePasswordUseCase(this._repository);

  Future<BaseResponse<ForgetPasswordEntity>> call({
    required String password,
    required String newPassword,
  }) {
    return _repository.changePassword(
      password: password,
      newPassword: newPassword,
    );
  }
}
