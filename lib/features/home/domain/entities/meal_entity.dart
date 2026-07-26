import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final String id;
  final String name;
  final String thumbnail;

  const MealEntity({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [id, name, thumbnail];
}
