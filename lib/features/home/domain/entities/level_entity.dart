import 'package:equatable/equatable.dart';

class LevelEntity extends Equatable {
  final String id;
  final String name;

  const LevelEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
