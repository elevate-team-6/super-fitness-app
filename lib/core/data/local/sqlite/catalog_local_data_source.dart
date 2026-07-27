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

  bool get _isArabic => Intl.defaultLocale == CatalogDbConstants.localeAr;
  String get _nameCol => _isArabic
      ? CatalogDbConstants.columnNameAr
      : CatalogDbConstants.columnName;

  // --- Exercises (Home) ---

  Future<List<home_exercise.ExerciseModel>> getRandomExercises({
    String? primeMoverMuscleId,
    String? difficultyLevelId,
    int? limit,
  }) async {
    final nameCol = _nameCol;

    String query =
        '''
      SELECT 
        e.*, 
        e.$nameCol as ${CatalogDbConstants.aliasExerciseName},
        l.$nameCol as ${CatalogDbConstants.aliasDifficultyLevel},
        mg.$nameCol as ${CatalogDbConstants.aliasTargetMuscleGroup},
        m.$nameCol as ${CatalogDbConstants.aliasPrimeMoverMuscle}
      FROM ${CatalogDbConstants.tableExercise} e
      LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscle} m ON e.${CatalogDbConstants.columnPrimeMoverId} = m.${CatalogDbConstants.columnId}
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

  // --- Shared Metadata ---

  Future<List<MuscleModel>> getMuscleGroups() async {
    final nameCol = _nameCol;

    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, $nameCol as ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableMuscleGroup}',
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
    final nameCol = _nameCol;

    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, $nameCol as ${CatalogDbConstants.columnName}, ${CatalogDbConstants.columnImage} FROM ${CatalogDbConstants.tableMuscle} ORDER BY RANDOM() LIMIT 10',
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
    final nameCol = _nameCol;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, $nameCol as ${CatalogDbConstants.columnName}, ${CatalogDbConstants.columnImage} FROM ${CatalogDbConstants.tableMuscle} WHERE ${CatalogDbConstants.columnMuscleGroupId} = ?',
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
    final nameCol = _nameCol;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, $nameCol as ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableDifficultyLevel} ORDER BY ${CatalogDbConstants.columnRank}',
    );
    return results.map((e) => LevelModel.fromSqlite(e)).toList();
  }

  // --- Meals ---

  Future<List<MealCategoryModel>> getMealsCategories() async {
    final nameCol = _nameCol;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId} as ${CatalogDbConstants.aliasIdCategory}, $nameCol as ${CatalogDbConstants.columnStrCategory}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName} FROM ${CatalogDbConstants.tableMealCategory}',
    );
    return results.map((e) {
      final map = Map<String, dynamic>.from(e);
      map[CatalogDbConstants.columnStrMealThumb] =
          'https://www.themealdb.com/images/category/${e[CatalogDbConstants.aliasEnglishName]}.png';
      return MealCategoryModel.fromSqlite(map);
    }).toList();
  }

  Future<List<MealModel>> getMealsByCategory(String category) async {
    final nameCol = _isArabic
        ? CatalogDbConstants.columnNameAr
        : CatalogDbConstants.columnName;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.columnIdMeal}, 
          m.$nameCol as ${CatalogDbConstants.columnStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.columnStrMealThumb},
          a.$nameCol as ${CatalogDbConstants.columnStrArea}
        FROM ${CatalogDbConstants.tableMeal} m
        LEFT JOIN ${CatalogDbConstants.tableMealCategory} c ON m.${CatalogDbConstants.columnCategoryId} = c.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMealArea} a ON m.${CatalogDbConstants.columnAreaId} = a.${CatalogDbConstants.columnId}
        WHERE c.${CatalogDbConstants.columnName} = ? OR c.${CatalogDbConstants.columnNameAr} = ?
      ''',
      arguments: [category, category],
    );
    return results.map((e) => MealModel.fromSqlite(e)).toList();
  }

  Future<DetailsFoodModel?> getDetailsFood(String id) async {
    final nameCol = _nameCol;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.columnIdMeal}, 
          m.$nameCol as ${CatalogDbConstants.columnStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.columnStrMealThumb},
          c.$nameCol as ${CatalogDbConstants.columnStrCategory},
          a.$nameCol as ${CatalogDbConstants.columnStrArea},
          m.${CatalogDbConstants.columnStrInstructions} as ${CatalogDbConstants.columnStrInstructions},
          m.${CatalogDbConstants.columnStrYoutube} as ${CatalogDbConstants.columnStrYoutube}
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
        SELECT i.$nameCol as ${CatalogDbConstants.columnName}, mi.${CatalogDbConstants.columnQty} || ' ' || mi.${CatalogDbConstants.columnUnit} as ${CatalogDbConstants.aliasMeasure}
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
    final nameCol = _nameCol;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          '''
        SELECT DISTINCT l.${CatalogDbConstants.columnId}, l.$nameCol as ${CatalogDbConstants.columnName}
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
    final nameCol = _nameCol;
    final results = await _sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          '''
        SELECT 
          e.*, 
          e.$nameCol as ${CatalogDbConstants.aliasExerciseName},
          l.$nameCol as ${CatalogDbConstants.aliasDifficultyLevel},
          mg.$nameCol as ${CatalogDbConstants.aliasTargetMuscleGroup},
          m.$nameCol as ${CatalogDbConstants.aliasPrimeMoverMuscle},
          eq.$nameCol as ${CatalogDbConstants.aliasPrimaryEquipment},
          br.${CatalogDbConstants.columnName} as ${CatalogDbConstants.columnBodyRegion},
          e.${CatalogDbConstants.columnDemoUrl} as ${CatalogDbConstants.aliasShortYoutubeLink},
          e.${CatalogDbConstants.columnExplainUrl} as ${CatalogDbConstants.aliasInDepthYoutubeLink}
        FROM ${CatalogDbConstants.tableExercise} e
        LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableMuscle} m ON e.${CatalogDbConstants.columnPrimeMoverId} = m.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableEquipment} eq ON e.${CatalogDbConstants.columnPrimaryEquipmentId} = eq.${CatalogDbConstants.columnId}
        LEFT JOIN ${CatalogDbConstants.tableBodyRegion} br ON e.${CatalogDbConstants.columnBodyRegionId} = br.${CatalogDbConstants.columnId}
        WHERE e.${CatalogDbConstants.columnPrimeMoverId} = ? AND e.${CatalogDbConstants.columnDifficultyId} = ?
      ''',
      arguments: [primeMoverMuscleId, difficultyLevelId],
    );
    return results
        .map((e) => workout_exercise.ExerciseModel.fromSqlite(e))
        .toList();
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
