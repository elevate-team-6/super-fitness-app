import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String exercise;
  final String difficultyLevel;
  final String targetMuscleGroup;
  final String primeMoverMuscle;
  final String primaryEquipment;
  final String posture;
  final String bodyRegion;
  final String mechanics;
  final String laterality;
  final String primaryExerciseClassification;
  final String shortYoutubeDemonstrationLink;
  final String inDepthYoutubeExplanationLink;

  const ExerciseEntity({
    required this.id,
    required this.exercise,
    required this.difficultyLevel,
    required this.targetMuscleGroup,
    required this.primeMoverMuscle,
    required this.primaryEquipment,
    required this.posture,
    required this.bodyRegion,
    required this.mechanics,
    required this.laterality,
    required this.primaryExerciseClassification,
    required this.shortYoutubeDemonstrationLink,
    required this.inDepthYoutubeExplanationLink,
  });

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

class ExercisesEntity extends Equatable {
  final String message;
  final int totalExercises;
  final int totalPages;
  final int currentPage;
  final List<ExerciseEntity> exercises;

  const ExercisesEntity({
    required this.message,
    required this.totalExercises,
    required this.totalPages,
    required this.currentPage,
    required this.exercises,
  });

  @override
  List<Object?> get props => [
        message,
        totalExercises,
        totalPages,
        currentPage,
        exercises,
      ];
}
