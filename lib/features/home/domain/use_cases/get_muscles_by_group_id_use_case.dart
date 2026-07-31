import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/muscle_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetMusclesByGroupIdUseCase {
  final HomeRepoContract _repo;

  GetMusclesByGroupIdUseCase(this._repo);

  Future<BaseResponse<List<MuscleEntity>>> call(String id) {
    return _repo.getMusclesByGroupId(id);
  }
}
