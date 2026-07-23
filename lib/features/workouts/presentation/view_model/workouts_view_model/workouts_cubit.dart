import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'workouts_events.dart';
import 'workouts_state.dart';

@injectable
class WorkoutsCubit extends BaseCubit<WorkoutsState, BaseUiEvent> {
  final GetMuscleGroupsUseCase _getMuscleGroupsUseCase;
  final GetMusclesByGroupIdUseCase _getMusclesByGroupIdUseCase;

  WorkoutsCubit({
    required GetMuscleGroupsUseCase getMuscleGroupsUseCase,
    required GetMusclesByGroupIdUseCase getMusclesByGroupIdUseCase,
  }) : _getMuscleGroupsUseCase = getMuscleGroupsUseCase,
       _getMusclesByGroupIdUseCase = getMusclesByGroupIdUseCase,
       super(const WorkoutsState());

  void doEvent(WorkoutsEvents event) {
    switch (event) {
      case GetMuscleGroupsEvent():
        _getMuscleGroups();
      case GetMusclesByGroupIdEvent():
        _getMusclesByGroupId(event.id);
    }
  }

  Future<void> _getMuscleGroups() async {
    emit(state.copyWith(muscleGroupsState: const BaseState(isLoading: true)));

    final response = await _getMuscleGroupsUseCase();

    switch (response) {
      case SuccessBaseResponse<List<MuscleGroupEntity>>():
        final groups = response.data ?? [];
        emit(state.copyWith(muscleGroupsState: BaseState(data: groups)));
        if (groups.isNotEmpty) {
          _getMusclesByGroupId(groups[0].id);
        }
      case ErrorBaseResponse<List<MuscleGroupEntity>>():
        emit(
          state.copyWith(
            muscleGroupsState: BaseState(errorMessage: response.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  Future<void> _getMusclesByGroupId(String id) async {
    emit(
      state.copyWith(
        musclesState: const BaseState(isLoading: true),
        selectedMuscleGroupId: id,
      ),
    );

    final response = await _getMusclesByGroupIdUseCase(id: id);

    switch (response) {
      case SuccessBaseResponse<List<MuscleEntity>>():
        emit(state.copyWith(musclesState: BaseState(data: response.data)));
      case ErrorBaseResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(
            musclesState: BaseState(errorMessage: response.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }
}
