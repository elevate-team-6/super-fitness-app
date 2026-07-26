import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';

final class DetailsFoodState extends Equatable {
  /// The async details fetch — loading, the loaded meal, or a failure.
  final BaseState<DetailsFoodEntity> detailsState;

  /// The meal this screen was opened with; the load reads it from here.
  final String mealId;

  const DetailsFoodState({
    this.detailsState = const BaseState(),
    this.mealId = '',
  });

  DetailsFoodState copyWith({
    BaseState<DetailsFoodEntity>? detailsState,
    String? mealId,
  }) => DetailsFoodState(
    detailsState: detailsState ?? this.detailsState,
    mealId: mealId ?? this.mealId,
  );

  @override
  List<Object?> get props => [detailsState, mealId];
}
