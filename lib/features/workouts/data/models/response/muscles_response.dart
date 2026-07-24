import 'package:super_fitness/features/workouts/data/models/response/muscle_group_model.dart';
import 'package:super_fitness/features/workouts/data/models/response/muscle_model.dart';

class MusclesResponse {
  final String? message;
  final MuscleGroupModel? muscleGroup;
  final List<MuscleModel>? muscles;

  const MusclesResponse({this.message, this.muscleGroup, this.muscles});

  factory MusclesResponse.fromJson(Map<String, dynamic> json) {
    return MusclesResponse(
      message: json['message'] as String?,
      muscleGroup: json['muscleGroup'] != null
          ? MuscleGroupModel.fromJson(
              json['muscleGroup'] as Map<String, dynamic>,
            )
          : null,
      muscles: (json['muscles'] as List?)
          ?.map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
