import 'package:super_fitness/features/home/data/models/response/level_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import '../catalog_db_constants.dart';
import '../sqlite_helper.dart';

mixin CommonCatalogMixin {
  SqliteHelper get sqliteHelper;
  String getNameCol([String? alias]);

  Future<List<MuscleModel>> getMuscleGroups() async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, ${getNameCol()} as ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableMuscleGroup}',
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
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, ${getNameCol()} as ${CatalogDbConstants.columnName}, ${CatalogDbConstants.columnImage} FROM ${CatalogDbConstants.tableMuscle} ORDER BY RANDOM() LIMIT 10',
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
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName}, ${getNameCol()} as ${CatalogDbConstants.columnName}, ${CatalogDbConstants.columnImage} FROM ${CatalogDbConstants.tableMuscle} WHERE ${CatalogDbConstants.columnMuscleGroupId} = ?',
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
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId}, ${getNameCol()} as ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableDifficultyLevel} ORDER BY ${CatalogDbConstants.columnRank}',
    );
    return results.map((e) => LevelModel.fromSqlite(e)).toList();
  }

  Future<List<String>> getDistinctMuscleGroups() async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          "SELECT DISTINCT ${getNameCol()} FROM ${CatalogDbConstants.tableMuscleGroup} WHERE ${getNameCol()} IS NOT NULL AND ${getNameCol()} != '' ORDER BY ${getNameCol()}",
    );
    return results.map((e) => e.values.first.toString()).toList();
  }

  Future<List<String>> getDistinctEquipment() async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          "SELECT DISTINCT ${getNameCol()} FROM ${CatalogDbConstants.tableEquipment} WHERE ${getNameCol()} IS NOT NULL AND ${getNameCol()} != '' ORDER BY ${getNameCol()}",
    );
    return results.map((e) => e.values.first.toString()).toList();
  }

  Future<List<String>> getDistinctMovementPatterns() async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          "SELECT DISTINCT ${CatalogDbConstants.columnName} FROM ${CatalogDbConstants.tableMovementPattern} WHERE ${CatalogDbConstants.columnName} IS NOT NULL AND ${CatalogDbConstants.columnName} != '' ORDER BY ${CatalogDbConstants.columnName}",
    );
    return results.map((e) => e.values.first.toString()).toList();
  }

  Future<Map<String, int>> getDifficultyLevelsMap() async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          'SELECT ${getNameCol()} as name, ${CatalogDbConstants.columnRank} as rank FROM ${CatalogDbConstants.tableDifficultyLevel} ORDER BY ${CatalogDbConstants.columnRank}',
    );
    final Map<String, int> levelsMap = {};
    for (final row in results) {
      levelsMap[row['name'].toString()] = row['rank'] as int;
    }
    return levelsMap;
  }

  Future<String?> getDatabaseVersion() async {
    try {
      final results = await sqliteHelper.rawQuery(
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
