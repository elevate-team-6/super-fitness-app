import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_meal_time_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_state.dart';

@injectable
class FoodCubit extends BaseCubit<FoodState, BaseUiEvent> {
  final GetMealsByMealTimeUseCase _getMealsByMealTimeUseCase;

  /// Keeps already-loaded meal times around so switching tabs back and forth
  /// doesn't re-hit the network.
  final Map<MealTime, List<MealEntity>> _cache = {};

  FoodCubit(this._getMealsByMealTimeUseCase) : super(const FoodState());

  void doIntent(FoodEvents event) {
    switch (event) {
      case LoadMealsEvent():
        _loadMeals(state.selectedMealTime);
      case SelectMealTimeEvent(:final mealTime):
        _selectMealTime(mealTime);
    }
  }

  void _selectMealTime(MealTime mealTime) {
    // `initial` still needs a fetch even when the meal time already matches —
    // that's the case when the route opens straight onto Breakfast.
    if (mealTime == state.selectedMealTime &&
        state.status != FoodStatus.initial) {
      return;
    }

    final cached = _cache[mealTime];
    if (cached != null) {
      emit(
        state.copyWith(
          selectedMealTime: mealTime,
          status: FoodStatus.success,
          meals: cached,
        ),
      );
      return;
    }

    emit(state.copyWith(selectedMealTime: mealTime));
    _loadMeals(mealTime);
  }

  Future<void> _loadMeals(MealTime mealTime) async {
    emit(state.copyWith(status: FoodStatus.loading, meals: const []));

    final result = await _getMealsByMealTimeUseCase(mealTime);

    // The user may have switched tabs while this was in flight — dropping the
    // stale response keeps the list matching the selected tab.
    if (isClosed || mealTime != state.selectedMealTime) return;

    switch (result) {
      case SuccessBaseResponse<List<MealEntity>>():
        final meals = result.data ?? const <MealEntity>[];
        _cache[mealTime] = meals;
        emit(state.copyWith(status: FoodStatus.success, meals: meals));

      case ErrorBaseResponse<List<MealEntity>>():
        emit(
          state.copyWith(
            status: FoodStatus.error,
            errorMessage: result.errorMessage,
          ),
        );
    }
  }
}
