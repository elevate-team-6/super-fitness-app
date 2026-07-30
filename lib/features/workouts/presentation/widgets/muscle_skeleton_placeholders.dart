import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';

const MuscleEntity kSkeletonMuscle = MuscleEntity(
  id: '',
  name: 'Loading muscle',
  image: '',
);

const int kSkeletonMuscleCount = 6;

List<MuscleEntity> get skeletonMuscles =>
    List.filled(kSkeletonMuscleCount, kSkeletonMuscle);

const List<String> kSkeletonMuscleGroups = [
  'Loading',
  'Loading',
  'Loading',
  'Loading',
];
