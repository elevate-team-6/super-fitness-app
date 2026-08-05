import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@injectable
class GetProfileDataUseCase {
  final ProfileRepoContract _repo;

  const GetProfileDataUseCase(this._repo);

  Future<BaseResponse<UserEntity>> call(bool isFromRemote) {
    if (isFromRemote) {
      return _repo.getRemoteProfileData();
    }
    return _repo.getLocalProfileData();
  }
}
