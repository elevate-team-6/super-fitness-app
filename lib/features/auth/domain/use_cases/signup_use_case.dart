import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../data/models/request/signup_request.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo_contract.dart';

@injectable
class SignupUseCase {
  final AuthRepoContract _repository;

  const SignupUseCase(this._repository);

  Future<BaseResponse<UserEntity>> call(SignupRequest request) async {
    return await _repository.signup(request);
  }
}
