import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_nutrition_entity.dart';

enum DetailsFoodStatus { initial, loading, success, error }

final class DetailsFoodState extends Equatable {
  final DetailsFoodStatus status;
  final DetailsFoodEntity? details;
  final String errorMessage;

  final DetailsFoodStatus nutritionStatus;
  final MealNutritionEntity? nutrition;

  const DetailsFoodState({
    this.status = DetailsFoodStatus.initial,
    this.details,
    this.errorMessage = '',
    this.nutritionStatus = DetailsFoodStatus.initial,
    this.nutrition,
  });

  DetailsFoodState copyWith({
    DetailsFoodStatus? status,
    DetailsFoodEntity? details,
    String? errorMessage,
    DetailsFoodStatus? nutritionStatus,
    MealNutritionEntity? nutrition,
  }) => DetailsFoodState(
    status: status ?? this.status,
    details: details ?? this.details,
    errorMessage: errorMessage ?? this.errorMessage,
    nutritionStatus: nutritionStatus ?? this.nutritionStatus,
    nutrition: nutrition ?? this.nutrition,
  );

  @override
  List<Object?> get props => [
    status,
    details,
    errorMessage,
    nutritionStatus,
    nutrition,
  ];
}
