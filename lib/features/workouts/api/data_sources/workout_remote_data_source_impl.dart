import 'package:injectable/injectable.dart';

import '../../data/data_sources/workout_remote_data_source_contract.dart';
import '../api_client/workout_api_client.dart';

@Injectable(as: WorkoutRemoteDataSourceContract)
class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSourceContract {
  // ignore: unused_field
  final WorkoutApiClient _apiClient;

  const WorkoutRemoteDataSourceImpl(this._apiClient);
}
