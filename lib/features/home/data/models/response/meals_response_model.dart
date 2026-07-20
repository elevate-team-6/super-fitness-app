import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';

class MealsResponseModel {
  /// TheMealDB returns `{"meals": null}` — not an empty list — when a category
  /// yields no results, so this stays nullable.
  final List<MealModel>? meals;

  const MealsResponseModel({this.meals});

  factory MealsResponseModel.fromJson(Map<String, dynamic> json) =>
      MealsResponseModel(
        meals: (json[ApiParameters.meals] as List<dynamic>?)
            ?.map((meal) => MealModel.fromJson(meal as Map<String, dynamic>))
            .toList(),
      );
}
