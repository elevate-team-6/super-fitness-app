import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/level_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetLevelsUseCase {
  final HomeRepoContract _repo;

  GetLevelsUseCase(this._repo);

  Future<BaseResponse<List<LevelEntity>>> call() {
    return _repo.getLevels();
  }
}
