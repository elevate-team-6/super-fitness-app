import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/data/models/response/meal_details_model.dart';

class MealDetailsResponseModel {
  /// `lookup.php` answers with `{"meals": null}` for an unknown id rather than
  /// a 404, so this stays nullable and the repo turns it into an error.
  final List<MealDetailsModel>? meals;

  const MealDetailsResponseModel({this.meals});

  factory MealDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      MealDetailsResponseModel(
        meals: (json[ApiParameters.meals] as List<dynamic>?)
            ?.map(
              (meal) => MealDetailsModel.fromJson(meal as Map<String, dynamic>),
            )
            .toList(),
      );
}
