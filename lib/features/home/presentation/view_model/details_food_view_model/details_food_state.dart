import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';

enum DetailsFoodStatus { initial, loading, success, error }

/// Mirrors [FoodState]: loading and error live in state rather than on the UI
/// event stream, because this screen renders them inline.
final class DetailsFoodState extends Equatable {
  final DetailsFoodStatus status;
  final DetailsFoodEntity? details;
  final String errorMessage;

  const DetailsFoodState({
    this.status = DetailsFoodStatus.initial,
    this.details,
    this.errorMessage = '',
  });

  DetailsFoodState copyWith({
    DetailsFoodStatus? status,
    DetailsFoodEntity? details,
    String? errorMessage,
  }) => DetailsFoodState(
    status: status ?? this.status,
    details: details ?? this.details,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, details, errorMessage];
}
