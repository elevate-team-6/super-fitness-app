import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/exercise_entity.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? exercise;
  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;
  @JsonKey(name: 'target_muscle_group')
  final String? targetMuscleGroup;
  @JsonKey(name: 'short_youtube_demonstration_link')
  final String? videoLink;

  const ExerciseModel({
    this.id,
    this.exercise,
    this.difficultyLevel,
    this.targetMuscleGroup,
    this.videoLink,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id ?? '',
      name: exercise ?? '',
      difficulty: difficultyLevel ?? '',
      targetMuscle: targetMuscleGroup ?? '',
      image: '', // To be handled with a video thumbnail extractor or placeholder
      duration: '30 MIN', // Static as per design requirements
      videoUrl: videoLink ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    exercise,
    difficultyLevel,
    targetMuscleGroup,
    videoLink,
  ];
}
