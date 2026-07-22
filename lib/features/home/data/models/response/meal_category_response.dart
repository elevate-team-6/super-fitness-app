import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_category_response.g.dart';

@JsonSerializable()
class MealCategoryResponse extends Equatable {
  final List<MealCategoryModel>? categories;

  const MealCategoryResponse({this.categories});

  factory MealCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$MealCategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MealCategoryResponseToJson(this);

  @override
  List<Object?> get props => [categories];
}

@JsonSerializable()
class MealCategoryModel extends Equatable {
  final String? idCategory;
  final String? strCategory;
  final String? strCategoryThumb;
  final String? strCategoryDescription;

  const MealCategoryModel({
    this.idCategory,
    this.strCategory,
    this.strCategoryThumb,
    this.strCategoryDescription,
  });

  factory MealCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$MealCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealCategoryModelToJson(this);

  @override
  List<Object?> get props => [
        idCategory,
        strCategory,
        strCategoryThumb,
        strCategoryDescription,
      ];
}
