import 'package:injectable/injectable.dart';

import '../../domain/repo/workout_repo_contract.dart';
import '../data_sources/workout_remote_data_source_contract.dart';

@Injectable(as: WorkoutRepoContract)
class WorkoutRepoImpl implements WorkoutRepoContract {
  // ignore: unused_field
  final WorkoutRemoteDataSourceContract _workoutRemoteDataSourceContract;

  WorkoutRepoImpl(this._workoutRemoteDataSourceContract);
}
