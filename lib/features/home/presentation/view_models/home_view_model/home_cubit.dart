import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import '../../../domain/entities/home_user_entity.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/muscle_entity.dart';
import '../../../domain/use_cases/get_cached_user_data_use_case.dart';
import '../../../domain/use_cases/get_meals_categories_use_case.dart';
import '../../../domain/use_cases/get_muscle_groups_use_case.dart';
import '../../../domain/use_cases/get_muscles_by_group_id_use_case.dart';
import '../../../domain/use_cases/get_popular_training_exercises_use_case.dart';
import '../../../domain/use_cases/get_random_muscles_use_case.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';
import 'home_event.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState, BaseUiEvent> {
  final GetRandomMusclesUseCase _getRandomMusclesUseCase;
  final GetMuscleGroupsUseCase _getMuscleGroupsUseCase;
  final GetMusclesByGroupIdUseCase _getMusclesByGroupIdUseCase;
  final GetMealsCategoriesUseCase _getMealsCategoriesUseCase;
  final GetPopularTrainingExercisesUseCase _getPopularTrainingExercisesUseCase;
  final GetCachedUserDataUseCase _getCachedUserDataUseCase;
  final ProfileRepoContract _profileRepo;

  StreamSubscription? _userSubscription;

  HomeCubit(
    this._getRandomMusclesUseCase,
    this._getMuscleGroupsUseCase,
    this._getMusclesByGroupIdUseCase,
    this._getMealsCategoriesUseCase,
    this._getPopularTrainingExercisesUseCase,
    this._getCachedUserDataUseCase,
    this._profileRepo,
  ) : super(const HomeState()) {
    _subscribeToUserChanges();
  }

  void _subscribeToUserChanges() {
    _userSubscription = _profileRepo.userStream.listen((user) {
      if (user != null) {
        emit(
          state.copyWith(
            homeUserStatus: BaseState(
              data: HomeUserEntity(
                name: "${user.firstName} ${user.lastName}",
                image: user.photo,
              ),
            ),
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  void doEvent(HomeEvent event) {
    switch (event) {
      case FetchAllHomeDataEvent():
        _fetchAllHomeData();
      case FetchHomeUserEvent():
        _fetchHomeUser();
      case FetchRandomExercisesEvent():
        _fetchRandomMuscles();
      case FetchMuscleGroupsEvent():
        _fetchMuscleGroups();
      case FetchMealCategoriesEvent():
        _fetchMealCategories();
      case FetchPopularExercisesEvent():
        _fetchPopularExercises();
      case ChangeMuscleTabEvent():
        _changeMuscleTab(event.muscleId);
    }
  }

  void _fetchAllHomeData() {
    _fetchHomeUser();
    _fetchRandomMuscles();
    _fetchMuscleGroups();
    _fetchMealCategories();
    _fetchPopularExercises();
  }

  Future<void> _fetchHomeUser() async {
    emit(state.copyWith(homeUserStatus: const BaseState(isLoading: true)));
    final result = await _getCachedUserDataUseCase();

    switch (result) {
      case SuccessBaseResponse<HomeUserEntity>():
        emit(state.copyWith(homeUserStatus: BaseState(data: result.data)));
      case ErrorBaseResponse<HomeUserEntity>():
        emit(
          state.copyWith(
            homeUserStatus: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }

  Future<void> _fetchRandomMuscles() async {
    emit(
      state.copyWith(
        recommendationTodayStatus: const BaseState(isLoading: true),
      ),
    );
    final result = await _getRandomMusclesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(
            recommendationTodayStatus: BaseState(data: result.data),
          ),
        );
      case ErrorBaseResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(
            recommendationTodayStatus: BaseState(
              errorMessage: result.errorMessage,
            ),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _fetchMuscleGroups() async {
    emit(
      state.copyWith(
        upcomingWorkoutsTabsStatus: const BaseState(isLoading: true),
      ),
    );
    final result = await _getMuscleGroupsUseCase();

    switch (result) {
      case SuccessBaseResponse<List<MuscleEntity>>():
        final muscles = result.data ?? [];
        emit(
          state.copyWith(
            upcomingWorkoutsTabsStatus: BaseState(data: muscles),
            activeMuscleId: muscles.isNotEmpty ? muscles.first.id : '',
          ),
        );
        if (state.activeMuscleId.isNotEmpty) {
          await _fetchMusclesByGroupId(state.activeMuscleId);
        }
      case ErrorBaseResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(
            upcomingWorkoutsTabsStatus: BaseState(
              errorMessage: result.errorMessage,
            ),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _fetchMusclesByGroupId(String groupId) async {
    emit(
      state.copyWith(upcomingWorkoutsStatus: const BaseState(isLoading: true)),
    );
    final result = await _getMusclesByGroupIdUseCase(groupId);

    switch (result) {
      case SuccessBaseResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(upcomingWorkoutsStatus: BaseState(data: result.data)),
        );
      case ErrorBaseResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(
            upcomingWorkoutsStatus: BaseState(
              errorMessage: result.errorMessage,
            ),
          ),
        );
    }
  }

  Future<void> _fetchMealCategories() async {
    emit(
      state.copyWith(
        recommendationForYouTabsStatus: const BaseState(isLoading: true),
      ),
    );
    final result = await _getMealsCategoriesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<MealCategoryEntity>>():
        emit(
          state.copyWith(
            recommendationForYouTabsStatus: BaseState(data: result.data),
          ),
        );
      case ErrorBaseResponse<List<MealCategoryEntity>>():
        emit(
          state.copyWith(
            recommendationForYouTabsStatus: BaseState(
              errorMessage: result.errorMessage,
            ),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _fetchPopularExercises() async {
    emit(
      state.copyWith(popularTrainingStatus: const BaseState(isLoading: true)),
    );
    final result = await _getPopularTrainingExercisesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<ExerciseEntity>>():
        emit(
          state.copyWith(popularTrainingStatus: BaseState(data: result.data)),
        );
      case ErrorBaseResponse<List<ExerciseEntity>>():
        emit(
          state.copyWith(
            popularTrainingStatus: BaseState(errorMessage: result.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  void _changeMuscleTab(String muscleId) {
    if (state.activeMuscleId == muscleId) return;
    emit(state.copyWith(activeMuscleId: muscleId));
    _fetchMusclesByGroupId(muscleId);
  }
}
