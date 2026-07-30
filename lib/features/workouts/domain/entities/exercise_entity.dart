import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String exercise;
  final String difficultyLevel;
  final String targetMuscleGroup;
  final String primeMoverMuscle;
  final String primaryEquipment;
  final String secondaryEquipment;
  final String posture;
  final String grip;
  final String forceType;
  final String secondaryMuscles;
  final String tertiaryMuscles;
  final String bodyRegion;
  final String mechanics;
  final String laterality;
  final String primaryExerciseClassification;
  final String shortYoutubeDemonstrationLink;
  final String inDepthYoutubeExplanationLink;

  const ExerciseEntity({
    required this.id,
    required this.exercise,
    required this.difficultyLevel,
    required this.targetMuscleGroup,
    required this.primeMoverMuscle,
    required this.primaryEquipment,
    required this.secondaryEquipment,
    required this.posture,
    required this.grip,
    required this.forceType,
    required this.secondaryMuscles,
    required this.tertiaryMuscles,
    required this.bodyRegion,
    required this.mechanics,
    required this.laterality,
    required this.primaryExerciseClassification,
    required this.shortYoutubeDemonstrationLink,
    required this.inDepthYoutubeExplanationLink,
  });

  static const ExerciseEntity empty = ExerciseEntity(
    id: '',
    exercise: 'Loading Exercise...',
    difficultyLevel: 'Beginner',
    targetMuscleGroup: '',
    primeMoverMuscle: '',
    primaryEquipment: '',
    secondaryEquipment: '',
    posture: '',
    grip: '',
    forceType: '',
    secondaryMuscles: '',
    tertiaryMuscles: '',
    bodyRegion: '',
    mechanics: '',
    laterality: '',
    primaryExerciseClassification: '',
    shortYoutubeDemonstrationLink: '',
    inDepthYoutubeExplanationLink: '',
  );

  // Legacy fields for backward compatibility
  String get name => exercise;
  String get difficulty => difficultyLevel;
  String get targetMuscle => targetMuscleGroup;
  String get videoUrl => shortYoutubeDemonstrationLink.isNotEmpty
      ? shortYoutubeDemonstrationLink
      : inDepthYoutubeExplanationLink;
  String get image =>
      'https://img.youtube.com/vi/${_extractVideoId(videoUrl)}/0.jpg';

  static String _extractVideoId(String url) {
    RegExp regExp = RegExp(
      r'^(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/|youtube\.com/v/|youtube\.com/shorts/)([^#&?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.groupCount >= 1) ? match.group(1)! : '';
  }

  @override
  List<Object?> get props => [
    id,
    exercise,
    difficultyLevel,
    targetMuscleGroup,
    primeMoverMuscle,
    primaryEquipment,
    secondaryEquipment,
    posture,
    grip,
    forceType,
    secondaryMuscles,
    tertiaryMuscles,
    bodyRegion,
    mechanics,
    laterality,
    primaryExerciseClassification,
    shortYoutubeDemonstrationLink,
    inDepthYoutubeExplanationLink,
  ];
}
