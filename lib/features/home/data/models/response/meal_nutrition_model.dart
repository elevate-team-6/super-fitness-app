import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/domain/entities/meal_nutrition_entity.dart';

/// The inner JSON object the model is constrained to return by the request's
/// `response_format` schema — not the chat-completion envelope itself, which
/// [ChatCompletionResponseModel] unwraps first.
///
/// Also the on-disk cache shape: [toJson] is what gets written to Hive, so any
/// field added here has to survive a round trip.
class MealNutritionModel {
  final double? caloriesKcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  const MealNutritionModel({
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  factory MealNutritionModel.fromJson(Map<String, dynamic> json) =>
      MealNutritionModel(
        caloriesKcal: _toDouble(json[ApiParameters.caloriesKcal]),
        proteinG: _toDouble(json[ApiParameters.proteinG]),
        carbsG: _toDouble(json[ApiParameters.carbsG]),
        fatG: _toDouble(json[ApiParameters.fatG]),
      );

  Map<String, dynamic> toJson() => {
    ApiParameters.caloriesKcal: caloriesKcal,
    ApiParameters.proteinG: proteinG,
    ApiParameters.carbsG: carbsG,
    ApiParameters.fatG: fatG,
  };

  MealNutritionEntity toEntity() => MealNutritionEntity(
    calories: _sanitize(caloriesKcal),
    protein: _sanitize(proteinG),
    carbs: _sanitize(carbsG),
    fat: _sanitize(fatG),
  );

  /// The schema asks for NUMBER, which arrives as either `int` or `double`
  /// depending on whether the estimate came out whole.
  static double? _toDouble(dynamic value) => (value as num?)?.toDouble();

  /// A missing or negative macro is a bad estimate rather than a real zero, but
  /// there is nothing better to show than 0 for it.
  static double _sanitize(double? value) {
    if (value == null || value.isNaN || value < 0) return 0;
    return value;
  }
}
