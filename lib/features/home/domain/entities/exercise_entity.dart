import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String difficulty;
  final String targetMuscle;
  final String videoUrl;
  final String image;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.targetMuscle,
    required this.videoUrl,
    required this.image,
  });

  static const ExerciseEntity empty = ExerciseEntity(
    id: '',
    name: 'Loading Exercise...',
    difficulty: 'Beginner',
    targetMuscle: '',
    videoUrl: '',
    image: '',
  );

  @override
  List<Object?> get props => [
    id,
    name,
    difficulty,
    targetMuscle,
    videoUrl,
    image,
  ];
}
