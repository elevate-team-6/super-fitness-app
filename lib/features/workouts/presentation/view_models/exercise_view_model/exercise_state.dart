import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

class ExerciseState extends Equatable {
  final bool isLoadingLevels;
  final bool isLoadingExercises;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasReachedMax;
  final List<DifficultyLevelEntity> difficultyLevels;
  final DifficultyLevelEntity? selectedDifficulty;
  final List<ExerciseEntity> exercises;
  final int totalExercises;
  final int totalPages;
  final int currentPage;
  final String? activePrimeMoverMuscleId;
  final String? levelsError;
  final String? exercisesError;

  const ExerciseState({
    this.isLoadingLevels = false,
    this.isLoadingExercises = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasReachedMax = false,
    this.difficultyLevels = const [],
    this.selectedDifficulty,
    this.exercises = const [],
    this.totalExercises = 0,
    this.totalPages = 0,
    this.currentPage = 1,
    this.activePrimeMoverMuscleId,
    this.levelsError,
    this.exercisesError,
  });

  ExerciseState copyWith({
    bool? isLoadingLevels,
    bool? isLoadingExercises,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasReachedMax,
    List<DifficultyLevelEntity>? difficultyLevels,
    DifficultyLevelEntity? selectedDifficulty,
    List<ExerciseEntity>? exercises,
    int? totalExercises,
    int? totalPages,
    int? currentPage,
    String? activePrimeMoverMuscleId,
    String? Function()? levelsError,
    String? Function()? exercisesError,
  }) {
    return ExerciseState(
      isLoadingLevels: isLoadingLevels ?? this.isLoadingLevels,
      isLoadingExercises: isLoadingExercises ?? this.isLoadingExercises,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      difficultyLevels: difficultyLevels ?? this.difficultyLevels,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      exercises: exercises ?? this.exercises,
      totalExercises: totalExercises ?? this.totalExercises,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
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
    isLoadingMore,
    isRefreshing,
    hasReachedMax,
    difficultyLevels,
    selectedDifficulty,
    exercises,
    totalExercises,
    totalPages,
    currentPage,
    activePrimeMoverMuscleId,
    levelsError,
    exercisesError,
  ];
}
