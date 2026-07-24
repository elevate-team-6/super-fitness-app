import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/utils/app_end_points.dart';
import '../../data/models/response/muscle_groups_response.dart';
import '../../data/models/response/muscles_response.dart';

part 'workout_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class WorkoutApiClient {
  @factoryMethod
  factory WorkoutApiClient(Dio dio) = _WorkoutApiClient;

  @GET(AppEndPoints.muscles)
  Future<MuscleGroupsResponse> getMuscleGroups();

  @GET("${AppEndPoints.musclesGroup}/{id}")
  Future<MusclesResponse> getMusclesByGroupId(@Path("id") String id);
}
