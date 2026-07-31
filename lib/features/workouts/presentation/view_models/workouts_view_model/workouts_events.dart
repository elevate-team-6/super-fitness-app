sealed class WorkoutsEvents {}

class GetMuscleGroupsEvent extends WorkoutsEvents {}

class GetMusclesByGroupIdEvent extends WorkoutsEvents {
  final String id;

  GetMusclesByGroupIdEvent(this.id);
}
