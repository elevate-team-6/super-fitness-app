import 'package:equatable/equatable.dart';

/// Macros for the **whole recipe** as written — the sum of every ingredient in
/// [DetailsFoodEntity.ingredients], not a per-serving figure.
///
/// These are model estimates, not measured values. TheMealDB ships no nutrition
/// data at all, so they are inferred from the ingredient list and should be
/// presented as approximate.
class MealNutritionEntity extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealNutritionEntity({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object?> get props => [calories, protein, carbs, fat];
}
