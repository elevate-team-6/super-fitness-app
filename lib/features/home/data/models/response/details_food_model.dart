import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';

class DetailsFoodModel {
  final String? idMeal;
  final String? strMeal;
  final String? strMealThumb;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strTags;
  final String? strYoutube;

  /// Already flattened out of the numbered `strIngredientN` / `strMeasureN`
  /// keys — blank slots are dropped during parsing.
  final List<MealIngredientEntity> ingredients;

  const DetailsFoodModel({
    this.idMeal,
    this.strMeal,
    this.strMealThumb,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strTags,
    this.strYoutube,
    this.ingredients = const [],
  });

  factory DetailsFoodModel.fromJson(Map<String, dynamic> json) =>
      DetailsFoodModel(
        idMeal: json[ApiParameters.idMeal] as String?,
        strMeal: json[ApiParameters.strMeal] as String?,
        strMealThumb: json[ApiParameters.strMealThumb] as String?,
        strCategory: json[ApiParameters.strCategory] as String?,
        strArea: json[ApiParameters.strArea] as String?,
        strInstructions: json[ApiParameters.strInstructions] as String?,
        strTags: json[ApiParameters.strTags] as String?,
        strYoutube: json[ApiParameters.strYoutube] as String?,
        ingredients: _parseIngredients(json),
      );

  /// Walks the 20 fixed slots and keeps the ones with an ingredient name. A
  /// missing measure is fine (`to serve`-style rows sometimes have none), but a
  /// nameless row has nothing to show, so it's skipped.
  static List<MealIngredientEntity> _parseIngredients(
    Map<String, dynamic> json,
  ) {
    final ingredients = <MealIngredientEntity>[];

    for (var slot = 1; slot <= ApiParameters.mealIngredientSlots; slot++) {
      final name =
          (json['${ApiParameters.strIngredientPrefix}$slot'] as String?)
              ?.trim() ??
          '';
      if (name.isEmpty) continue;

      final measure =
          (json['${ApiParameters.strMeasurePrefix}$slot'] as String?)?.trim() ??
          '';

      ingredients.add(MealIngredientEntity(name: name, measure: measure));
    }

    return ingredients;
  }

  DetailsFoodEntity toEntity() => DetailsFoodEntity(
    id: idMeal ?? '',
    name: strMeal ?? '',
    thumbnail: strMealThumb ?? '',
    category: strCategory ?? '',
    area: strArea ?? '',
    instructions: strInstructions ?? '',
    // Normalized to null so the UI has a single "no video" check instead of
    // also testing for empty strings, which the API does return.
    youtubeUrl: (strYoutube?.trim().isNotEmpty ?? false) ? strYoutube : null,
    tags: _parseTags(),
    ingredients: ingredients,
  );

  /// `strTags` is a comma-joined string (`"Paleo,Keto,Baking"`) or null.
  List<String> _parseTags() {
    final raw = strTags?.trim();
    if (raw == null || raw.isEmpty) return const [];

    return raw
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
