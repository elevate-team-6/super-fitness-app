import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_difficulty_levels_by_prime_mover_use_case.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_exercises_by_muscle_difficulty_use_case.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_event.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_state.dart';

@injectable
class ExerciseCubit extends BaseCubit<ExerciseState, BaseUiEvent> {
  final GetDifficultyLevelsByPrimeMoverUseCase
      _getDifficultyLevelsByPrimeMoverUseCase;
  final GetExercisesByMuscleDifficultyUseCase
      _getExercisesByMuscleDifficultyUseCase;

  ExerciseCubit(
    this._getDifficultyLevelsByPrimeMoverUseCase,
    this._getExercisesByMuscleDifficultyUseCase,
  ) : super(const ExerciseState());

  void doIntent(ExerciseEvents event) {
    switch (event) {
      case InitializeExerciseScreen(:final primeMoverMuscleId):
        _initialize(primeMoverMuscleId);
      case ChangeDifficulty(:final level):
        _changeDifficulty(level);
      case RefreshExercises():
        _refresh();
      case LoadMoreExercises():
        _loadMore();
    }
  }

  Future<void> _initialize(String primeMoverMuscleId) async {
    emit(
      state.copyWith(
        activePrimeMoverMuscleId: primeMoverMuscleId,
        isLoadingLevels: true,
        levelsError: () => null,
      ),
    );

    final response = await _getDifficultyLevelsByPrimeMoverUseCase(
      primeMoverMuscleId: primeMoverMuscleId,
    );

    switch (response) {
      case SuccessBaseResponse<List<DifficultyLevelEntity>>():
        final levels = response.data ?? [];
        final firstLevel = levels.isNotEmpty ? levels.first : null;

        emit(
          state.copyWith(
            isLoadingLevels: false,
            difficultyLevels: levels,
            selectedDifficulty: firstLevel,
          ),
        );

        if (firstLevel != null) {
          await _loadExercises();
        }
      case ErrorBaseResponse<List<DifficultyLevelEntity>>():
        emit(
          state.copyWith(
            isLoadingLevels: false,
            levelsError: () => response.errorMessage.tr(),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  Future<void> _changeDifficulty(DifficultyLevelEntity level) async {
    if (state.selectedDifficulty == level && state.exercises.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        selectedDifficulty: level,
        exercises: [],
        isLoadingExercises: true,
        hasReachedMax: false,
        currentPage: 1,
        exercisesError: () => null,
      ),
    );

    await _loadExercises();
  }

  Future<void> _refresh() async {
    final muscleId = state.activePrimeMoverMuscleId;
    final difficulty = state.selectedDifficulty;

    if (muscleId == null || difficulty == null || state.isRefreshing) {
      return;
    }

    emit(state.copyWith(isRefreshing: true, exercisesError: () => null));

    final response = await _getExercisesByMuscleDifficultyUseCase(
      primeMoverMuscleId: muscleId,
      difficultyLevelId: difficulty.id,
    );

    switch (response) {
      case SuccessBaseResponse<ExercisesEntity>():
        final data = response.data;
        final totalPages = data?.totalPages ?? 0;
        final currentPage = data?.currentPage ?? 1;

        emit(
          state.copyWith(
            isRefreshing: false,
            exercises: data?.exercises ?? [],
            totalExercises: data?.totalExercises ?? 0,
            totalPages: totalPages,
            currentPage: currentPage,
            hasReachedMax: currentPage >= totalPages,
          ),
        );
      case ErrorBaseResponse<ExercisesEntity>():
        emit(
          state.copyWith(
            isRefreshing: false,
            exercisesError: () => response.errorMessage.tr(),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  Future<void> _loadMore() async {
    final muscleId = state.activePrimeMoverMuscleId;
    final difficulty = state.selectedDifficulty;

    if (muscleId == null ||
        difficulty == null ||
        state.isLoadingMore ||
        state.isLoadingExercises ||
        state.isRefreshing ||
        state.hasReachedMax) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, exercisesError: () => null));

    final response = await _getExercisesByMuscleDifficultyUseCase(
      primeMoverMuscleId: muscleId,
      difficultyLevelId: difficulty.id,
    );

    switch (response) {
      case SuccessBaseResponse<ExercisesEntity>():
        final data = response.data;
        final newExercises = data?.exercises ?? [];
        final totalPages = data?.totalPages ?? state.totalPages;
        final currentPage = data?.currentPage ?? (state.currentPage + 1);

        emit(
          state.copyWith(
            isLoadingMore: false,
            exercises: [...state.exercises, ...newExercises],
            totalExercises: data?.totalExercises ?? state.totalExercises,
            totalPages: totalPages,
            currentPage: currentPage,
            hasReachedMax: currentPage >= totalPages,
          ),
        );
      case ErrorBaseResponse<ExercisesEntity>():
        emit(
          state.copyWith(
            isLoadingMore: false,
            exercisesError: () => response.errorMessage.tr(),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  Future<void> _loadExercises() async {
    final muscleId = state.activePrimeMoverMuscleId;
    final difficulty = state.selectedDifficulty;

    if (muscleId == null || difficulty == null) return;

    emit(state.copyWith(isLoadingExercises: true, exercisesError: () => null));

    final response = await _getExercisesByMuscleDifficultyUseCase(
      primeMoverMuscleId: muscleId,
      difficultyLevelId: difficulty.id,
    );

    switch (response) {
      case SuccessBaseResponse<ExercisesEntity>():
        final data = response.data;
        final totalPages = data?.totalPages ?? 0;
        final currentPage = data?.currentPage ?? 1;

        emit(
          state.copyWith(
            isLoadingExercises: false,
            exercises: data?.exercises ?? [],
            totalExercises: data?.totalExercises ?? 0,
            totalPages: totalPages,
            currentPage: currentPage,
            hasReachedMax: currentPage >= totalPages,
          ),
        );
      case ErrorBaseResponse<ExercisesEntity>():
        emit(
          state.copyWith(
            isLoadingExercises: false,
            exercisesError: () => response.errorMessage.tr(),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }
}
