import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';

final class FoodState extends Equatable {
  final BaseState<List<MealCategoryEntity>> categoriesState;
  final BaseState<List<MealEntity>> mealsState;
  final String? selectedCategory;
  final String? initialCategory;

  const FoodState({
    this.categoriesState = const BaseState(),
    this.mealsState = const BaseState(),
    this.selectedCategory,
    this.initialCategory,
  });

  FoodState copyWith({
    BaseState<List<MealCategoryEntity>>? categoriesState,
    BaseState<List<MealEntity>>? mealsState,
    String? selectedCategory,
    String? initialCategory,
  }) => FoodState(
    categoriesState: categoriesState ?? this.categoriesState,
    mealsState: mealsState ?? this.mealsState,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    initialCategory: initialCategory ?? this.initialCategory,
  );

  @override
  List<Object?> get props => [
    categoriesState,
    mealsState,
    selectedCategory,
    initialCategory,
  ];
}
