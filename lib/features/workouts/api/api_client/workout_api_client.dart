import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/utils/app_end_points.dart';

part 'workout_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class WorkoutApiClient {
  @factoryMethod
  factory WorkoutApiClient(Dio dio) = _WorkoutApiClient;
}
