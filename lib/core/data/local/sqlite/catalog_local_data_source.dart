import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../features/home/data/models/response/details_food_model.dart';
import '../../../../features/home/data/models/response/exercise_response.dart'
    as home_exercise;
import '../../../../features/home/data/models/response/level_response.dart';
import '../../../../features/home/data/models/response/meal_category_response.dart';
import '../../../../features/home/data/models/response/meal_model.dart';
import '../../../../features/home/data/models/response/muscle_response.dart';
import '../../../../features/workouts/data/models/response/exercise_model.dart'
    as workout_exercise;
import 'catalog_db_constants.dart';
import 'sqlite_helper.dart';

@lazySingleton
class CatalogLocalDataSource {
  final SqliteHelper _sqliteHelper;

  CatalogLocalDataSource(this._sqliteHelper);

  bool get _isArabic =>
      Intl.getCurrentLocale().startsWith(CatalogDbConstants.localeAr);

  String _getNameCol([String? alias]) {
    const nameAr = CatalogDbConstants.columnNameAr;
    const nameEn = CatalogDbConstants.columnName;
    final prefix = alias != null ? '$alias.' : '';

    if (_isArabic) {
      // Fallback to English 'name' if 'name_ar' is null or empty
      return "COALESCE(NULLIF($prefix$nameAr, ''), $prefix$nameEn)";
    }
    return '$prefix$nameEn';
  }

  // --- Exercises (Home) ---

  Future<List<home_exercise.ExerciseModel>> getRandomExercises({
    String? primeMoverMuscleId,
    String? difficultyLevelId,
    int? limit,
  }) async {
    String query =
        '''
      SELECT 
        e.*, 
        ${_getNameCol('e')} as ${CatalogDbConstants.aliasExerciseName},
        ${_getNameCol('l')} as ${CatalogDbConstants.aliasDifficultyLevel},
        ${_getNameCol('mg')} as ${CatalogDbConstants.aliasTargetMuscleGroup},
        ${_getNameCol('m')} as ${CatalogDbConstants.aliasPrimeMoverMuscle},
        ${_getNameCol('eq')} as ${CatalogDbConstants.aliasPrimaryEquipment},
        ${_getNameCol('seq')} as ${CatalogDbConstants.columnSecondaryEquipment}
      FROM ${CatalogDbConstants.tableExercise} e
      LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscle} m ON e.${CatalogDbConstants.columnPrimeMoverId} = m.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableEquipment} eq ON e.${CatalogDbConstants.columnPrimaryEquipmentId} = eq.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableEquipment} seq ON e.${CatalogDbConstants.columnSecondaryEquipmentId} = seq.${CatalogDbConstants.columnId}
    ''';

    List<dynamic> whereArgs = [];
    List<String> conditions = [];

    if (primeMoverMuscleId != null) {
      conditions.add('e.${CatalogDbConstants.columnPrimeMoverId} = ?');
      whereArgs.add(primeMoverMuscleId);
    }
    if (difficultyLevelId != null) {
      conditions.add('e.${CatalogDbConstants.columnDifficultyId} = ?');
      whereArgs.add(difficultyLevelId);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY RANDOM() LIMIT ${limit ?? 10}';

    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql: query,
      arguments: whereArgs,
    );
    return results
        .map((e) => home_exercise.ExerciseModel.fromSqlite(e))
        .toList();
  }

