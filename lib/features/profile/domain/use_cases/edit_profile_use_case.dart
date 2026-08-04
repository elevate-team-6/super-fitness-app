import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@injectable
class EditProfileUseCase {
  final ProfileRepoContract _repository;

  const EditProfileUseCase(this._repository);

  Future<BaseResponse<UserEntity>> call(EditProfileRequest request) =>
      _repository.editProfile(request);
}
