import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

part 'exercise_model.g.dart';

@JsonSerializable(createToJson: false)
class ExerciseModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? exercise;
  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;
  @JsonKey(name: 'target_muscle_group')
  final String? targetMuscleGroup;
  @JsonKey(name: 'prime_mover_muscle')
  final String? primeMoverMuscle;
  @JsonKey(name: 'primary_equipment')
  final String? primaryEquipment;
  final String? posture;
  @JsonKey(name: 'body_region')
  final String? bodyRegion;
  final String? mechanics;
  final String? laterality;
  @JsonKey(name: 'primary_exercise_classification')
  final String? primaryExerciseClassification;
  @JsonKey(name: 'short_youtube_demonstration_link')
  final String? shortYoutubeDemonstrationLink;
  @JsonKey(name: 'in_depth_youtube_explanation_link')
  final String? inDepthYoutubeExplanationLink;

  const ExerciseModel({
    this.id,
    this.exercise,
    this.difficultyLevel,
    this.targetMuscleGroup,
    this.primeMoverMuscle,
    this.primaryEquipment,
    this.posture,
    this.bodyRegion,
    this.mechanics,
    this.laterality,
    this.primaryExerciseClassification,
    this.shortYoutubeDemonstrationLink,
    this.inDepthYoutubeExplanationLink,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  ExerciseEntity toEntity() => ExerciseEntity(
        id: id ?? '',
        exercise: exercise ?? '',
        difficultyLevel: difficultyLevel ?? '',
        targetMuscleGroup: targetMuscleGroup ?? '',
        primeMoverMuscle: primeMoverMuscle ?? '',
        primaryEquipment: primaryEquipment ?? '',
        posture: posture ?? '',
        bodyRegion: bodyRegion ?? '',
        mechanics: mechanics ?? '',
        laterality: laterality ?? '',
        primaryExerciseClassification: primaryExerciseClassification ?? '',
        shortYoutubeDemonstrationLink: shortYoutubeDemonstrationLink ?? '',
        inDepthYoutubeExplanationLink: inDepthYoutubeExplanationLink ?? '',
      );

  @override
  List<Object?> get props => [
        id,
        exercise,
        difficultyLevel,
        targetMuscleGroup,
        primeMoverMuscle,
        primaryEquipment,
        posture,
        bodyRegion,
        mechanics,
        laterality,
        primaryExerciseClassification,
        shortYoutubeDemonstrationLink,
        inDepthYoutubeExplanationLink,
      ];
}
