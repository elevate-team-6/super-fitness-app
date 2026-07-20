import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';

enum MealDetailsStatus { initial, loading, success, error }

/// Mirrors [FoodState]: loading and error live in state rather than on the UI
/// event stream, because this screen renders them inline.
final class MealDetailsState extends Equatable {
  final MealDetailsStatus status;
  final MealDetailsEntity? details;
  final String errorMessage;

  const MealDetailsState({
    this.status = MealDetailsStatus.initial,
    this.details,
    this.errorMessage = '',
  });

  MealDetailsState copyWith({
    MealDetailsStatus? status,
    MealDetailsEntity? details,
    String? errorMessage,
  }) => MealDetailsState(
    status: status ?? this.status,
    details: details ?? this.details,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, details, errorMessage];
}
