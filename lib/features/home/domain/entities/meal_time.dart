import 'package:super_fitness/core/utils/app_strings.dart';

/// The meal times shown in the "Recommendation For You" section (SF-19).
///
/// TheMealDB has no `Lunch` or `Dinner` category — it only exposes ingredient
/// based ones (Beef, Chicken, Pasta, ...) plus a single `Breakfast`. So each
/// meal time maps to the categories that best represent it, and the repo merges
/// their results. Swap [categories] here if the backend ever returns a real
/// meal type.
enum MealTime {
  breakfast(AppStrings.breakfast, [
    'Breakfast',
  ], '$_categoryImages/breakfast.png'),
  lunch(AppStrings.lunch, [
    'Chicken',
    'Pasta',
    'Seafood',
  ], '$_categoryImages/chicken.png'),
  dinner(AppStrings.dinner, [
    'Beef',
    'Lamb',
    'Pork',
  ], '$_categoryImages/beef.png');

  const MealTime(this.labelKey, this.categories, this.thumbnail);

  /// Localization key, resolved with `.tr()` at the widget layer.
  final String labelKey;

  /// TheMealDB categories this meal time is composed of.
  final List<String> categories;

  /// Cover image for the Home cards. Uses TheMealDB's own category artwork so
  /// the feature ships without waiting on design assets.
  final String thumbnail;
}

const String _categoryImages = 'https://www.themealdb.com/images/category';