  Future<List<home_exercise.ExerciseModel>> getExercisesByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(', ');
    final query =
        '''
      SELECT 
        e.*, 
        ${_getNameCol('e')} as ${CatalogDbConstants.aliasExerciseName},
        ${_getNameCol('l')} as ${CatalogDbConstants.aliasDifficultyLevel},
        ${_getNameCol('mg')} as ${CatalogDbConstants.aliasTargetMuscleGroup},
        ${_getNameCol('m')} as ${CatalogDbConstants.aliasPrimeMoverMuscle}
      FROM ${CatalogDbConstants.tableExercise} e
      LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscle} m ON e.${CatalogDbConstants.columnPrimeMoverId} = m.${CatalogDbConstants.columnId}
      WHERE e.${CatalogDbConstants.columnId} IN ($placeholders)
    ''';

    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql: query,
      arguments: ids,
    );

    return results
        .map((e) => home_exercise.ExerciseModel.fromSqlite(e))
        .toList();
  }

  // --- Shared Metadata ---

  Future<List<MuscleModel>> getMuscleGroups() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, ${_getNameCol()} as ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableMuscleGroup}',
    );

    return results.map((e) {
      final map = Map<String, dynamic>.from(e);
      map[CatalogDbConstants.columnImage] = _getMuscleImageUrl(
        e[CatalogDbConstants.aliasEnglishName],
      );
      return MuscleModel.fromSqlite(map);
    }).toList();
  }

  Future<List<MuscleModel>> getRandomMuscles() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, ${_getNameCol()} as ${CatalogDbConstants.columnName}, ${CatalogDbConstants.columnImage} FROM ${CatalogDbConstants.tableMuscle} ORDER BY RANDOM() LIMIT 10',
    );

    return results.map((e) {
      final map = Map<String, dynamic>.from(e);
      map[CatalogDbConstants.columnImage] = _getMuscleImageUrl(
        e[CatalogDbConstants.aliasEnglishName],
      );
      return MuscleModel.fromSqlite(map);
    }).toList();
  }

  Future<List<MuscleModel>> getMusclesByGroupId(String id) async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, ${_getNameCol()} as ${CatalogDbConstants.columnName}, ${CatalogDbConstants.columnImage} FROM ${CatalogDbConstants.tableMuscle} WHERE ${CatalogDbConstants.columnMuscleGroupId} = ?',
      arguments: [id],
    );

    return results.map((e) {
      final map = Map<String, dynamic>.from(e);
      map[CatalogDbConstants.columnImage] = _getMuscleImageUrl(
        e[CatalogDbConstants.aliasEnglishName],
      );
      return MuscleModel.fromSqlite(map);
    }).toList();
  }

  Future<List<LevelModel>> getLevels() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${_getNameCol()} as ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableDifficultyLevel} ORDER BY ${CatalogDbConstants.columnRank}',
    );
    return results.map((e) => LevelModel.fromSqlite(e)).toList();
  }

  // --- Meals ---

  Future<List<MealCategoryModel>> getMealsCategories() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId} as ${CatalogDbConstants.aliasIdCategory}, ${_getNameCol()} as ${CatalogDbConstants.keyStrCategory}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName} FROM ${CatalogDbConstants.tableMealCategory}',
    );
    return results.map((e) {
      final map = Map<String, dynamic>.from(e);
      map[CatalogDbConstants.keyStrMealThumb] =
          'https://www.themealdb.com/images/category/${e[CatalogDbConstants.aliasEnglishName]}.png';
      return MealCategoryModel.fromSqlite(map);
    }).toList();
  }

  Future<List<MealModel>> getMealsByCategory(String category) async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.keyIdMeal}, 
          ${_getNameCol('m')} as ${CatalogDbConstants.keyStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.keyStrMealThumb},
          ${_getNameCol('a')} as ${CatalogDbConstants.keyStrArea}
        FROM ${CatalogDbConstants.tableMeal} m
        LEFT JOIN ${CatalogDbConstants.tableMealCategory} c ON m.${CatalogDbConstants.columnCategoryId} = c.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMealArea} a ON m.${CatalogDbConstants.columnAreaId} = a.${CatalogDbConstants.columnId}
        WHERE c.${CatalogDbConstants.columnName} = ? OR c.${CatalogDbConstants.columnNameAr} = ?
      ''',
      arguments: [category, category],
    );
    return results.map((e) => MealModel.fromSqlite(e)).toList();
  }

  Future<List<MealModel>> getMealsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(', ');
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.keyIdMeal}, 
          ${_getNameCol('m')} as ${CatalogDbConstants.keyStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.keyStrMealThumb},
          ${_getNameCol('a')} as ${CatalogDbConstants.keyStrArea}
        FROM ${CatalogDbConstants.tableMeal} m
        LEFT JOIN ${CatalogDbConstants.tableMealCategory} c ON m.${CatalogDbConstants.columnCategoryId} = c.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMealArea} a ON m.${CatalogDbConstants.columnAreaId} = a.${CatalogDbConstants.columnId}
        WHERE m.${CatalogDbConstants.columnId} IN ($placeholders)
      ''',
      arguments: ids,
    );
    return results.map((e) => MealModel.fromSqlite(e)).toList();
  }

  Future<DetailsFoodModel?> getDetailsFood(String id) async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.keyIdMeal}, 
          ${_getNameCol('m')} as ${CatalogDbConstants.keyStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.keyStrMealThumb},
          ${_getNameCol('c')} as ${CatalogDbConstants.keyStrCategory},
          ${_getNameCol('a')} as ${CatalogDbConstants.keyStrArea},
          m.${CatalogDbConstants.columnInstructions} as ${CatalogDbConstants.keyStrInstructions},
          m.${CatalogDbConstants.columnYoutube} as ${CatalogDbConstants.keyStrYoutube}
        FROM ${CatalogDbConstants.tableMeal} m
        LEFT JOIN ${CatalogDbConstants.tableMealCategory} c ON m.${CatalogDbConstants.columnCategoryId} = c.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMealArea} a ON m.${CatalogDbConstants.columnAreaId} = a.${CatalogDbConstants.columnId}
        WHERE m.${CatalogDbConstants.columnId} = ?
      ''',
      arguments: [id],
    );
    if (results.isEmpty) return null;

    final mealMap = Map<String, dynamic>.from(results.first);
    final ingredients = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT ${_getNameCol('i')} as ${CatalogDbConstants.columnName}, mi.${CatalogDbConstants.columnQty} || ' ' || mi.${CatalogDbConstants.columnUnit} as ${CatalogDbConstants.aliasMeasure}
        FROM ${CatalogDbConstants.tableMealIngredient} mi
        JOIN ${CatalogDbConstants.tableIngredient} i ON mi.${CatalogDbConstants.columnIngredientId} = i.${CatalogDbConstants.columnId}
        WHERE mi.meal_id = ?
        ORDER BY mi.${CatalogDbConstants.columnPosition}
      ''',
      arguments: [id],
    );

    return DetailsFoodModel.fromSqlite(mealMap, ingredients: ingredients);
  }

  // --- Workout Feature Helpers ---

  Future<List<LevelModel>> getDifficultyLevelsByPrimeMover(
    String primeMoverMuscleId,
  ) async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          '''
        SELECT DISTINCT l.${CatalogDbConstants.columnId}, ${_getNameCol('l')} as ${CatalogDbConstants.columnName}
        FROM ${CatalogDbConstants.tableDifficultyLevel} l
        JOIN ${CatalogDbConstants.tableExercise} e ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
        WHERE e.${CatalogDbConstants.columnPrimeMoverId} = ?
        ORDER BY l.${CatalogDbConstants.columnRank}
      ''',
      arguments: [primeMoverMuscleId],
    );
    return results.map((e) => LevelModel.fromSqlite(e)).toList();
  }

  Future<List<workout_exercise.ExerciseModel>> getExercisesByMuscleDifficulty(
    String primeMoverMuscleId,
    String difficultyLevelId,
  ) async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          '''
        SELECT 
          e.*, 
          ${_getNameCol('e')} as ${CatalogDbConstants.aliasExerciseName},
          ${_getNameCol('l')} as ${CatalogDbConstants.aliasDifficultyLevel},
          ${_getNameCol('mg')} as ${CatalogDbConstants.aliasTargetMuscleGroup},
          ${_getNameCol('m')} as ${CatalogDbConstants.aliasPrimeMoverMuscle},
          ${_getNameCol('eq')} as ${CatalogDbConstants.aliasPrimaryEquipment},
          ${_getNameCol('seq')} as ${CatalogDbConstants.columnSecondaryEquipment},
          br.${CatalogDbConstants.columnName} as ${CatalogDbConstants.columnBodyRegionName},
          e.${CatalogDbConstants.columnDemoUrl} as ${CatalogDbConstants.aliasShortYoutubeLink},
          e.${CatalogDbConstants.columnExplainUrl} as ${CatalogDbConstants.aliasInDepthYoutubeLink}
        FROM ${CatalogDbConstants.tableExercise} e
        LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMuscle} m ON e.${CatalogDbConstants.columnPrimeMoverId} = m.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableEquipment} eq ON e.${CatalogDbConstants.columnPrimaryEquipmentId} = eq.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableEquipment} seq ON e.${CatalogDbConstants.columnSecondaryEquipmentId} = seq.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableBodyRegion} br ON e.${CatalogDbConstants.columnBodyRegionId} = br.${CatalogDbConstants.columnId}
        WHERE e.${CatalogDbConstants.columnPrimeMoverId} = ? AND e.${CatalogDbConstants.columnDifficultyId} = ?
      ''',
      arguments: [primeMoverMuscleId, difficultyLevelId],
    );
    return results
        .map((e) => workout_exercise.ExerciseModel.fromSqlite(e))
        .toList();
  }

  // --- Vocabulary Fetching for AI Coach ---

  Future<List<String>> getDistinctMuscleGroups() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          "SELECT DISTINCT ${_getNameCol()} FROM ${CatalogDbConstants.tableMuscleGroup} WHERE ${_getNameCol()} IS NOT NULL AND ${_getNameCol()} != '' ORDER BY ${_getNameCol()}",
    );
    return results.map((e) => e.values.first.toString()).toList();
  }

  Future<List<String>> getDistinctEquipment() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          "SELECT DISTINCT ${_getNameCol()} FROM ${CatalogDbConstants.tableEquipment} WHERE ${_getNameCol()} IS NOT NULL AND ${_getNameCol()} != '' ORDER BY ${_getNameCol()}",
    );
    return results.map((e) => e.values.first.toString()).toList();
  }

  Future<List<String>> getDistinctMovementPatterns() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          "SELECT DISTINCT ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableMovementPattern} WHERE ${CatalogDbConstants.columnName} IS NOT NULL AND ${CatalogDbConstants.columnName} != '' ORDER BY ${CatalogDbConstants.columnName}",
    );
    return results.map((e) => e.values.first.toString()).toList();
  }

  Future<Map<String, int>> getDifficultyLevelsMap() async {
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${_getNameCol()} as name, ${CatalogDbConstants.columnRank} as rank FROM ${CatalogDbConstants.tableDifficultyLevel} ORDER BY ${CatalogDbConstants.columnRank}',
    );
    final Map<String, int> levelsMap = {};
    for (final row in results) {
      levelsMap[row['name'].toString()] = row['rank'] as int;
    }
    return levelsMap;
  }

  Future<String?> getDatabaseVersion() async {
    try {
      final results = await _sqliteHelper.rawQuery(
        dbName: CatalogDbConstants.exercisesDb,
        sql:
            "SELECT value FROM ${CatalogDbConstants.tableMeta} WHERE key = 'data_version'",
      );
      if (results.isNotEmpty) {
        return results.first['value']?.toString();
      }
    } catch (_) {}
    return null;
  }

  // --- Filtered Search for AI Retrieval ---

  Future<List<Map<String, dynamic>>> searchExercisesRaw({
    String? muscleGroup,
    String? equipment,
    int? maxDifficulty,
    String? movementPattern,
    String? bodyRegion,
    String? mechanics,
    String? excludeEquipment,
    int limit = 6,
  }) async {
    String query =
        '''
      SELECT 
        e.id, 
        ${_getNameCol('e')} as name,
        ${_getNameCol('mg')} as muscle,
        ${_getNameCol('eq')} as equipment,
        ${_getNameCol('l')} as difficulty
      FROM ${CatalogDbConstants.tableExercise} e
      LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableEquipment} eq ON e.${CatalogDbConstants.columnPrimaryEquipmentId} = eq.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableBodyRegion} br ON e.${CatalogDbConstants.columnBodyRegionId} = br.${CatalogDbConstants.columnId}
    ''';

    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (muscleGroup != null) {
      conditions.add('${_getNameCol('mg')} = ?');
      args.add(muscleGroup);
    }
    if (equipment != null) {
      conditions.add('${_getNameCol('eq')} = ?');
      args.add(equipment);
    }
    if (maxDifficulty != null) {
      conditions.add('l.${CatalogDbConstants.columnRank} <= ?');
      args.add(maxDifficulty);
    }
    if (bodyRegion != null) {
      conditions.add('br.${CatalogDbConstants.columnName} = ?');
      args.add(bodyRegion);
    }
    if (mechanics != null) {
      conditions.add('e.${CatalogDbConstants.columnMechanics} = ?');
      args.add(mechanics);
    }
    if (excludeEquipment != null) {
      conditions.add('${_getNameCol('eq')} != ?');
      args.add(excludeEquipment);
    }
    if (movementPattern != null) {
      query +=
          ' JOIN ${CatalogDbConstants.tableExerciseMovementPattern} emp ON e.id = emp.exercise_id';
      query +=
          ' JOIN ${CatalogDbConstants.tableMovementPattern} mp ON emp.pattern_id = mp.id';
      conditions.add('mp.${CatalogDbConstants.columnName} = ?');
      args.add(movementPattern);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY RANDOM() LIMIT ?';
    args.add(limit);

    return await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql: query,
      arguments: args,
    );
  }

  Future<List<Map<String, dynamic>>> searchMealsRaw({
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
    String query =
        '''
      SELECT 
        m.id, 
        ${_getNameCol('m')} as name,
        ${_getNameCol('c')} as category,
        ${_getNameCol('a')} as area,
        m.kcal,
        m.protein_g as protein
      FROM ${CatalogDbConstants.tableMeal} m
      LEFT JOIN ${CatalogDbConstants.tableMealCategory} c ON m.category_id = c.id
      LEFT JOIN ${CatalogDbConstants.tableMealArea} a ON m.area_id = a.id
    ''';

    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (category != null) {
      conditions.add('${_getNameCol('c')} = ?');
      args.add(category);
    }
    if (area != null) {
      conditions.add('${_getNameCol('a')} = ?');
      args.add(area);
    }
    if (minProtein != null) {
      conditions.add('m.protein_g >= ?');
      args.add(minProtein);
    }
    if (maxKcal != null) {
      conditions.add('m.kcal <= ?');
      args.add(maxKcal);
    }
    if (vegetarian == true) {
      conditions.add('m.vegetarian = 1');
    }
    if (vegan == true) {
      conditions.add('m.vegan = 1');
    }
    if (glutenFree == true) {
      conditions.add('m.contains_gluten = 0');
    }
    if (excludeIngredient != null) {
      // Simple check in instructions or we need a proper join.
      // For now, let's use a subquery if we had an ingredient search,
      // but the prompt says 'exclude_ingredient'.
      query +=
          ' LEFT JOIN ${CatalogDbConstants.tableMealIngredient} mi ON m.id = mi.meal_id';
      query +=
          ' LEFT JOIN ${CatalogDbConstants.tableIngredient} i ON mi.ingredient_id = i.id';
      conditions.add(
        'm.id NOT IN (SELECT meal_id FROM ${CatalogDbConstants.tableMealIngredient} mi2 JOIN ${CatalogDbConstants.tableIngredient} i2 ON mi2.ingredient_id = i2.id WHERE ${_getNameCol('i2')} = ?)',
      );
      args.add(excludeIngredient);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' GROUP BY m.id ORDER BY RANDOM() LIMIT ?';
    args.add(limit);

    return await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql: query,
      arguments: args,
    );
  }

  String? _getMuscleImageUrl(dynamic name) {
    if (name == null) return null;
    final muscleName = name.toString().trim();

    const imageMap = {
      "Posterior Deltoids": "https://iili.io/33p7ene.png",
      "Anterior Deltoids": "https://iili.io/33p7ene.png",
      "Obliques": "https://iili.io/33p7mSR.png",
      "Pectoralis Major": "https://iili.io/33p7y9p.png",
      "Adductor Magnus": "https://iili.io/33p7kMu.png",
      "Latissimus Dorsi": "https://iili.io/33p7bcv.png",
      "Gluteus Medius": "https://iili.io/33p7it1.png",
      "Triceps Brachii": "https://iili.io/33pY2oX.png",
      "Biceps Brachii": "https://iili.io/33p7v6b.png",
      "Biceps Femoris": "https://iili.io/33p7ww7.png",
      "Brachioradialis": "https://iili.io/33p7Ucx.png",
      "Erector Spinae": "https://iili.io/33p7ZPa.png",
      "Tibialis Anterior": "https://iili.io/33pY3Vn.png",
      "Iliopsoas":
          "https://www.lower-back-pain-answers.com/images/Iliopsoas.jpg",
      "Subscapularis":
          "https://images.squarespace-cdn.com/content/v1/58e3a13a4402430a5d1e1689/1509640719573-YPLWDSI1C6BIPKDJZHFM/rotator-cuff.jpg",
      "Gluteus Maximus": "https://iili.io/33p7QMg.png",
      "Rectus Abdominis": "https://iili.io/33pYHNI.png",
    };

    return imageMap[muscleName];
  }
}
