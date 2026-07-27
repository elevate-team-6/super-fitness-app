import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/data/local/sqlite/catalog_local_data_source.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';
import 'package:super_fitness/features/workouts/domain/repo/workout_repo_contract.dart';

@Injectable(as: WorkoutRepoContract)
class WorkoutRepoImpl implements WorkoutRepoContract {
  final CatalogLocalDataSource _localDataSource;

  WorkoutRepoImpl(this._localDataSource);

  @override
  Future<BaseResponse<List<DifficultyLevelEntity>>>
  getDifficultyLevelsByPrimeMover(String primeMoverMuscleId) async {
    try {
      final levels = await _localDataSource.getDifficultyLevelsByPrimeMover(
        primeMoverMuscleId,
      );
      return SuccessBaseResponse(
        levels
            .map(
              (e) => DifficultyLevelEntity(id: e.id ?? '', name: e.name ?? ''),
            )
            .toList(),
      );
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<ExerciseEntity>>> getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  ) async {
    try {
      final exercises = await _localDataSource.getExercisesByMuscleDifficulty(
        primeMoverMuscleId,
        difficultyLevelId,
      );
      // Ensure we map to the workouts version of ExerciseEntity
      return SuccessBaseResponse<List<ExerciseEntity>>(
        exercises.map((e) => e.toEntity()).toList(),
      );
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<MuscleGroupEntity>>> getMuscleGroups() async {
    try {
      final groups = await _localDataSource.getMuscleGroups();
      return SuccessBaseResponse(
        groups
            .map((e) => MuscleGroupEntity(id: e.id ?? '', name: e.name ?? ''))
            .toList(),
      );
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(
    String id,
  ) async {
    try {
      final muscles = await _localDataSource.getMusclesByGroupId(id);
      return SuccessBaseResponse(
        muscles
            .map(
              (e) => MuscleEntity(
                id: e.id ?? '',
                name: e.name ?? '',
                image: e.image ?? '',
              ),
            )
            .toList(),
      );
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }
}
