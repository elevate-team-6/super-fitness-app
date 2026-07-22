import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/exercise_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetRandomExercisesUseCase {
  final HomeRepoContract _repo;

  GetRandomExercisesUseCase(this._repo);

  Future<BaseResponse<List<ExerciseEntity>>> call({
    String? targetMuscleGroupId,
    String? difficultyLevelId,
    int? limit,
  }) {
    return _repo.getRandomExercises(
      targetMuscleGroupId: targetMuscleGroupId,
      difficultyLevelId: difficultyLevelId,
      limit: limit,
    );
  }
}
