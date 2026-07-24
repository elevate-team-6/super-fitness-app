import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_meal_time_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_state.dart';

@injectable
class FoodCubit extends BaseCubit<FoodState, BaseUiEvent> {
  final GetMealsByMealTimeUseCase _getMealsByMealTimeUseCase;

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
    // Re-selecting the current tab is a no-op once its load has started, but the
    // very first selection (still an untouched BaseState) has to fall through.
    final mealsState = state.mealsState;
    final isUntouched =
        !mealsState.isLoading &&
        mealsState.data == null &&
        mealsState.errorMessage == null;
    if (mealTime == state.selectedMealTime && !isUntouched) return;

    final cached = _cache[mealTime];
    if (cached != null) {
      emit(
        state.copyWith(
          selectedMealTime: mealTime,
          mealsState: BaseState(data: cached),
        ),
      );
      return;
    }

    emit(state.copyWith(selectedMealTime: mealTime));
    _loadMeals(mealTime);
  }

  Future<void> _loadMeals(MealTime mealTime) async {
    emit(state.copyWith(mealsState: const BaseState(isLoading: true)));

    final result = await _getMealsByMealTimeUseCase(mealTime);

    if (isClosed || mealTime != state.selectedMealTime) return;

    switch (result) {
      case SuccessBaseResponse<List<MealEntity>>():
        final meals = result.data ?? const <MealEntity>[];
        _cache[mealTime] = meals;
        emit(state.copyWith(mealsState: BaseState(data: meals)));

      case ErrorBaseResponse<List<MealEntity>>():
        emit(
          state.copyWith(
            mealsState: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }
}
