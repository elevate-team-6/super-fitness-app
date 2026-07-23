import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';

class MuscleGroupModel {
  final String? id;
  final String? name;

  const MuscleGroupModel({this.id, this.name});

  factory MuscleGroupModel.fromJson(Map<String, dynamic> json) {
    return MuscleGroupModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
    );
  }

  MuscleGroupEntity toEntity() =>
      MuscleGroupEntity(id: id ?? '', name: name ?? '');
}
