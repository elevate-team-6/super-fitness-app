import '../../../../config/base_response/base_response.dart';
import '../models/response/exercise_response.dart';
import '../models/response/meal_category_response.dart';
import '../models/response/muscle_response.dart';

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

  Future<BaseResponse<MealCategoryResponse>> getMealsCategories();

  Future<BaseResponse<ExerciseResponse>> getAllExercises({
    required String language,
    int? page,
    int? limit,
  });
}
