import '../../../../../core/data/local/sqlite/catalog_db_constants.dart';
import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';

class MealModel {
  final String? idMeal;
  final String? strMeal;
  final String? strMealThumb;
  final String? strArea;
  final String? strCountry;

  const MealModel({
    this.idMeal,
    this.strMeal,
    this.strMealThumb,
    this.strArea,
    this.strCountry,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    idMeal: json[ApiParameters.idMeal] as String?,
    strMeal: json[ApiParameters.strMeal] as String?,
    strMealThumb: json[ApiParameters.strMealThumb] as String?,
    strArea: json[ApiParameters.strArea] as String?,
    strCountry: json[ApiParameters.strCountry] as String?,
  );

  factory MealModel.fromSqlite(Map<String, dynamic> map) => MealModel(
    idMeal: map[CatalogDbConstants.keyIdMeal]?.toString(),
    strMeal: map[CatalogDbConstants.keyStrMeal]?.toString(),
    strMealThumb: map[CatalogDbConstants.keyStrMealThumb]?.toString(),
    strArea: map[CatalogDbConstants.keyStrArea]?.toString(),
    strCountry: map[CatalogDbConstants.keyStrCountry]?.toString(),
  );

  MealEntity toEntity() => MealEntity(
    id: idMeal ?? '',
    name: strMeal ?? '',
    thumbnail: strMealThumb ?? '',
  );
}
