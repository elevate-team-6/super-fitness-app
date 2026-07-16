import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@injectable
class SignInUseCase {
  final AuthRepoContract _repo;

  SignInUseCase(this._repo);

  Future<BaseResponse<SignInEntity>> call(SignInRequestModel request) {
    return _repo.signIn(request);
  }
}
