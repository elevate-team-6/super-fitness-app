import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';

abstract class DetailsFoodPlaceholders {
  static const skeleton = DetailsFoodEntity(
    id: '',
    name: '',
    thumbnail: '',
    category: 'Category',
    area: 'Area',
    instructions:
        'Loading the recipe steps for this meal, which usually run to a '
        'few sentences across a couple of paragraphs.',
    ingredients: [
      MealIngredientEntity(name: 'Ingredient', measure: '100g'),
      MealIngredientEntity(name: 'Ingredient', measure: '2 tbs'),
      MealIngredientEntity(name: 'Ingredient', measure: '1 tsp'),
    ],
  );
}
