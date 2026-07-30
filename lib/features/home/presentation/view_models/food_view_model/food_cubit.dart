import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_by_category_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meals_categories_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_state.dart';

@injectable
class FoodCubit extends BaseCubit<FoodState, BaseUiEvent> {
  final GetMealsCategoriesUseCase _getMealsCategoriesUseCase;
  final GetMealsByCategoryUseCase _getMealsByCategoryUseCase;

  FoodCubit(this._getMealsCategoriesUseCase, this._getMealsByCategoryUseCase)
    : super(const FoodState());

  void doIntent(FoodEvents event) {
    switch (event) {
      case GetMealsCategoriesEvent():
        _getMealsCategories(initialCategory: event.initialCategory);
      case ChangeCategoryEvent():
        _changeCategory(event.category);
    }
  }

  Future<void> _getMealsCategories({String? initialCategory}) async {
    emit(
      state.copyWith(
        initialCategory: initialCategory ?? state.initialCategory,
        categoriesState: const BaseState(isLoading: true),
        mealsState: const BaseState(isLoading: true),
      ),
    );
    final result = await _getMealsCategoriesUseCase();

    switch (result) {
      case SuccessBaseResponse():
        final categories = result.data ?? [];
        String? selected;

        final target = initialCategory ?? state.initialCategory;

        if (target != null &&
            categories.any((element) => element.name == target)) {
          selected = target;
        } else {
          selected = categories.firstOrNull?.name;
        }

        emit(
          state.copyWith(
            categoriesState: BaseState(data: categories),
            selectedCategory: selected,
          ),
        );
        if (state.selectedCategory != null) {
          await _getMealsByCategory(state.selectedCategory!);
        }
      case ErrorBaseResponse():
        emit(
          state.copyWith(
            mealsState: BaseState(errorMessage: result.errorMessage),
            categoriesState: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }

  Future<void> _changeCategory(String category) async {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(selectedCategory: category));
    await _getMealsByCategory(category);
  }

  Future<void> _getMealsByCategory(String category) async {
    emit(state.copyWith(mealsState: const BaseState(isLoading: true)));
    final result = await _getMealsByCategoryUseCase(category);

    switch (result) {
      case SuccessBaseResponse():
        emit(state.copyWith(mealsState: BaseState(data: result.data)));
      case ErrorBaseResponse():
        emit(
          state.copyWith(
            mealsState: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }
}
