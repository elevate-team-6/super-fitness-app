import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

class ExerciseState extends Equatable {
  final bool isLoadingLevels;
  final bool isLoadingExercises;
  final List<DifficultyLevelEntity> difficultyLevels;
  final DifficultyLevelEntity? selectedDifficulty;
  final List<ExerciseEntity> exercises;
  final String? activePrimeMoverMuscleId;
  final String? levelsError;
  final String? exercisesError;

  const ExerciseState({
    this.isLoadingLevels = false,
    this.isLoadingExercises = false,
    this.difficultyLevels = const [],
    this.selectedDifficulty,
    this.exercises = const [],
    this.activePrimeMoverMuscleId,
    this.levelsError,
    this.exercisesError,
  });

  ExerciseState copyWith({
    bool? isLoadingLevels,
    bool? isLoadingExercises,
    List<DifficultyLevelEntity>? difficultyLevels,
    DifficultyLevelEntity? selectedDifficulty,
    List<ExerciseEntity>? exercises,
    String? activePrimeMoverMuscleId,
    String? Function()? levelsError,
    String? Function()? exercisesError,
  }) {
    return ExerciseState(
      isLoadingLevels: isLoadingLevels ?? this.isLoadingLevels,
      isLoadingExercises: isLoadingExercises ?? this.isLoadingExercises,
      difficultyLevels: difficultyLevels ?? this.difficultyLevels,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      exercises: exercises ?? this.exercises,
      activePrimeMoverMuscleId:
          activePrimeMoverMuscleId ?? this.activePrimeMoverMuscleId,
      levelsError: levelsError != null ? levelsError() : this.levelsError,
      exercisesError: exercisesError != null
          ? exercisesError()
          : this.exercisesError,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingLevels,
    isLoadingExercises,
    difficultyLevels,
    selectedDifficulty,
    exercises,
    activePrimeMoverMuscleId,
    levelsError,
    exercisesError,
  ];
}
