sealed class RegisterEvent {}

class UpdateAccountInfoEvent extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  UpdateAccountInfoEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class SelectGenderEvent extends RegisterEvent {
  final String gender;
  SelectGenderEvent(this.gender);
}

class UpdateAgeEvent extends RegisterEvent {
  final int age;
  UpdateAgeEvent(this.age);
}

class UpdateWeightEvent extends RegisterEvent {
  final int weight;
  UpdateWeightEvent(this.weight);
}

class UpdateHeightEvent extends RegisterEvent {
  final int height;
  UpdateHeightEvent(this.height);
}

class SelectGoalEvent extends RegisterEvent {
  final String goal;
  SelectGoalEvent(this.goal);
}

class SelectActivityLevelEvent extends RegisterEvent {
  final String level;
  SelectActivityLevelEvent(this.level);
}

class NextStepEvent extends RegisterEvent {}

class PreviousStepEvent extends RegisterEvent {}

class SubmitSignupEvent extends RegisterEvent {}
