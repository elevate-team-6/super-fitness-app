import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/data/models/response/profile_data_response.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract {
  final ProfileRemoteDataSourceContract _remoteDataSource;
  final ProfileLocalDataSourceContract _localDataSource;

  final _userStreamController = StreamController<UserEntity?>.broadcast();

  ProfileRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Stream<UserEntity?> get userStream => _userStreamController.stream;

  @override
  Future<BaseResponse<String>> uploadPhoto(File photo) =>
      _remoteDataSource.uploadPhoto(photo);

  @override
  Future<BaseResponse<UserEntity>> editProfile(
    EditProfileRequest request,
  ) async {
    return await _remoteDataSource.editProfile(request);
  }

  @override
  Future<BaseResponse<UserEntity>> getRemoteProfileData() async {
    final response = await _remoteDataSource.getProfileData();

    switch (response) {
      case SuccessBaseResponse<ProfileDataResponse>(data: final profileData):
        final user = profileData?.user;
        if (user == null) {
          return ErrorBaseResponse(AppStrings.unexpectedError.tr());
        }

        await _localDataSource.cacheUser(user);

        final entity = user.toEntity();
        _userStreamController.add(entity); // Notify listeners

        return SuccessBaseResponse(entity);

      case ErrorBaseResponse<ProfileDataResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<UserEntity>> getLocalProfileData() async {
    final cachedUser = await _localDataSource.getCachedUser();

    if (cachedUser == null) {
      return await getRemoteProfileData();
    }

    _userStreamController.add(cachedUser); // Initial notification

    return SuccessBaseResponse(cachedUser);
  }
}
