import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../entities/muscle_group_entity.dart';

part 'muscle_group_model.g.dart';

@JsonSerializable()
class MuscleGroupModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  const MuscleGroupModel({
    this.id,
    this.name,
  });

  factory MuscleGroupModel.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleGroupModelToJson(this);

  MuscleGroupEntity toEntity() {
    return MuscleGroupEntity(
      id: id ?? '',
      name: name ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}
