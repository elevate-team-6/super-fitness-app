import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

enum FoodStatus { initial, loading, success, error }

/// Unlike the auth cubits, loading and error live in state rather than on the
/// UI event stream: this section renders inline inside Home, so a full-screen
/// loading dialog or a snackbar would be the wrong affordance.
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
