import 'package:equatable/equatable.dart';

class MuscleEntity extends Equatable {
  final String? id;
  final String? name;

  const MuscleEntity({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}
