import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

enum FoodStatus { initial, loading, success, error }

final class FoodState extends Equatable {
  final MealTime selectedMealTime;
  final FoodStatus status;
  final List<MealEntity> meals;
  final String errorMessage;

  const FoodState({
    this.selectedMealTime = MealTime.breakfast,
    this.status = FoodStatus.initial,
    this.meals = const [],
    this.errorMessage = '',
  });

  FoodState copyWith({
    MealTime? selectedMealTime,
    FoodStatus? status,
    List<MealEntity>? meals,
    String? errorMessage,
  }) => FoodState(
    selectedMealTime: selectedMealTime ?? this.selectedMealTime,
    status: status ?? this.status,
    meals: meals ?? this.meals,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [selectedMealTime, status, meals, errorMessage];
}
