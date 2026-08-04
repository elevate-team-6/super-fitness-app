import 'package:super_fitness/features/home/data/models/response/details_food_model.dart';
import 'package:super_fitness/features/home/data/models/response/meal_category_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import '../catalog_db_constants.dart';
import '../sqlite_helper.dart';

mixin MealCatalogMixin {
  SqliteHelper get sqliteHelper;
  String getNameCol([String? alias]);

  Future<List<MealCategoryModel>> getMealsCategories() async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          'SELECT ${CatalogDbConstants.columnId} as ${CatalogDbConstants.aliasIdCategory}, ${getNameCol()} as ${CatalogDbConstants.keyStrCategory}, ${CatalogDbConstants.columnName} as ${CatalogDbConstants.aliasEnglishName} FROM ${CatalogDbConstants.tableMealCategory}',
    );
    return results.map((e) {
      final map = Map<String, dynamic>.from(e);
      map[CatalogDbConstants.keyStrMealThumb] =
          'https://www.themealdb.com/images/category/${e[CatalogDbConstants.aliasEnglishName]}.png';
      return MealCategoryModel.fromSqlite(map);
    }).toList();
  }

  Future<List<MealModel>> getMealsByCategory(String category) async {
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.keyIdMeal}, 
          ${getNameCol('m')} as ${CatalogDbConstants.keyStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.keyStrMealThumb},
          ${getNameCol('a')} as ${CatalogDbConstants.keyStrArea}
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
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.keyIdMeal}, 
          ${getNameCol('m')} as ${CatalogDbConstants.keyStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.keyStrMealThumb},
          ${getNameCol('a')} as ${CatalogDbConstants.keyStrArea}
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
    final results = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT 
          m.${CatalogDbConstants.columnId} as ${CatalogDbConstants.keyIdMeal}, 
          ${getNameCol('m')} as ${CatalogDbConstants.keyStrMeal}, 
          m.${CatalogDbConstants.columnThumb} as ${CatalogDbConstants.keyStrMealThumb},
          ${getNameCol('c')} as ${CatalogDbConstants.keyStrCategory},
          ${getNameCol('a')} as ${CatalogDbConstants.keyStrArea},
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
    final ingredients = await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql:
          '''
        SELECT ${getNameCol('i')} as ${CatalogDbConstants.columnName}, mi.${CatalogDbConstants.columnQty} || ' ' || mi.${CatalogDbConstants.columnUnit} as ${CatalogDbConstants.aliasMeasure}
        FROM ${CatalogDbConstants.tableMealIngredient} mi
        JOIN ${CatalogDbConstants.tableIngredient} i ON mi.${CatalogDbConstants.columnIngredientId} = i.${CatalogDbConstants.columnId}
        WHERE mi.meal_id = ?
        ORDER BY mi.${CatalogDbConstants.columnPosition}
      ''',
      arguments: [id],
    );

    return DetailsFoodModel.fromSqlite(mealMap, ingredients: ingredients);
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
        ${getNameCol('m')} as name,
        ${getNameCol('c')} as category,
        ${getNameCol('a')} as area,
        m.kcal,
        m.protein_g as protein
      FROM ${CatalogDbConstants.tableMeal} m
      LEFT JOIN ${CatalogDbConstants.tableMealCategory} c ON m.category_id = c.id
      LEFT JOIN ${CatalogDbConstants.tableMealArea} a ON m.area_id = a.id
    ''';

    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (category != null) {
      conditions.add('${getNameCol('c')} = ?');
      args.add(category);
    }
    if (area != null) {
      conditions.add('${getNameCol('a')} = ?');
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
      query +=
          ' LEFT JOIN ${CatalogDbConstants.tableMealIngredient} mi ON m.id = mi.meal_id';
      query +=
          ' LEFT JOIN ${CatalogDbConstants.tableIngredient} i ON mi.ingredient_id = i.id';
      conditions.add(
        'm.id NOT IN (SELECT meal_id FROM ${CatalogDbConstants.tableMealIngredient} mi2 JOIN ${CatalogDbConstants.tableIngredient} i2 ON mi2.ingredient_id = i2.id WHERE ${getNameCol('i2')} = ?)',
      );
      args.add(excludeIngredient);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' GROUP BY m.id ORDER BY RANDOM() LIMIT ?';
    args.add(limit);

    return await sqliteHelper.rawQuery(
      dbName: CatalogDbConstants.mealsDb,
      sql: query,
      arguments: args,
    );
  }
}
