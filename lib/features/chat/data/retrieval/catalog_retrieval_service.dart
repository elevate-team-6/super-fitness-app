import 'package:injectable/injectable.dart';
import '../../../../core/data/local/sqlite/catalog_local_data_source.dart';
import 'equipment_categories.dart';

@lazySingleton
class CatalogRetrievalService {
  final CatalogLocalDataSource _catalogDataSource;

  CatalogRetrievalService(this._catalogDataSource);

  /// Searches exercises with a relaxation ladder as per section 3.6.
  /// Relaxation order: movement_pattern -> mechanics -> body_region -> max_difficulty -> equipment -> muscle_group
  Future<List<Map<String, dynamic>>> searchExercisesByFilters({
    String? muscleGroup,
    String? equipment,
    int? maxDifficulty,
    String? movementPattern,
    String? bodyRegion,
    String? mechanics,
    String? excludeEquipment,
    int limit = 6,
  }) async {
    final bool shouldDiversify = equipment == null;
    final int effectiveLimit = shouldDiversify ? 20 : limit;

    final ladder = [
      {'movementPattern': movementPattern},
      {'mechanics': mechanics},
      {'bodyRegion': bodyRegion},
      {'maxDifficulty': maxDifficulty},
      {'equipment': equipment},
      {'muscleGroup': muscleGroup},
    ];

    // Filter out null values to know which filters were actually provided
    final activeFilters = Map<String, dynamic>.from({
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'maxDifficulty': maxDifficulty,
      'movementPattern': movementPattern,
      'bodyRegion': bodyRegion,
      'mechanics': mechanics,
      'excludeEquipment': excludeEquipment,
    })..removeWhere((key, value) => value == null);

    // Initial attempt with all filters
    var results = await _catalogDataSource.searchExercisesRaw(
      muscleGroup: activeFilters['muscleGroup'],
      equipment: activeFilters['equipment'],
      maxDifficulty: activeFilters['maxDifficulty'],
      movementPattern: activeFilters['movementPattern'],
      bodyRegion: activeFilters['bodyRegion'],
      mechanics: activeFilters['mechanics'],
      excludeEquipment: activeFilters['excludeEquipment'],
      limit: effectiveLimit,
    );

    if (results.isEmpty) {
      // Relaxation Ladder: iteratively drop filters from the ladder if they were provided
      final currentFilters = Map<String, dynamic>.from(activeFilters);
      for (final step in ladder) {
        final key = step.keys.first;
        if (currentFilters.containsKey(key)) {
          currentFilters.remove(key);

          results = await _catalogDataSource.searchExercisesRaw(
            muscleGroup: currentFilters['muscleGroup'],
            equipment: currentFilters['equipment'],
            maxDifficulty: currentFilters['maxDifficulty'],
            movementPattern: currentFilters['movementPattern'],
            bodyRegion: currentFilters['bodyRegion'],
            mechanics: currentFilters['mechanics'],
            excludeEquipment: currentFilters['excludeEquipment'],
            limit: effectiveLimit,
          );

          if (results.isNotEmpty) break;
        }
      }
    }

    if (shouldDiversify && results.isNotEmpty) {
      return _diversifyResults(results, limit);
    }

    return results.length > limit ? results.sublist(0, limit) : results;
  }

  List<Map<String, dynamic>> _diversifyResults(
    List<Map<String, dynamic>> results,
    int targetLimit,
  ) {
    final List<Map<String, dynamic>> diversified = [];
    final Set<String> selectedIds = {};

    final bodyweightItems = results
        .where(
          (e) => EquipmentCategories.categories['bodyweight']!.contains(
            e['equipment'],
          ),
        )
        .toList();
    final homeItems = results
        .where(
          (e) =>
              EquipmentCategories.categories['home']!.contains(e['equipment']),
        )
        .toList();
    final gymItems = results
        .where(
          (e) =>
              EquipmentCategories.categories['gym']!.contains(e['equipment']),
        )
        .toList();

    // 1. Pick 2 from each category
    void pickFrom(List<Map<String, dynamic>> source, int count) {
      int picked = 0;
      for (var item in source) {
        if (picked >= count) break;
        if (!selectedIds.contains(item['id'].toString())) {
          diversified.add(item);
          selectedIds.add(item['id'].toString());
          picked++;
        }
      }
    }

    pickFrom(bodyweightItems, 2);
    pickFrom(homeItems, 2);
    pickFrom(gymItems, 2);

    // 2. Fill the rest with any remaining results
    for (var item in results) {
      if (diversified.length >= targetLimit) break;
      if (!selectedIds.contains(item['id'].toString())) {
        diversified.add(item);
        selectedIds.add(item['id'].toString());
      }
    }

    return diversified;
  }

  Future<List<Map<String, dynamic>>> searchMealsByFilters({
    String? category,
    String? area,
    double? minProtein,
    double? maxKcal,
    bool? vegetarian,
    bool? vegan,
    bool? glutenFree,
    String? excludeIngredient,
    int limit = 6,
  }) async {
    return _catalogDataSource.searchMealsRaw(
      category: category,
      area: area,
      minProtein: minProtein,
      maxKcal: maxKcal,
      vegetarian: vegetarian,
      vegan: vegan,
      glutenFree: glutenFree,
      excludeIngredient: excludeIngredient,
      limit: limit,
    );
  }

  /// Serializes exercise results to pipe-delimited format (Section 3.7).
  String serializeExerciseCards(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) return "NO_MATCHES_FOUND";

    final buffer = StringBuffer();
    buffer.writeln("CANDIDATE EXERCISES:");
    for (final e in exercises) {
      final id = e['id'];
      final name = e['name'];
      final muscle = e['muscle'] ?? 'N/A';
      final equip = e['equipment'] ?? 'N/A';
      final diff = e['difficulty'] ?? 'N/A';
      buffer.writeln("$id | $name | $muscle | $equip | $diff");
    }
    return buffer.toString().trim();
  }

  /// Serializes meal results to pipe-delimited format (Section 3.7).
  String serializeMealCards(List<Map<String, dynamic>> meals) {
    if (meals.isEmpty) return "NO_MATCHES_FOUND";

    final buffer = StringBuffer();
    buffer.writeln("CANDIDATE MEALS:");
    for (final m in meals) {
      final id = m['id'];
      final name = m['name'];
      final category = m['category'] ?? 'N/A';
      final area = m['area'] ?? 'N/A';
      final kcal = m['kcal'] ?? 'N/A';
      final protein = m['protein'] ?? 'N/A';
      buffer.writeln(
        "$id | $name | $category | $area | ${kcal}kcal | ${protein}g protein",
      );
    }
    return buffer.toString().trim();
  }
}
