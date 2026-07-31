import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/api/api_client/profile_api_client.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/data/models/response/edit_profile_response.dart';
import 'package:super_fitness/features/profile/data/models/response/upload_photo_response.dart';

@Injectable(as: ProfileRemoteDataSourceContract)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSourceContract {
  final ProfileApiClient _apiClient;

  const ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<UserEntity>> editProfile(
    EditProfileRequest request,
  ) async {
    final response = await ErrorHandler.handleApiCall<EditProfileResponse>(
      () => _apiClient.editProfile(request),
    );

    switch (response) {
      case SuccessBaseResponse<EditProfileResponse>():
        return SuccessBaseResponse(response.data?.user?.toEntity());
      case ErrorBaseResponse<EditProfileResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<String>> uploadPhoto(File photo) async {
    final response = await ErrorHandler.handleApiCall<UploadPhotoResponse>(
      () => _apiClient.uploadPhoto(photo),
    );

    switch (response) {
      case SuccessBaseResponse<UploadPhotoResponse>():
        return SuccessBaseResponse(
          response.data?.message ?? AppStrings.success,
        );
      case ErrorBaseResponse<UploadPhotoResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }
}

