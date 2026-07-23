import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';

sealed class ExerciseEvents extends Equatable {
  const ExerciseEvents();

  @override
  List<Object?> get props => [];
}

class InitializeExerciseScreen extends ExerciseEvents {
  final String primeMoverMuscleId;

  const InitializeExerciseScreen(this.primeMoverMuscleId);

  @override
  List<Object?> get props => [primeMoverMuscleId];
}

class ChangeDifficulty extends ExerciseEvents {
  final DifficultyLevelEntity level;

  const ChangeDifficulty(this.level);

  @override
  List<Object?> get props => [level];
}

class RefreshExercises extends ExerciseEvents {
  const RefreshExercises();
}

class LoadMoreExercises extends ExerciseEvents {
  const LoadMoreExercises();
}
