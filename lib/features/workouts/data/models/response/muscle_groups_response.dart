import 'package:super_fitness/features/workouts/data/models/response/muscle_group_model.dart';

class MuscleGroupsResponse {
  final String? message;
  final List<MuscleGroupModel>? musclesGroup;

  const MuscleGroupsResponse({this.message, this.musclesGroup});

  factory MuscleGroupsResponse.fromJson(Map<String, dynamic> json) {
    return MuscleGroupsResponse(
      message: json['message'] as String?,
      musclesGroup: (json['musclesGroup'] as List?)
          ?.map((e) => MuscleGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
