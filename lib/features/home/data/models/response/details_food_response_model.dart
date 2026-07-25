import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_model.dart';

class DetailsFoodResponseModel {
  /// `lookup.php` answers with `{"meals": null}` for an unknown id rather than
  /// a 404, so this stays nullable and the repo turns it into an error.
  final List<DetailsFoodModel>? meals;

  const DetailsFoodResponseModel({this.meals});

  factory DetailsFoodResponseModel.fromJson(Map<String, dynamic> json) =>
      DetailsFoodResponseModel(
        meals: (json[ApiParameters.meals] as List<dynamic>?)
            ?.map(
              (meal) => DetailsFoodModel.fromJson(meal as Map<String, dynamic>),
            )
            .toList(),
      );
}
