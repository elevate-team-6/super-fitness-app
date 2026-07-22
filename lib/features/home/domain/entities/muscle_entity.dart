import 'package:equatable/equatable.dart';

class MuscleEntity extends Equatable {
  final String id;
  final String name;

  const MuscleEntity({required this.id, required this.name});

  static const MuscleEntity empty = MuscleEntity(id: '', name: 'Loading...');

  @override
  List<Object?> get props => [id, name];
}
