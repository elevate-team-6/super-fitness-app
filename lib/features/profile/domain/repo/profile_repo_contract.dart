import 'dart:io';

import 'package:super_fitness/config/base_response/base_response.dart';

import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';

abstract class ProfileRepoContract {
  /// The user kept from an earlier fetch, or null on the first visit.
  Future<UserEntity?> getCachedUser();

  Future<BaseResponse<UserEntity>> editProfile(EditProfileRequest request);

  Future<BaseResponse<String>> uploadPhoto(File photo);

  /// Hits `/auth/profile-data` and refreshes the cached copy with the result.
  Future<BaseResponse<UserEntity>> getProfileData();
}
