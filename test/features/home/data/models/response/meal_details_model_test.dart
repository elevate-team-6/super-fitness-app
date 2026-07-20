import 'package:flutter_test/flutter_test.dart';
import 'package:super_fitness/features/home/data/models/response/meal_details_model.dart';

void main() {
  /// Trimmed-down copy of the real `lookup.php?i=52959` payload — the shape
  /// the parsing has to survive, blank trailing slots and all.
  Map<String, dynamic> payload({
    String? youtube = 'https://www.youtube.com/watch?v=xvPR2Tfw5k0',
    String? tags = 'Paleo,Keto,HighFat',
    Map<String, dynamic> overrides = const {},
  }) => {
    'idMeal': '52959',
    'strMeal': 'Baked salmon with fennel & tomatoes',
    'strCategory': 'Seafood',
    'strArea': 'British',
    'strInstructions': 'Heat oven to 180C.',
    'strMealThumb': 'https://themealdb.com/salmon.jpg',
    'strTags': tags,
    'strYoutube': youtube,
    'strIngredient1': 'Fennel',
    'strIngredient2': 'Parsley',
    'strIngredient3': 'Salmon',
    'strMeasure1': '2 medium',
    'strMeasure2': '2 tbs chopped',
    'strMeasure3': '350g',
    // Slots 4..20 come back as empty strings, not as missing keys.
    for (var slot = 4; slot <= 20; slot++) 'strIngredient$slot': '',
    for (var slot = 4; slot <= 20; slot++) 'strMeasure$slot': '',
    ...overrides,
  };

  group('MealDetailsModel ingredients', () {
    test('flattens the numbered slots into a list, dropping the blanks', () {
      final meal = MealDetailsModel.fromJson(payload()).toEntity();

      expect(meal.ingredients, hasLength(3));
      expect(meal.ingredients.first.name, 'Fennel');
      expect(meal.ingredients.first.measure, '2 medium');
      expect(meal.ingredients.last.name, 'Salmon');
      expect(meal.ingredients.last.measure, '350g');
    });

    test('keeps an ingredient that has no measure', () {
      final meal = MealDetailsModel.fromJson(
        payload(overrides: {'strMeasure3': ''}),
      ).toEntity();

      expect(meal.ingredients, hasLength(3));
      expect(meal.ingredients.last.name, 'Salmon');
      expect(meal.ingredients.last.measure, isEmpty);
    });

    // The API pads several recipes with whitespace-only slots, which would
    // otherwise render as blank rows in the list.
    test('drops slots that hold only whitespace', () {
      final meal = MealDetailsModel.fromJson(
        payload(overrides: {'strIngredient2': '   '}),
      ).toEntity();

      expect(meal.ingredients.map((i) => i.name), ['Fennel', 'Salmon']);
    });

    test('handles a recipe with no ingredients at all', () {
      final meal = MealDetailsModel.fromJson(
        payload(
          overrides: {
            for (var slot = 1; slot <= 20; slot++) 'strIngredient$slot': '',
          },
        ),
      ).toEntity();

      expect(meal.ingredients, isEmpty);
    });
  });

  group('MealDetailsModel tags', () {
    test('splits the comma-joined tag string', () {
      final meal = MealDetailsModel.fromJson(payload()).toEntity();

      expect(meal.tags, ['Paleo', 'Keto', 'HighFat']);
    });

    test('yields an empty list when tags are null or blank', () {
      expect(MealDetailsModel.fromJson(payload(tags: null)).toEntity().tags,
          isEmpty);
      expect(
          MealDetailsModel.fromJson(payload(tags: '')).toEntity().tags, isEmpty);
    });
  });

  group('MealDetailsModel youtube', () {
    test('passes a real link through', () {
      final meal = MealDetailsModel.fromJson(payload()).toEntity();

      expect(meal.youtubeUrl, 'https://www.youtube.com/watch?v=xvPR2Tfw5k0');
    });

    // Normalized at the model boundary so the UI has a single null check
    // rather than also testing for empty strings.
    test('normalizes a missing or blank link to null', () {
      expect(
        MealDetailsModel.fromJson(payload(youtube: null)).toEntity().youtubeUrl,
        isNull,
      );
      expect(
        MealDetailsModel.fromJson(payload(youtube: '  ')).toEntity().youtubeUrl,
        isNull,
      );
    });
  });

  test('maps the scalar fields onto the entity', () {
    final meal = MealDetailsModel.fromJson(payload()).toEntity();

    expect(meal.id, '52959');
    expect(meal.name, 'Baked salmon with fennel & tomatoes');
    expect(meal.category, 'Seafood');
    expect(meal.area, 'British');
    expect(meal.instructions, 'Heat oven to 180C.');
    expect(meal.thumbnail, 'https://themealdb.com/salmon.jpg');
  });

  test('falls back to empty strings when the record is mostly null', () {
    final meal = MealDetailsModel.fromJson(const {'idMeal': '1'}).toEntity();

    expect(meal.id, '1');
    expect(meal.name, isEmpty);
    expect(meal.instructions, isEmpty);
    expect(meal.ingredients, isEmpty);
    expect(meal.youtubeUrl, isNull);
  });
}
