import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@injectable
class LogoutUseCase {
  final AuthRepoContract _repository;

  LogoutUseCase(this._repository);

  Future<BaseResponse<void>> call() {
    return _repository.logout();
  }
}
