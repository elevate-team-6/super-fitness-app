import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/hive_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/meal_nutrition_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_nutrition_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/repo/home_repo_contract.dart';

@Injectable(as: HomeRepoContract)
class HomeRepoImpl implements HomeRepoContract {
  final HomeRemoteDataSourceContract _remoteDataSource;
  final HiveHelper _hiveHelper;

  const HomeRepoImpl(this._remoteDataSource, this._hiveHelper);

  @override
  Future<BaseResponse<List<MealEntity>>> getMealsByMealTime(
    MealTime mealTime,
  ) async {
    final responses = await Future.wait(
      mealTime.categories.map(_remoteDataSource.getMealsByCategory),
    );

    final buckets = <List<MealModel>>[];
    String? firstError;

    for (final response in responses) {
      switch (response) {
        case SuccessBaseResponse<MealsResponseModel>():
          final meals = response.data?.meals;
          if (meals != null && meals.isNotEmpty) buckets.add(meals);

        case ErrorBaseResponse<MealsResponseModel>():
          firstError ??= response.errorMessage;
      }
    }

    if (buckets.isEmpty) {
      return ErrorBaseResponse(firstError ?? AppStrings.noMealsFound);
    }

    return SuccessBaseResponse(_interleave(buckets));
  }

  @override
  Future<BaseResponse<DetailsFoodEntity>> getDetailsFood(String id) async {
    final response = await _remoteDataSource.getDetailsFood(id);

    switch (response) {
      case SuccessBaseResponse<DetailsFoodResponseModel>():
        final meals = response.data?.meals;

        if (meals == null || meals.isEmpty) {
          return const ErrorBaseResponse(AppStrings.detailsFoodNotFound);
        }

        return SuccessBaseResponse(meals.first.toEntity());

      case ErrorBaseResponse<DetailsFoodResponseModel>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<MealNutritionEntity>> getMealNutrition(
    DetailsFoodEntity meal,
  ) async {
    final cached = await _readCachedNutrition(meal.id);
    if (cached != null) return SuccessBaseResponse(cached.toEntity());

    final response = await _remoteDataSource.estimateNutrition(meal);

    switch (response) {
      case SuccessBaseResponse<MealNutritionModel>():
        final nutrition = response.data;
        if (nutrition == null) {
          return const ErrorBaseResponse(AppStrings.nutritionUnavailable);
        }

        await _writeCachedNutrition(meal.id, nutrition);
        return SuccessBaseResponse(nutrition.toEntity());

      case ErrorBaseResponse<MealNutritionModel>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  Future<MealNutritionModel?> _readCachedNutrition(String mealId) async {
    if (mealId.isEmpty) return null;

    try {
      final raw = await _hiveHelper.getData<String>(
        boxName: AppKeys.nutritionBoxName,
        key: mealId,
      );
      if (raw == null) return null;

      return MealNutritionModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCachedNutrition(
    String mealId,
    MealNutritionModel nutrition,
  ) async {
    if (mealId.isEmpty) return;

    try {
      await _hiveHelper.cacheData(
        boxName: AppKeys.nutritionBoxName,
        key: mealId,
        value: jsonEncode(nutrition.toJson()),
      );
    } catch (_) {}
  }

  List<MealEntity> _interleave(List<List<MealModel>> buckets) {
    final longest = buckets.fold<int>(
      0,
      (max, bucket) => bucket.length > max ? bucket.length : max,
    );

    final seenIds = <String>{};
    final meals = <MealEntity>[];

    for (var index = 0; index < longest; index++) {
      for (final bucket in buckets) {
        if (index >= bucket.length) continue;

        final meal = bucket[index].toEntity();
        if (meal.id.isEmpty || !seenIds.add(meal.id)) continue;

        meals.add(meal);
      }
    }

    return meals;
  }
}
