import 'package:equatable/equatable.dart';

class IngredientEntity extends Equatable {
  final String name;
  final String measure;

  const IngredientEntity({
    required this.name,
    required this.measure,
  });

  @override
  List<Object?> get props => [name, measure];
}
