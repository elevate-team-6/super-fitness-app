import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@injectable
class VerifyResetCodeUseCase {
  final AuthRepoContract _repository;

  VerifyResetCodeUseCase(this._repository);

  Future<BaseResponse<ForgetPasswordEntity>> call({required String resetCode}) {
    return _repository.verifyResetCode(resetCode: resetCode);
  }
}