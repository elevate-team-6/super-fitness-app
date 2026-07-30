import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

import '../../../../../core/data/local/sqlite/catalog_db_constants.dart';

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
  @JsonKey(name: 'secondary_equipment')
  final String? secondaryEquipment;
  final String? posture;
  final String? grip;
  @JsonKey(name: 'force_type')
  final String? forceType;
  @JsonKey(name: 'secondary_muscle')
  final String? secondaryMuscles;
  @JsonKey(name: 'tertiary_muscle')
  final String? tertiaryMuscles;
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
    this.secondaryEquipment,
    this.posture,
    this.grip,
    this.forceType,
    this.secondaryMuscles,
    this.tertiaryMuscles,
    this.bodyRegion,
    this.mechanics,
    this.laterality,
    this.primaryExerciseClassification,
    this.shortYoutubeDemonstrationLink,
    this.inDepthYoutubeExplanationLink,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  factory ExerciseModel.fromSqlite(Map<String, dynamic> map) => ExerciseModel(
    id: map[CatalogDbConstants.columnId]?.toString(),
    exercise: map[CatalogDbConstants.aliasExerciseName]?.toString(),
    difficultyLevel: map[CatalogDbConstants.aliasDifficultyLevel]?.toString(),
    targetMuscleGroup: map[CatalogDbConstants.aliasTargetMuscleGroup]
        ?.toString(),
    primeMoverMuscle: map[CatalogDbConstants.aliasPrimeMoverMuscle]?.toString(),
    primaryEquipment: map[CatalogDbConstants.aliasPrimaryEquipment]?.toString(),
    secondaryEquipment: map[CatalogDbConstants.columnSecondaryEquipment]
        ?.toString(),
    posture: map[CatalogDbConstants.columnPosture]?.toString(),
    grip: map[CatalogDbConstants.columnGrip]?.toString(),
    forceType: map[CatalogDbConstants.columnForceType]?.toString(),
    secondaryMuscles: map[CatalogDbConstants.columnSecondaryMuscle]?.toString(),
    tertiaryMuscles: map[CatalogDbConstants.columnTertiaryMuscle]?.toString(),
    bodyRegion: map[CatalogDbConstants.columnBodyRegionName]?.toString(),
    mechanics: map[CatalogDbConstants.columnMechanics]?.toString(),
    laterality: map[CatalogDbConstants.columnLaterality]?.toString(),
    primaryExerciseClassification: map[CatalogDbConstants.columnClassification]
        ?.toString(),
    shortYoutubeDemonstrationLink:
        (map[CatalogDbConstants.aliasShortYoutubeLink] ??
                map[CatalogDbConstants.columnDemoUrl])
            ?.toString(),
    inDepthYoutubeExplanationLink:
        (map[CatalogDbConstants.aliasInDepthYoutubeLink] ??
                map[CatalogDbConstants.columnExplainUrl])
            ?.toString(),
  );

  ExerciseEntity toEntity() => ExerciseEntity(
    id: id ?? '',
    exercise: exercise ?? '',
    difficultyLevel: difficultyLevel ?? '',
    targetMuscleGroup: targetMuscleGroup ?? '',
    primeMoverMuscle: primeMoverMuscle ?? '',
    primaryEquipment: primaryEquipment ?? '',
    secondaryEquipment: secondaryEquipment ?? '',
    posture: posture ?? '',
    grip: grip ?? '',
    forceType: forceType ?? '',
    secondaryMuscles: secondaryMuscles ?? '',
    tertiaryMuscles: tertiaryMuscles ?? '',
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
    secondaryEquipment,
    posture,
    grip,
    forceType,
    secondaryMuscles,
    tertiaryMuscles,
    bodyRegion,
    mechanics,
    laterality,
    primaryExerciseClassification,
    shortYoutubeDemonstrationLink,
    inDepthYoutubeExplanationLink,
  ];
}
