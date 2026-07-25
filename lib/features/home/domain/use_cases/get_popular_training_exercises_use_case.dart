import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../core/utils/app_strings.dart';
import '../entities/exercise_entity.dart';
import '../entities/level_entity.dart';
import '../entities/muscle_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetPopularTrainingExercisesUseCase {
  final HomeRepoContract _repo;

  GetPopularTrainingExercisesUseCase(this._repo);

  Future<BaseResponse<List<ExerciseEntity>>> call() async {
    final levelsResult = await _repo.getLevels();
    final musclesResult = await _repo.getRandomMuscles();

    if (levelsResult is SuccessBaseResponse<List<LevelEntity>> &&
        musclesResult is SuccessBaseResponse<List<MuscleEntity>>) {
      final levels = levelsResult.data ?? [];
      final muscles = musclesResult.data ?? [];

      if (levels.isEmpty || muscles.isEmpty) {
        return const SuccessBaseResponse<List<ExerciseEntity>>([]);
      }

      final Map<String, ExerciseEntity> uniqueExercises = {};
      final random = Random();

      int attempts = 0;
      // We need to collect 3 unique items.
      // If the API returns the same one, we keep trying with different random filters.
      while (uniqueExercises.length < 3 && attempts < 12) {
        attempts++;
        final randomLevelId = levels[random.nextInt(levels.length)].id;
        final randomMuscleId = muscles[random.nextInt(muscles.length)].id;

        // Try filtering by 'targetMuscleGroupId' which is a known valid key in this API
        final exercisesResult = await _repo.getAllExercises(
          difficultyLevelId: randomLevelId,
          muscleId: randomMuscleId,
          limit: 5, // Request more to increase chance of variety
        );

        if (exercisesResult is SuccessBaseResponse<List<ExerciseEntity>>) {
          final fetched = exercisesResult.data ?? [];
          for (final exercise in fetched) {
            if (uniqueExercises.length < 3) {
              uniqueExercises[exercise.id] = exercise;
            }
          }
        }
      }

      return SuccessBaseResponse<List<ExerciseEntity>>(
        uniqueExercises.values.toList(),
      );
    }

    return ErrorBaseResponse(AppStrings.failedToFetchLevelsOrMuscles.tr());
  }
}
