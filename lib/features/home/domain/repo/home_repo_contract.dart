import '../../../../config/base_response/base_response.dart';
import '../entities/details_food_entity.dart';
import '../entities/exercise_entity.dart';
import '../entities/home_user_entity.dart';
import '../entities/level_entity.dart';
import '../entities/meal_category_entity.dart';
import '../entities/meal_entity.dart';
import '../entities/muscle_entity.dart';

abstract interface class HomeRepoContract {
  Future<BaseResponse<HomeUserEntity>> getCachedUserData();

  Future<BaseResponse<List<ExerciseEntity>>> getRandomExercises({
    String? primeMoverMuscleId,
    String? difficultyLevelId,
    int? limit,
  });

  Future<BaseResponse<List<MuscleEntity>>> getMuscleGroups();

  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles();

  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(String id);

  Future<BaseResponse<List<LevelEntity>>> getLevels();

  Future<BaseResponse<List<MealCategoryEntity>>> getMealsCategories();

  Future<BaseResponse<List<MealEntity>>> getMealsByCategory(String category);

  Future<BaseResponse<DetailsFoodEntity>> getDetailsFood(String id);
}
