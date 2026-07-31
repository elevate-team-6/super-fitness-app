import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@injectable
class UploadProfilePhotoUseCase {
  final ProfileRepoContract _repository;

  const UploadProfilePhotoUseCase(this._repository);

  Future<BaseResponse<String>> call(File photo) =>
      _repository.uploadPhoto(photo);
}
