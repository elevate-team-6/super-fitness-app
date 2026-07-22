import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/error_handler/error_handler.dart';
import '../../data/data_sources/home_remote_data_source_contract.dart';
import '../../data/models/response/exercise_response.dart';
import '../../data/models/response/meal_category_response.dart';
import '../../data/models/response/muscle_response.dart';
import '../api_client/home_api_client.dart';

@Injectable(as: HomeRemoteDataSourceContract)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSourceContract {
  final HomeApiClient _apiClient;

  const HomeRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<ExerciseResponse>> getRandomExercises({
    required String language,
    String? targetMuscleGroupId,
    String? difficultyLevelId,
    int? limit,
  }) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getRandomExercises(
        language: language,
        targetMuscleGroupId: targetMuscleGroupId,
        difficultyLevelId: difficultyLevelId,
        limit: limit,
      ),
    );
  }

  @override
  Future<BaseResponse<MuscleResponse>> getMuscleGroups({
    required String language,
  }) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getMuscleGroups(language: language),
    );
  }

  @override
  Future<BaseResponse<MealCategoryResponse>> getMealsCategories() {
    return ErrorHandler.handleApiCall(() => _apiClient.getMealsCategories());
  }

  @override
  Future<BaseResponse<ExerciseResponse>> getAllExercises({
    required String language,
    int? page,
    int? limit,
  }) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getAllExercises(
        language: language,
        page: page,
        limit: limit,
      ),
    );
  }
}
