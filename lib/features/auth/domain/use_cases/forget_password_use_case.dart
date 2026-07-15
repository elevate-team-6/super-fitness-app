import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@injectable
class ForgetPasswordUseCase {
  final AuthRepoContract _repository;

  ForgetPasswordUseCase(this._repository);

  Future<BaseResponse<ForgetPasswordEntity>> call({required String email}) {
    return _repository.forgotPassword(email: email);
  }
}
