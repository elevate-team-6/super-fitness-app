import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/ingredient_entity.dart';
import '../../domain/entities/meal_entity.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class MealModel extends Equatable {
  final String? idMeal;
  final String? strMeal;
  final String? strCategory;
  final String? strMealThumb;
  final String? strInstructions;
  final String? strIngredient1;
  final String? strIngredient2;
  final String? strIngredient3;
  final String? strIngredient4;
  final String? strIngredient5;
  final String? strIngredient6;
  final String? strIngredient7;
  final String? strIngredient8;
  final String? strIngredient9;
  final String? strIngredient10;
  final String? strIngredient11;
  final String? strIngredient12;
  final String? strIngredient13;
  final String? strIngredient14;
  final String? strIngredient15;
  final String? strIngredient16;
  final String? strIngredient17;
  final String? strIngredient18;
  final String? strIngredient19;
  final String? strIngredient20;
  final String? strMeasure1;
  final String? strMeasure2;
  final String? strMeasure3;
  final String? strMeasure4;
  final String? strMeasure5;
  final String? strMeasure6;
  final String? strMeasure7;
  final String? strMeasure8;
  final String? strMeasure9;
  final String? strMeasure10;
  final String? strMeasure11;
  final String? strMeasure12;
  final String? strMeasure13;
  final String? strMeasure14;
  final String? strMeasure15;
  final String? strMeasure16;
  final String? strMeasure17;
  final String? strMeasure18;
  final String? strMeasure19;
  final String? strMeasure20;

  const MealModel({
    this.idMeal,
    this.strMeal,
    this.strCategory,
    this.strMealThumb,
    this.strInstructions,
    this.strIngredient1,
    this.strIngredient2,
    this.strIngredient3,
    this.strIngredient4,
    this.strIngredient5,
    this.strIngredient6,
    this.strIngredient7,
    this.strIngredient8,
    this.strIngredient9,
    this.strIngredient10,
    this.strIngredient11,
    this.strIngredient12,
    this.strIngredient13,
    this.strIngredient14,
    this.strIngredient15,
    this.strIngredient16,
    this.strIngredient17,
    this.strIngredient18,
    this.strIngredient19,
    this.strIngredient20,
    this.strMeasure1,
    this.strMeasure2,
    this.strMeasure3,
    this.strMeasure4,
    this.strMeasure5,
    this.strMeasure6,
    this.strMeasure7,
    this.strMeasure8,
    this.strMeasure9,
    this.strMeasure10,
    this.strMeasure11,
    this.strMeasure12,
    this.strMeasure13,
    this.strMeasure14,
    this.strMeasure15,
    this.strMeasure16,
    this.strMeasure17,
    this.strMeasure18,
    this.strMeasure19,
    this.strMeasure20,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  MealEntity toEntity() {
    final List<IngredientEntity> ingredients = [];

    _addIngredient(ingredients, strIngredient1, strMeasure1);
    _addIngredient(ingredients, strIngredient2, strMeasure2);
    _addIngredient(ingredients, strIngredient3, strMeasure3);
    _addIngredient(ingredients, strIngredient4, strMeasure4);
    _addIngredient(ingredients, strIngredient5, strMeasure5);
    _addIngredient(ingredients, strIngredient6, strMeasure6);
    _addIngredient(ingredients, strIngredient7, strMeasure7);
    _addIngredient(ingredients, strIngredient8, strMeasure8);
    _addIngredient(ingredients, strIngredient9, strMeasure9);
    _addIngredient(ingredients, strIngredient10, strMeasure10);
    _addIngredient(ingredients, strIngredient11, strMeasure11);
    _addIngredient(ingredients, strIngredient12, strMeasure12);
    _addIngredient(ingredients, strIngredient13, strMeasure13);
    _addIngredient(ingredients, strIngredient14, strMeasure14);
    _addIngredient(ingredients, strIngredient15, strMeasure15);
    _addIngredient(ingredients, strIngredient16, strMeasure16);
    _addIngredient(ingredients, strIngredient17, strMeasure17);
    _addIngredient(ingredients, strIngredient18, strMeasure18);
    _addIngredient(ingredients, strIngredient19, strMeasure19);
    _addIngredient(ingredients, strIngredient20, strMeasure20);

    return MealEntity(
      id: idMeal ?? '',
      name: strMeal ?? '',
      category: strCategory ?? '',
      image: strMealThumb ?? '',
      instructions: strInstructions ?? '',
      ingredients: ingredients,
    );
  }

  void _addIngredient(
    List<IngredientEntity> list,
    String? name,
    String? measure,
  ) {
    if (name != null && name.trim().isNotEmpty) {
      list.add(
        IngredientEntity(
          name: name.trim(),
          measure: measure?.trim() ?? '',
        ),
      );
    }
  }

  @override
  List<Object?> get props => [
    idMeal,
    strMeal,
    strCategory,
    strMealThumb,
    strInstructions,
    strIngredient1,
    strIngredient2,
    strIngredient3,
    strIngredient4,
    strIngredient5,
    strIngredient6,
    strIngredient7,
    strIngredient8,
    strIngredient9,
    strIngredient10,
    strIngredient11,
    strIngredient12,
    strIngredient13,
    strIngredient14,
    strIngredient15,
    strIngredient16,
    strIngredient17,
    strIngredient18,
    strIngredient19,
    strIngredient20,
    strMeasure1,
    strMeasure2,
    strMeasure3,
    strMeasure4,
    strMeasure5,
    strMeasure6,
    strMeasure7,
    strMeasure8,
    strMeasure9,
    strMeasure10,
    strMeasure11,
    strMeasure12,
    strMeasure13,
    strMeasure14,
    strMeasure15,
    strMeasure16,
    strMeasure17,
    strMeasure18,
    strMeasure19,
    strMeasure20,
  ];
}
