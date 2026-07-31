import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/muscle_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetMuscleGroupsUseCase {
  final HomeRepoContract _repo;

  GetMuscleGroupsUseCase(this._repo);

  Future<BaseResponse<List<MuscleEntity>>> call() {
    return _repo.getMuscleGroups();
  }
}
