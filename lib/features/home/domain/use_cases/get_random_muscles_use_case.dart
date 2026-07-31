import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/muscle_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetRandomMusclesUseCase {
  final HomeRepoContract _repo;

  GetRandomMusclesUseCase(this._repo);

  Future<BaseResponse<List<MuscleEntity>>> call() {
    return _repo.getRandomMuscles();
  }
}
