import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../entities/exercise_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetPopularTrainingExercisesUseCase {
  final HomeRepoContract _repo;

  GetPopularTrainingExercisesUseCase(this._repo);

  Future<BaseResponse<List<ExerciseEntity>>> call() async {
    final levelsResult = await _repo.getLevels();
    final musclesResult = await _repo.getRandomMuscles();

    if (levelsResult is SuccessBaseResponse &&
        musclesResult is SuccessBaseResponse) {
      final levels = (levelsResult as SuccessBaseResponse).data ?? [];
      final muscles = (musclesResult as SuccessBaseResponse).data ?? [];

      if (levels.isEmpty || muscles.isEmpty) {
        return const SuccessBaseResponse([]);
      }

      final List<ExerciseEntity> allExercises = [];
      final random = Random();

      // Repeat 3 times as requested
      for (int i = 0; i < 3; i++) {
        final randomLevelId = levels[random.nextInt(levels.length)].id;
        final randomMuscleId = muscles[random.nextInt(muscles.length)].id;

        final exercisesResult = await _repo.getRandomExercises(
          difficultyLevelId: randomLevelId,
          targetMuscleGroupId: randomMuscleId,
          limit: 2,
        );

        if (exercisesResult is SuccessBaseResponse) {
          allExercises.addAll((exercisesResult as SuccessBaseResponse).data ?? []);
        }
      }

      // Remove duplicates if any
      final uniqueExercises = {for (var e in allExercises) e.id: e}.values.toList();

      return SuccessBaseResponse(uniqueExercises);
    }

    return const ErrorBaseResponse("Failed to fetch levels or muscles");
  }
}
