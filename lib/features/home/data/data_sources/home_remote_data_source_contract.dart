import '../../../../config/base_response/base_response.dart';
import '../models/response/details_food_response_model.dart';
import '../models/response/exercise_response.dart';
import '../models/response/level_response.dart';
import '../models/response/meal_category_response.dart';
import '../models/response/meals_response_model.dart';
import '../models/response/muscle_response.dart';
import '../models/response/muscles_by_group_response.dart';

abstract interface class HomeRemoteDataSourceContract {
  Future<BaseResponse<ExerciseResponse>> getRandomExercises({
    required String language,
    String? targetMuscleGroupId,
    String? difficultyLevelId,
    int? limit,
  });

  Future<BaseResponse<MuscleResponse>> getMuscleGroups({
    required String language,
  });

  Future<BaseResponse<MuscleResponse>> getRandomMuscles({
    required String language,
  });

  Future<BaseResponse<MusclesByGroupResponse>> getMusclesByGroupId({
    required String language,
    required String id,
  });

  Future<BaseResponse<LevelResponse>> getLevels({required String language});

  Future<BaseResponse<MealCategoryResponse>> getMealsCategories();

  Future<BaseResponse<ExerciseResponse>> getAllExercises({
    required String language,
    String? targetMuscleGroupId,
    String? muscleId,
    String? difficultyLevelId,
    int? page,
    int? limit,
  });

  Future<BaseResponse<MealsResponseModel>> getMealsByCategory(String category);

  Future<BaseResponse<DetailsFoodResponseModel>> getDetailsFood(String id);

}
