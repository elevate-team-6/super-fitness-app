import 'package:equatable/equatable.dart';

class MuscleEntity extends Equatable {
  final String id;
  final String name;
  final String? image;

  const MuscleEntity({required this.id, required this.name, this.image});

  static const MuscleEntity empty = MuscleEntity(
    id: '',
    name: 'Loading...',
    image: null,
  );

  @override
  List<Object?> get props => [id, name, image];
}
