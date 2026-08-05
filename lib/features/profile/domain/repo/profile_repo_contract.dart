import 'dart:io';

import 'package:super_fitness/config/base_response/base_response.dart';

import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';

abstract class ProfileRepoContract {
  Future<BaseResponse<UserEntity>> editProfile(EditProfileRequest request);

  Future<BaseResponse<String>> uploadPhoto(File photo);

  Future<BaseResponse<UserEntity>> getRemoteProfileData();

  Future<BaseResponse<UserEntity>> getLocalProfileData();
}
