import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/repo/home_repo_contract.dart';

@Injectable(as: HomeRepoContract)
class HomeRepoImpl implements HomeRepoContract {
  final HomeRemoteDataSourceContract _remoteDataSource;

  const HomeRepoImpl(this._remoteDataSource);

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

    // Only fail when nothing came back at all — one dead category shouldn't
    // blank out a meal time that has other categories behind it.
    if (buckets.isEmpty) {
      return ErrorBaseResponse(firstError ?? AppStrings.noMealsFound);
    }

    return SuccessBaseResponse(_interleave(buckets));
  }

  /// Round-robins the categories so a multi-category meal time doesn't render
  /// as "all the chicken, then all the pasta". Duplicate ids are dropped.
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
