import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/level_entity.dart';

part 'level_response.g.dart';

@JsonSerializable()
class LevelResponse extends Equatable {
  final String? message;
  final List<LevelModel>? levels;

  const LevelResponse({this.message, this.levels});

  factory LevelResponse.fromJson(Map<String, dynamic> json) =>
      _$LevelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LevelResponseToJson(this);

  @override
  List<Object?> get props => [message, levels];
}

@JsonSerializable()
class LevelModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  const LevelModel({this.id, this.name});

  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      _$LevelModelFromJson(json);

  Map<String, dynamic> toJson() => _$LevelModelToJson(this);

  LevelEntity toEntity() => LevelEntity(id: id ?? '', name: name ?? '');

  @override
  List<Object?> get props => [id, name];
}
