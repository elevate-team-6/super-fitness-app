import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import 'catalog_db_constants.dart';
import 'mixins/common_catalog_mixin.dart';
import 'mixins/exercise_catalog_mixin.dart';
import 'mixins/meal_catalog_mixin.dart';
import 'sqlite_helper.dart';

@lazySingleton
class CatalogLocalDataSource
    with CommonCatalogMixin, ExerciseCatalogMixin, MealCatalogMixin {
  final SqliteHelper _sqliteHelper;

  CatalogLocalDataSource(this._sqliteHelper);

  @override
  SqliteHelper get sqliteHelper => _sqliteHelper;

  bool get _isArabic =>
      Intl.getCurrentLocale().startsWith(CatalogDbConstants.localeAr);

  @override
  String getNameCol([String? alias]) {
    const nameAr = CatalogDbConstants.columnNameAr;
    const nameEn = CatalogDbConstants.columnName;
    final prefix = alias != null ? '$alias.' : '';

    if (_isArabic) {
      // Fallback to English 'name' if 'name_ar' is null or empty
      return "COALESCE(NULLIF($prefix$nameAr, ''), $prefix$nameEn)";
    }
    return '$prefix$nameEn';
  }
}
