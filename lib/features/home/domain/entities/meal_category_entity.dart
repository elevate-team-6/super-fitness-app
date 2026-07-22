import 'package:equatable/equatable.dart';

class MealCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String image;

  const MealCategoryEntity({
    required this.id,
    required this.name,
    required this.image,
  });

  static const MealCategoryEntity empty = MealCategoryEntity(
    id: '',
    name: 'Loading...',
    image: '',
  );

  @override
  List<Object?> get props => [id, name, image];
}
