import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';

class WorkoutsState extends Equatable {
  final BaseState<List<MuscleGroupEntity>> muscleGroupsState;
  final BaseState<List<MuscleEntity>> musclesState;
  final String? selectedMuscleGroupId;

  const WorkoutsState({
    this.muscleGroupsState = const BaseState(),
    this.musclesState = const BaseState(),
    this.selectedMuscleGroupId,
  });

  WorkoutsState copyWith({
    BaseState<List<MuscleGroupEntity>>? muscleGroupsState,
    BaseState<List<MuscleEntity>>? musclesState,
    String? selectedMuscleGroupId,
  }) {
    return WorkoutsState(
      muscleGroupsState: muscleGroupsState ?? this.muscleGroupsState,
      musclesState: musclesState ?? this.musclesState,
      selectedMuscleGroupId: selectedMuscleGroupId ?? this.selectedMuscleGroupId,
    );
  }

  @override
  List<Object?> get props => [
        muscleGroupsState,
        musclesState,
        selectedMuscleGroupId,
      ];
}
