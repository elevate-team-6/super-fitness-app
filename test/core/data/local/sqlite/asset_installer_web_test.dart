@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:super_fitness/core/data/local/sqlite/asset_installer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('installs the bundled catalog database in browser storage', (
    tester,
  ) async {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;

    await AssetInstaller().initialize();

    expect(await databaseFactory.databaseExists('meals.db'), isTrue);
  });
}
