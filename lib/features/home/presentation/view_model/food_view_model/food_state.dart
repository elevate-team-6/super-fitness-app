import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

final class FoodState extends Equatable {
  final MealTime selectedMealTime;

  /// The async meals fetch for [selectedMealTime].
  final BaseState<List<MealEntity>> mealsState;

  const FoodState({
    this.selectedMealTime = MealTime.breakfast,
    this.mealsState = const BaseState(),
  });

  FoodState copyWith({
    MealTime? selectedMealTime,
    BaseState<List<MealEntity>>? mealsState,
  }) => FoodState(
    selectedMealTime: selectedMealTime ?? this.selectedMealTime,
    mealsState: mealsState ?? this.mealsState,
  );

  @override
  List<Object?> get props => [selectedMealTime, mealsState];
}
