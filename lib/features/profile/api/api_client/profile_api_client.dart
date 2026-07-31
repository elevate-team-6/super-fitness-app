import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/data/models/response/edit_profile_response.dart';
import 'package:super_fitness/features/profile/data/models/response/upload_photo_response.dart';

part 'profile_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class ProfileApiClient {
  @factoryMethod
  factory ProfileApiClient(Dio dio) = _ProfileApiClient;

  @PUT(AppEndPoints.editProfile)
  Future<EditProfileResponse> editProfile(@Body() EditProfileRequest request);

  @PUT(AppEndPoints.uploadPhoto)
  @MultiPart()
  Future<UploadPhotoResponse> uploadPhoto(@Part(name: 'photo') File photo);
}
