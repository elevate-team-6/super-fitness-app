import 'package:equatable/equatable.dart';

class MealCategoryEntity extends Equatable {
  final String? id;
  final String? name;
  final String? image;

  const MealCategoryEntity({this.id, this.name, this.image});

  @override
  List<Object?> get props => [id, name, image];
}
