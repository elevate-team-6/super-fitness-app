import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';

abstract class SqliteHelper {
  Future<Database> open({required String dbName});
  Future<List<Map<String, dynamic>>> query({
    required String dbName,
    required String table,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
  Future<List<Map<String, dynamic>>> rawQuery({
    required String dbName,
    required String sql,
    List<dynamic>? arguments,
  });
  Future<void> close({required String dbName});
}

@LazySingleton(as: SqliteHelper)
class SqliteHelperImpl implements SqliteHelper {
  final Map<String, Database> _databases = {};

  @override
  Future<Database> open({required String dbName}) async {
    if (_databases.containsKey(dbName)) {
      return _databases[dbName]!;
    }

    final path = kIsWeb ? dbName : '${await getDatabasesPath()}/$dbName';

    final db = await openDatabase(path, readOnly: true);
    _databases[dbName] = db;
    return db;
  }

  @override
  Future<List<Map<String, dynamic>>> query({
    required String dbName,
    required String table,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await open(dbName: dbName);
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery({
    required String dbName,
    required String sql,
    List<dynamic>? arguments,
  }) async {
    final db = await open(dbName: dbName);
    return await db.rawQuery(sql, arguments);
  }

  @override
  Future<void> close({required String dbName}) async {
    if (_databases.containsKey(dbName)) {
      await _databases[dbName]!.close();
      _databases.remove(dbName);
    }
  }
}
