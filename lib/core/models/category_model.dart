import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Equatable {
  @JsonKey(name: 'idCategory')
  final String? id;
  @JsonKey(name: 'strCategory')
  final String? name;
  @JsonKey(name: 'strCategoryThumb')
  final String? image;
  @JsonKey(name: 'strCategoryDescription')
  final String? description;

  const CategoryModel({
    this.id,
    this.name,
    this.image,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id ?? '',
      name: name ?? '',
      image: image ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, image, description];
}
