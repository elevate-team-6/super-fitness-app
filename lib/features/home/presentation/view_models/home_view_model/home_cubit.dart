import 'package:injectable/injectable.dart';
import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import '../../../domain/entities/exercise_entity.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/muscle_entity.dart';
import '../../../domain/use_cases/get_all_exercises_use_case.dart';
import '../../../domain/use_cases/get_meals_categories_use_case.dart';
import '../../../domain/use_cases/get_muscle_groups_use_case.dart';
import '../../../domain/use_cases/get_random_exercises_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState, BaseUiEvent> {
  final GetRandomExercisesUseCase _getRandomExercisesUseCase;
  final GetMuscleGroupsUseCase _getMuscleGroupsUseCase;
  final GetMealsCategoriesUseCase _getMealsCategoriesUseCase;
  final GetAllExercisesUseCase _getAllExercisesUseCase;

  HomeCubit(
    this._getRandomExercisesUseCase,
    this._getMuscleGroupsUseCase,
    this._getMealsCategoriesUseCase,
    this._getAllExercisesUseCase,
  ) : super(const HomeState());

  void doEvent(HomeEvent event) {
    switch (event) {
      case FetchAllHomeDataEvent():
        _fetchAllHomeData();
      case FetchRandomExercisesEvent():
        _fetchRandomExercises();
      case FetchMuscleGroupsEvent():
        _fetchMuscleGroups();
      case FetchMealCategoriesEvent():
        _fetchMealCategories();
      case FetchPopularExercisesEvent():
        _fetchPopularExercises();
      case ChangeMuscleTabEvent():
        _changeMuscleTab(event.muscleId);
      case ChangeMealCategoryTabEvent():
        _changeMealCategoryTab(event.categoryId);
    }
  }

  void _fetchAllHomeData() {
    _fetchRandomExercises();
    _fetchMuscleGroups();
    _fetchMealCategories();
    _fetchPopularExercises();
  }

  Future<void> _fetchRandomExercises() async {
    emit(state.copyWith(
        recommendationTodayStatus: const BaseState(isLoading: true)));
    final result = await _getRandomExercisesUseCase(limit: 5);

    switch (result) {
      case SuccessBaseResponse<List<ExerciseEntity>>():
        emit(state.copyWith(
            recommendationTodayStatus: BaseState(data: result.data)));
      case ErrorBaseResponse<List<ExerciseEntity>>():
        emit(state.copyWith(
            recommendationTodayStatus:
                BaseState(errorMessage: result.errorMessage)));
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _fetchMuscleGroups() async {
    emit(state.copyWith(
        upcomingWorkoutsTabsStatus: const BaseState(isLoading: true)));
    final result = await _getMuscleGroupsUseCase();

    switch (result) {
      case SuccessBaseResponse<List<MuscleEntity>>():
        final muscles = result.data ?? [];
        emit(state.copyWith(
          upcomingWorkoutsTabsStatus: BaseState(data: muscles),
          activeMuscleId: muscles.isNotEmpty ? muscles.first.id : '',
        ));
        if (state.activeMuscleId.isNotEmpty) {
          _fetchExercisesByMuscle(state.activeMuscleId);
        }
      case ErrorBaseResponse<List<MuscleEntity>>():
        emit(state.copyWith(
            upcomingWorkoutsTabsStatus:
                BaseState(errorMessage: result.errorMessage)));
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _fetchExercisesByMuscle(String muscleId) async {
    emit(state.copyWith(upcomingWorkoutsStatus: const BaseState(isLoading: true)));
    // Note: In a real scenario, you'd use a usecase that filters by muscleId.
    // For now, using getAllExercises as a placeholder or assuming the usecase supports filtering.
    final result = await _getAllExercisesUseCase(limit: 10);

    switch (result) {
      case SuccessBaseResponse<List<ExerciseEntity>>():
        emit(state.copyWith(upcomingWorkoutsStatus: BaseState(data: result.data)));
      case ErrorBaseResponse<List<ExerciseEntity>>():
        emit(state.copyWith(
            upcomingWorkoutsStatus: BaseState(errorMessage: result.errorMessage)));
    }
  }

  Future<void> _fetchMealCategories() async {
    emit(state.copyWith(
        recommendationForYouTabsStatus: const BaseState(isLoading: true)));
    final result = await _getMealsCategoriesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<MealCategoryEntity>>():
        final categories = result.data ?? [];
        emit(state.copyWith(
          recommendationForYouTabsStatus: BaseState(data: categories),
          activeMealCategoryId: categories.isNotEmpty ? categories.first.id : '',
        ));
      case ErrorBaseResponse<List<MealCategoryEntity>>():
        emit(state.copyWith(
            recommendationForYouTabsStatus:
                BaseState(errorMessage: result.errorMessage)));
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _fetchPopularExercises() async {
    emit(state.copyWith(popularTrainingStatus: const BaseState(isLoading: true)));
    final result = await _getAllExercisesUseCase(limit: 10);

    switch (result) {
      case SuccessBaseResponse<List<ExerciseEntity>>():
        emit(state.copyWith(popularTrainingStatus: BaseState(data: result.data)));
      case ErrorBaseResponse<List<ExerciseEntity>>():
        emit(state.copyWith(
            popularTrainingStatus: BaseState(errorMessage: result.errorMessage)));
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  void _changeMuscleTab(String muscleId) {
    if (state.activeMuscleId == muscleId) return;
    emit(state.copyWith(activeMuscleId: muscleId));
    _fetchExercisesByMuscle(muscleId);
  }

  void _changeMealCategoryTab(String categoryId) {
    if (state.activeMealCategoryId == categoryId) return;
    emit(state.copyWith(activeMealCategoryId: categoryId));
    // Fetch meals by category logic would go here
  }
}
