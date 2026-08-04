import 'package:equatable/equatable.dart';
import '../../../workouts/domain/entities/exercise_entity.dart';

enum ChatRefType { exercise, meal }

class ChatRefEntity extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String? videoUrl;
  final String? muscleGroup;
  final String? difficulty;
  final ChatRefType type;
  final bool
  isSnapshot; // True if loaded from Gateway fallback, False if hydrated from local SQLite
  final ExerciseEntity? exerciseInfo;

  const ChatRefEntity({
    required this.id,
    required this.name,
    this.image,
    this.videoUrl,
    this.muscleGroup,
    this.difficulty,
    required this.type,
    this.isSnapshot = false,
    this.exerciseInfo,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    videoUrl,
    muscleGroup,
    difficulty,
    type,
    isSnapshot,
    exerciseInfo,
  ];
}
