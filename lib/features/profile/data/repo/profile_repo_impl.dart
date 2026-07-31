import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract {
  final ProfileRemoteDataSourceContract _remoteDataSource;
  final ProfileLocalDataSourceContract _localDataSource;
  final SecureCacheHelper _secureCacheHelper;

  const ProfileRepoImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._secureCacheHelper,
  );

  @override
  Future<UserEntity?> getCachedUser() => _localDataSource.getCachedUser();

  @override
  Future<BaseResponse<UserEntity>> editProfile(
    EditProfileRequest request,
  ) async {
    final response = await _remoteDataSource.editProfile(request);
    if (response is SuccessBaseResponse<UserEntity> && response.data != null) {
      await _cacheUser(response.data!);
    }
    return response;
  }

  @override
  Future<BaseResponse<String>> uploadPhoto(File photo) =>
      _remoteDataSource.uploadPhoto(photo);

  Future<void> _cacheUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      gender: user.gender,
      age: user.age,
      weight: user.weight,
      height: user.height,
      activityLevel: user.activityLevel,
      goal: user.goal,
      photo: user.photo,
      createdAt: user.createdAt,
    );
    await _secureCacheHelper.writeData(
      key: AppKeys.userDataKey,
      value: jsonEncode(userModel.toJson()),
    );
  }
}
