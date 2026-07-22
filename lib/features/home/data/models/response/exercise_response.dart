import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/exercise_entity.dart';

part 'exercise_response.g.dart';

@JsonSerializable()
class ExerciseResponse extends Equatable {
  final String? message;
  final int? totalExercises;
  final int? totalPages;
  final int? currentPage;
  final List<ExerciseModel>? exercises;

  const ExerciseResponse({
    this.message,
    this.totalExercises,
    this.totalPages,
    this.currentPage,
    this.exercises,
  });

  factory ExerciseResponse.fromJson(Map<String, dynamic> json) =>
      _$ExerciseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseResponseToJson(this);

  @override
  List<Object?> get props => [
    message,
    totalExercises,
    totalPages,
    currentPage,
    exercises,
  ];
}

@JsonSerializable()
class ExerciseModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? exercise;
  @JsonKey(name: 'short_youtube_demonstration')
  final String? shortYoutubeDemonstration;
  @JsonKey(name: 'in_depth_youtube_explanation')
  final String? inDepthYoutubeExplanation;
  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;
  @JsonKey(name: 'target_muscle_group')
  final String? targetMuscleGroup;
  @JsonKey(name: 'prime_mover_muscle')
  final String? primeMoverMuscle;
  @JsonKey(name: 'secondary_muscle')
  final String? secondaryMuscle;
  @JsonKey(name: 'tertiary_muscle')
  final String? tertiaryMuscle;
  @JsonKey(name: 'primary_equipment')
  final String? primaryEquipment;
  @JsonKey(name: '_primary_items')
  final int? primaryItems;
  @JsonKey(name: 'secondary_equipment')
  final String? secondaryEquipment;
  @JsonKey(name: '_secondary_items')
  final int? secondaryItems;
  final String? posture;
  @JsonKey(name: 'single_or_double_arm')
  final String? singleOrDoubleArm;
  @JsonKey(name: 'continuous_or_alternating_arms')
  final String? continuousOrAlternatingArms;
  final String? grip;
  @JsonKey(name: 'load_position_ending')
  final String? loadPositionEnding;
  @JsonKey(name: 'continuous_or_alternating_legs')
  final String? continuousOrAlternatingLegs;
  @JsonKey(name: 'foot_elevation')
  final String? footElevation;
  @JsonKey(name: 'combination_exercises')
  final String? combinationExercises;
  @JsonKey(name: 'movement_pattern_1')
  final String? movementPattern1;
  @JsonKey(name: 'movement_pattern_2')
  final String? movementPattern2;
  @JsonKey(name: 'movement_pattern_3')
  final String? movementPattern3;
  @JsonKey(name: 'plane_of_motion_1')
  final String? planeOfMotion1;
  @JsonKey(name: 'plane_of_motion_2')
  final String? planeOfMotion2;
  @JsonKey(name: 'plane_of_motion_3')
  final String? planeOfMotion3;
  @JsonKey(name: 'body_region')
  final String? bodyRegion;
  @JsonKey(name: 'force_type')
  final String? forceType;
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
    this.shortYoutubeDemonstration,
    this.inDepthYoutubeExplanation,
    this.difficultyLevel,
    this.targetMuscleGroup,
    this.primeMoverMuscle,
    this.secondaryMuscle,
    this.tertiaryMuscle,
    this.primaryEquipment,
    this.primaryItems,
    this.secondaryEquipment,
    this.secondaryItems,
    this.posture,
    this.singleOrDoubleArm,
    this.continuousOrAlternatingArms,
    this.grip,
    this.loadPositionEnding,
    this.continuousOrAlternatingLegs,
    this.footElevation,
    this.combinationExercises,
    this.movementPattern1,
    this.movementPattern2,
    this.movementPattern3,
    this.planeOfMotion1,
    this.planeOfMotion2,
    this.planeOfMotion3,
    this.bodyRegion,
    this.forceType,
    this.mechanics,
    this.laterality,
    this.primaryExerciseClassification,
    this.shortYoutubeDemonstrationLink,
    this.inDepthYoutubeExplanationLink,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  ExerciseEntity toEntity() => ExerciseEntity(
    id: id ?? '',
    name: exercise ?? '',
    difficulty: difficultyLevel ?? '',
    targetMuscle: targetMuscleGroup ?? '',
    videoUrl:
        shortYoutubeDemonstrationLink ?? inDepthYoutubeExplanationLink ?? '',
  );

  @override
  List<Object?> get props => [
    id,
    exercise,
    shortYoutubeDemonstration,
    inDepthYoutubeExplanation,
    difficultyLevel,
    targetMuscleGroup,
    primeMoverMuscle,
    secondaryMuscle,
    tertiaryMuscle,
    primaryEquipment,
    primaryItems,
    secondaryEquipment,
    secondaryItems,
    posture,
    singleOrDoubleArm,
    continuousOrAlternatingArms,
    grip,
    loadPositionEnding,
    continuousOrAlternatingLegs,
    footElevation,
    combinationExercises,
    movementPattern1,
    movementPattern2,
    movementPattern3,
    planeOfMotion1,
    planeOfMotion2,
    planeOfMotion3,
    bodyRegion,
    forceType,
    mechanics,
    laterality,
    primaryExerciseClassification,
    shortYoutubeDemonstrationLink,
    inDepthYoutubeExplanationLink,
  ];
}
