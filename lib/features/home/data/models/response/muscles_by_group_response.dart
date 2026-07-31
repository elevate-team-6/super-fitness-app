import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'muscle_response.dart';

part 'muscles_by_group_response.g.dart';

@JsonSerializable()
class MusclesByGroupResponse extends Equatable {
  final String? message;
  final MuscleGroupModel? muscleGroup;
  final List<MuscleModel>? muscles;

  const MusclesByGroupResponse({this.message, this.muscleGroup, this.muscles});

  factory MusclesByGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$MusclesByGroupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MusclesByGroupResponseToJson(this);

  @override
  List<Object?> get props => [message, muscleGroup, muscles];
}

@JsonSerializable()
class MuscleGroupModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  const MuscleGroupModel({this.id, this.name});

  factory MuscleGroupModel.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleGroupModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}
