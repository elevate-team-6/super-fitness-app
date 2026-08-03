import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/features/profile/data/models/response/profile_data_response.dart';

part 'profile_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class ProfileApiClient {
  @factoryMethod
  factory ProfileApiClient(Dio dio) = _ProfileApiClient;

  /// The bearer token is attached by AuthInterceptor, so this takes no args.
  @GET(AppEndPoints.profileData)
  Future<ProfileDataResponse> getProfileData();
}
