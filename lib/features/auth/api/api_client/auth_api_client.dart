import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/utils/app_end_points.dart';
import '../../data/models/request/signup_request.dart';
import '../../data/models/response/signup_response.dart';

part 'auth_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  @POST(AppEndPoints.signup)
  Future<SignupResponse> signup(@Body() SignupRequest request);
}
