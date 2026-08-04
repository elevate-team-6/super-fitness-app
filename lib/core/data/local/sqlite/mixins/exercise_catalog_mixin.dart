import 'package:super_fitness/features/home/data/models/response/exercise_response.dart'
    as home_exercise;
import 'package:super_fitness/features/home/data/models/response/level_response.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercise_model.dart'
    as workout_exercise;
import '../catalog_db_constants.dart';
import '../sqlite_helper.dart';

mixin ExerciseCatalogMixin {
  SqliteHelper get sqliteHelper;
  String getNameCol([String? alias]);

  Future<List<home_exercise.ExerciseModel>> getRandomExercises({
    String? primeMoverMuscleId,
    String? difficultyLevelId,
    int? limit,
  }) async {
    String query =
        '''
      SELECT 
        e.*, 
        ${getNameCol('e')} as ${CatalogDbConstants.aliasExerciseName},
        ${getNameCol('l')} as ${CatalogDbConstants.aliasDifficultyLevel},
        ${getNameCol('mg')} as ${CatalogDbConstants.aliasTargetMuscleGroup},
        ${getNameCol('m')} as ${CatalogDbConstants.aliasPrimeMoverMuscle},
        ${getNameCol('eq')} as ${CatalogDbConstants.aliasPrimaryEquipment},
        ${getNameCol('seq')} as ${CatalogDbConstants.columnSecondaryEquipment}
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

    final results = await sqliteHelper.rawQuery(
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
        ${getNameCol('e')} as ${CatalogDbConstants.aliasExerciseName},
        ${getNameCol('l')} as ${CatalogDbConstants.aliasDifficultyLevel},
        ${getNameCol('mg')} as ${CatalogDbConstants.aliasTargetMuscleGroup},
        ${getNameCol('m')} as ${CatalogDbConstants.aliasPrimeMoverMuscle}
      FROM ${CatalogDbConstants.tableExercise} e
      LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableMuscle} m ON e.${CatalogDbConstants.columnPrimeMoverId} = m.${CatalogDbConstants.columnId}
      WHERE e.${CatalogDbConstants.columnId} IN ($placeholders)
    ''';

    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql: query,
      arguments: ids,
    );

    return results
        .map((e) => home_exercise.ExerciseModel.fromSqlite(e))
        .toList();
  }

  Future<List<LevelModel>> getDifficultyLevelsByPrimeMover(
    String primeMoverMuscleId,
  ) async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          '''
        SELECT DISTINCT l.${CatalogDbConstants.columnId}, ${getNameCol('l')} as ${CatalogDbConstants.columnName}
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
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql:
          '''
        SELECT 
          e.*, 
          ${getNameCol('e')} as ${CatalogDbConstants.aliasExerciseName},
          ${getNameCol('l')} as ${CatalogDbConstants.aliasDifficultyLevel},
          ${getNameCol('mg')} as ${CatalogDbConstants.aliasTargetMuscleGroup},
          ${getNameCol('m')} as ${CatalogDbConstants.aliasPrimeMoverMuscle},
          ${getNameCol('eq')} as ${CatalogDbConstants.aliasPrimaryEquipment},
          ${getNameCol('seq')} as ${CatalogDbConstants.columnSecondaryEquipment},
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
        ${getNameCol('e')} as name,
        ${getNameCol('mg')} as muscle,
        ${getNameCol('eq')} as equipment,
        ${getNameCol('l')} as difficulty
      FROM ${CatalogDbConstants.tableExercise} e
      LEFT JOIN ${CatalogDbConstants.tableMuscleGroup} mg ON e.${CatalogDbConstants.columnMuscleGroupId} = mg.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableEquipment} eq ON e.${CatalogDbConstants.columnPrimaryEquipmentId} = eq.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableDifficultyLevel} l ON e.${CatalogDbConstants.columnDifficultyId} = l.${CatalogDbConstants.columnId}
      LEFT JOIN ${CatalogDbConstants.tableBodyRegion} br ON e.${CatalogDbConstants.columnBodyRegionId} = br.${CatalogDbConstants.columnId}
    ''';

    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (muscleGroup != null) {
      conditions.add('${getNameCol('mg')} = ?');
      args.add(muscleGroup);
    }
    if (equipment != null) {
      conditions.add('${getNameCol('eq')} = ?');
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
      conditions.add('${getNameCol('eq')} != ?');
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

    return await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.exercisesDb,
      sql: query,
      arguments: args,
    );
  }
}
