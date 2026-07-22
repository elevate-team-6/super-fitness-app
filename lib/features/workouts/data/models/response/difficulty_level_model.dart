import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';

part 'difficulty_level_model.g.dart';

@JsonSerializable(createToJson: false)
class DifficultyLevelModel extends Equatable {
  final String? id;
  final String? name;

  const DifficultyLevelModel({this.id, this.name});

  factory DifficultyLevelModel.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelModelFromJson(json);

  DifficultyLevelEntity toEntity() => DifficultyLevelEntity(
        id: id ?? '',
        name: name ?? '',
      );

  @override
  List<Object?> get props => [id, name];
}
