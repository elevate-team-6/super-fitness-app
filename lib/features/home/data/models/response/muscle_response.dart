import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'muscle_response.g.dart';

@JsonSerializable()
class MuscleResponse extends Equatable {
  final String? message;
  final List<MuscleModel>? musclesGroup;

  const MuscleResponse({this.message, this.musclesGroup});

  factory MuscleResponse.fromJson(Map<String, dynamic> json) =>
      _$MuscleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleResponseToJson(this);

  @override
  List<Object?> get props => [message, musclesGroup];
}

@JsonSerializable()
class MuscleModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  const MuscleModel({this.id, this.name});

  factory MuscleModel.fromJson(Map<String, dynamic> json) =>
      _$MuscleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}
