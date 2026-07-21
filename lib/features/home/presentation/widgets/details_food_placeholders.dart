import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_nutrition_bar.dart';

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

  static const nutrition = [
    MealNutritionStat(value: '100 K', labelKey: AppStrings.energy),
    MealNutritionStat(value: '15 g', labelKey: AppStrings.protein),
    MealNutritionStat(value: '58 g', labelKey: AppStrings.carbs),
    MealNutritionStat(value: '20 g', labelKey: AppStrings.fat),
  ];
}
