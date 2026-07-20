import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';

/// The full meal record behind `lookup.php`, as opposed to the three-field
/// [MealEntity] the grid is built from.
class MealDetailsEntity extends Equatable {
  final String id;
  final String name;
  final String thumbnail;
  final String category;
  final String area;

  /// The recipe steps — rendered as the screen's description section.
  final String instructions;

  /// YouTube watch URL. Null when the recipe has no video, which is common
  /// enough that the player section has to be optional.
  final String? youtubeUrl;

  final List<String> tags;
  final List<MealIngredientEntity> ingredients;

  const MealDetailsEntity({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category = '',
    this.area = '',
    this.instructions = '',
    this.youtubeUrl,
    this.tags = const [],
    this.ingredients = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    thumbnail,
    category,
    area,
    instructions,
    youtubeUrl,
    tags,
    ingredients,
  ];
}
