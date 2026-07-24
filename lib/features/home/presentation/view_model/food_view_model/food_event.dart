import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

sealed class FoodEvents extends Equatable {
  const FoodEvents();

  @override
  List<Object?> get props => [];
}

class LoadMealsEvent extends FoodEvents {
  const LoadMealsEvent();
}

class SelectMealTimeEvent extends FoodEvents {
  final MealTime mealTime;

  const SelectMealTimeEvent(this.mealTime);

  @override
  List<Object?> get props => [mealTime];
}
