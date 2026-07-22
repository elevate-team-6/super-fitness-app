import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String? id;
  final String? name;
  final String? difficulty;
  final String? targetMuscle;
  final String? videoUrl;

  const ExerciseEntity({
    this.id,
    this.name,
    this.difficulty,
    this.targetMuscle,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [id, name, difficulty, targetMuscle, videoUrl];
}
