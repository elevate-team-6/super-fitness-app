import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final String id;
  final String name;
  final String thumbnail;
  final String? area;
  final String? country;

  const MealEntity({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.area,
    this.country,
  });

  @override
  List<Object?> get props => [id, name, thumbnail, area, country];
}
