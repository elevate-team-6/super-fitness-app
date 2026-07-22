import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_fitness/features/workouts/data/models/response/difficulty_level_model.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';

part 'difficulty_levels_response.g.dart';

@JsonSerializable(createToJson: false)
class DifficultyLevelsResponse extends Equatable {
  final String? message;
  final int? totalLevels;
  @JsonKey(name: 'difficulty_levels')
  final List<DifficultyLevelModel>? difficultyLevels;

  const DifficultyLevelsResponse({
    this.message,
    this.totalLevels,
    this.difficultyLevels,
  });

  factory DifficultyLevelsResponse.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelsResponseFromJson(json);

  List<DifficultyLevelEntity> toEntityList() =>
      difficultyLevels?.map((e) => e.toEntity()).toList() ?? [];

  @override
  List<Object?> get props => [message, totalLevels, difficultyLevels];
}
