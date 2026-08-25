import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class AssetInstaller {
  static const String _manifestPath = 'assets/data/manifest.json';
  static const String _assetPrefix = 'assets/data/';

  Future<void> initialize() async {
    final manifestStr = await rootBundle.loadString(_manifestPath);
    final Map<String, dynamic> manifest =
        json.decode(manifestStr) as Map<String, dynamic>;
    final databases = manifest['databases'] as Map<String, dynamic>;

    if (kIsWeb) {
      await _initializeWeb(databases);
      return;
    }

    final dbDirectory = await getDatabasesPath();

    // Ensure the directory exists
    await Directory(dbDirectory).create(recursive: true);

    for (final entry in databases.entries) {
      final dbName = entry.key;
      final Map<String, dynamic> dbInfo = entry.value as Map<String, dynamic>;
      final expectedSha = dbInfo['sha256'] as String;
      final targetPath = join(dbDirectory, dbName);

      bool needsCopy = true;

      if (File(targetPath).existsSync()) {
        final currentSha = await _calculateFileSha256(targetPath);
        if (currentSha == expectedSha) {
          needsCopy = false;
        }
      }

      if (needsCopy) {
        await _copyDatabase(dbName, targetPath, expectedSha);
      }
    }
  }

  Future<void> _initializeWeb(Map<String, dynamic> databases) async {
    for (final entry in databases.entries) {
      final dbName = entry.key;
      final dbInfo = entry.value as Map<String, dynamic>;
      final expectedSha = dbInfo['sha256'] as String;
      var needsCopy = true;

      if (await databaseFactory.databaseExists(dbName)) {
        final currentBytes = await databaseFactory.readDatabaseBytes(dbName);
        needsCopy = sha256.convert(currentBytes).toString() != expectedSha;
      }

      if (needsCopy) {
        final data = await rootBundle.load('$_assetPrefix$dbName');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await databaseFactory.writeDatabaseBytes(dbName, bytes);
      }
    }
  }

  Future<void> _copyDatabase(
    String dbName,
    String targetPath,
    String expectedSha,
  ) async {
    final tempPath = '$targetPath.tmp';
    final data = await rootBundle.load('$_assetPrefix$dbName');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes, flush: true);

    final actualSha = await _calculateFileSha256(tempPath);
    if (actualSha != expectedSha) {
      await tempFile.delete();
      throw Exception(
        'Integrity check failed for $dbName. Expected $expectedSha, got $actualSha',
      );
    }

    // Atomic rename
    await tempFile.rename(targetPath);
  }

  Future<String> _calculateFileSha256(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
