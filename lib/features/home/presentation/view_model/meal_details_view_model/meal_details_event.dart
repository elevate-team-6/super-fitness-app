import 'package:equatable/equatable.dart';

sealed class MealDetailsEvents extends Equatable {
  const MealDetailsEvents();

  @override
  List<Object?> get props => [];
}

/// Fetches the meal the screen was opened with — also what the retry button
/// fires, so it carries no id of its own.
class LoadMealDetailsEvent extends MealDetailsEvents {
  const LoadMealDetailsEvent();
}
