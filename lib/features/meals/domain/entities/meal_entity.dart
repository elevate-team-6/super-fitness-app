import 'package:equatable/equatable.dart';
import 'ingredient_entity.dart';

class MealEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String image;
  final String instructions;
  final List<IngredientEntity> ingredients;

  const MealEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.instructions,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    image,
    instructions,
    ingredients,
  ];
}
