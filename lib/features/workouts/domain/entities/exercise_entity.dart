import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String difficulty;
  final String targetMuscle;
  final String image;
  final String duration;
  final String videoUrl;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.targetMuscle,
    required this.image,
    required this.duration,
    required this.videoUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    difficulty,
    targetMuscle,
    image,
    duration,
    videoUrl,
  ];
}
