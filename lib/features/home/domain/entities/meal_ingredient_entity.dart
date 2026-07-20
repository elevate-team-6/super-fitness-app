import 'package:equatable/equatable.dart';

/// One row of the ingredients list, e.g. measure `350g` of [name] `Salmon`.
class MealIngredientEntity extends Equatable {
  final String name;

  /// Free text from TheMealDB — `2 tbs chopped`, `Juice of 1`, `to serve`.
  /// Empty for ingredients the recipe gives no quantity for.
  final String measure;

  const MealIngredientEntity({required this.name, this.measure = ''});

  @override
  List<Object?> get props => [name, measure];
}
