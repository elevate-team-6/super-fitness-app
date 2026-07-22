import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_fitness/features/workouts/data/models/response/exercise_model.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

part 'exercises_by_muscle_difficulty_response.g.dart';

@JsonSerializable(createToJson: false)
class ExercisesByMuscleDifficultyResponse extends Equatable {
  final String? message;
  final int? totalExercises;
  final int? totalPages;
  final int? currentPage;
  final List<ExerciseModel>? exercises;

  const ExercisesByMuscleDifficultyResponse({
    this.message,
    this.totalExercises,
    this.totalPages,
    this.currentPage,
    this.exercises,
  });

  factory ExercisesByMuscleDifficultyResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ExercisesByMuscleDifficultyResponseFromJson(json);

  ExercisesEntity toEntity() => ExercisesEntity(
        message: message ?? '',
        totalExercises: totalExercises ?? 0,
        totalPages: totalPages ?? 0,
        currentPage: currentPage ?? 1,
        exercises: exercises?.map((e) => e.toEntity()).toList() ?? [],
      );

  @override
  List<Object?> get props => [
        message,
        totalExercises,
        totalPages,
        currentPage,
        exercises,
      ];
}
