import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/core/utils/app_constants.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/cache/secure_cache_helper.dart';
import '../../../../core/utils/app_keys.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/home_user_entity.dart';
import '../../domain/entities/level_entity.dart';
import '../../domain/entities/meal_category_entity.dart';
import '../../domain/entities/muscle_entity.dart';
import '../../domain/repo/home_repo_contract.dart';
import '../data_sources/home_remote_data_source_contract.dart';
import '../models/response/exercise_response.dart';
import '../models/response/level_response.dart';
import '../models/response/meal_category_response.dart';
import '../models/response/muscle_response.dart';
import '../models/response/muscles_by_group_response.dart';

@LazySingleton(as: HomeRepoContract)
class HomeRepoImpl implements HomeRepoContract {
  final HomeRemoteDataSourceContract _homeRemoteDataSourceContract;
  final SecureCacheHelper _secureCacheHelper;

  HomeRepoImpl(this._homeRemoteDataSourceContract, this._secureCacheHelper);

  String get _currentLanguage => Intl.defaultLocale ?? AppConstants.englishCode;

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
    String? targetMuscleGroupId,
    String? difficultyLevelId,
    int? limit,
  }) async {
    final result = await _homeRemoteDataSourceContract.getRandomExercises(
      language: _currentLanguage,
      targetMuscleGroupId: targetMuscleGroupId,
      difficultyLevelId: difficultyLevelId,
      limit: limit,
    );

    switch (result) {
      case SuccessBaseResponse<ExerciseResponse>():
        return SuccessBaseResponse(
          result.data?.exercises?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<ExerciseResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getMuscleGroups() async {
    final result = await _homeRemoteDataSourceContract.getMuscleGroups(
      language: _currentLanguage,
    );

    switch (result) {
      case SuccessBaseResponse<MuscleResponse>():
        return SuccessBaseResponse(
          result.data?.musclesGroup?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<MuscleResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getRandomMuscles() async {
    final result = await _homeRemoteDataSourceContract.getRandomMuscles(
      language: _currentLanguage,
    );

    switch (result) {
      case SuccessBaseResponse<MuscleResponse>():
        return SuccessBaseResponse(
          result.data?.muscles?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<MuscleResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<MuscleEntity>>> getMusclesByGroupId(
    String id,
  ) async {
    final result = await _homeRemoteDataSourceContract.getMusclesByGroupId(
      language: _currentLanguage,
      id: id,
    );

    switch (result) {
      case SuccessBaseResponse<MusclesByGroupResponse>():
        return SuccessBaseResponse(
          result.data?.muscles?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<MusclesByGroupResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<LevelEntity>>> getLevels() async {
    final result = await _homeRemoteDataSourceContract.getLevels(
      language: _currentLanguage,
    );

    switch (result) {
      case SuccessBaseResponse<LevelResponse>():
        return SuccessBaseResponse(
          result.data?.levels?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<LevelResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<MealCategoryEntity>>> getMealsCategories() async {
    final result = await _homeRemoteDataSourceContract.getMealsCategories();

    switch (result) {
      case SuccessBaseResponse<MealCategoryResponse>():
        return SuccessBaseResponse(
          result.data?.categories?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<MealCategoryResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<ExerciseEntity>>> getAllExercises({
    String? targetMuscleGroupId,
    String? muscleId,
    String? difficultyLevelId,
    int? page,
    int? limit,
  }) async {
    final result = await _homeRemoteDataSourceContract.getAllExercises(
      language: _currentLanguage,
      targetMuscleGroupId: targetMuscleGroupId,
      muscleId: muscleId,
      difficultyLevelId: difficultyLevelId,
      page: page,
      limit: limit,
    );

    switch (result) {
      case SuccessBaseResponse<ExerciseResponse>():
        return SuccessBaseResponse(
          result.data?.exercises?.map((e) => e.toEntity()).toList() ?? [],
        );
      case ErrorBaseResponse<ExerciseResponse>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }
}
