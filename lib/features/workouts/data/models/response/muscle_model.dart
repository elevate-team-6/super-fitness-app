import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';

class MuscleModel {
  final String? id;
  final String? name;
  final String? image;

  const MuscleModel({this.id, this.name, this.image});

  factory MuscleModel.fromJson(Map<String, dynamic> json) {
    return MuscleModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }

  MuscleEntity toEntity() => MuscleEntity(
    id: id ?? '',
    name: name ?? '',
    image: image ?? '',
  );
}
