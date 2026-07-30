import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/cache/secure_cache_helper.dart';
import '../../../../core/data/local/sqlite/catalog_local_data_source.dart';
import '../../../../core/utils/app_keys.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import '../../domain/entities/home_user_entity.dart';
import '../../domain/entities/level_entity.dart';
import '../../domain/entities/meal_category_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/muscle_entity.dart';
import '../../domain/repo/home_repo_contract.dart';

@LazySingleton(as: HomeRepoContract)
class HomeRepoImpl implements HomeRepoContract {
  final CatalogLocalDataSource _localDataSource;
  final SecureCacheHelper _secureCacheHelper;

  HomeRepoImpl(this._localDataSource, this._secureCacheHelper);

  @override
  Future<BaseResponse<HomeUserEntity>> getCachedUserData() async {
    try {
      final name = await _secureCacheHelper.readData(key: AppKeys.userNameKey);
      final image = await _secureCacheHelper.readData(
        key: AppKeys.userImageKey,
      );

      return SuccessBaseResponse(
        HomeUserEntity(name: name ?? AppStrings.athlete.tr(), image: image),
      );
    } catch (e) {
      return SuccessBaseResponse(HomeUserEntity.empty);
    }
  }

  @override
  Future<BaseResponse<List<ExerciseEntity>>> getRandomExercises({
    String? primeMoverMuscleId,
    String? difficultyLevelId,
    int? limit,
  }) async {
    try {
      final exercises = await _localDataSource.getRandomExercises(
        primeMoverMuscleId: primeMoverMuscleId,
        difficultyLevelId: difficultyLevelId,
        limit: limit,
      );
      return SuccessBaseResponse(exercises.map((e) => e.toEntity()).toList());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getMuscleGroups() async {
    try {
      final muscles = await _localDataSource.getMuscleGroups();
      return SuccessBaseResponse(muscles.map((e) => e.toEntity()).toList());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles() async {
    try {
      final muscles = await _localDataSource.getRandomMuscles();
      return SuccessBaseResponse(muscles.map((e) => e.toEntity()).toList());
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
      return SuccessBaseResponse(muscles.map((e) => e.toEntity()).toList());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<LevelEntity>>> getLevels() async {
    try {
      final levels = await _localDataSource.getLevels();
      return SuccessBaseResponse(levels.map((e) => e.toEntity()).toList());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<MealCategoryEntity>>> getMealsCategories() async {
    try {
      final categories = await _localDataSource.getMealsCategories();
      return SuccessBaseResponse(categories.map((e) => e.toEntity()).toList());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<List<MealEntity>>> getMealsByCategory(
    String category,
  ) async {
    try {
      final meals = await _localDataSource.getMealsByCategory(category);
      return SuccessBaseResponse(meals.map((e) => e.toEntity()).toList());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }

  @override
  Future<BaseResponse<DetailsFoodEntity>> getDetailsFood(String id) async {
    try {
      final meal = await _localDataSource.getDetailsFood(id);
      if (meal == null) {
        return const ErrorBaseResponse(AppStrings.detailsFoodNotFound);
      }
      return SuccessBaseResponse(meal.toEntity());
    } catch (e) {
      return ErrorBaseResponse(e.toString());
    }
  }
}
