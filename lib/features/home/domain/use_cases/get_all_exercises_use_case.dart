import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/exercise_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetAllExercisesUseCase {
  final HomeRepoContract _repo;

  GetAllExercisesUseCase(this._repo);

  Future<BaseResponse<List<ExerciseEntity>>> call({int? page, int? limit}) {
    return _repo.getAllExercises(page: page, limit: limit);
  }
}
