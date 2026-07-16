sealed class RegisterEvent {
  const RegisterEvent();
}

class UpdateAccountInfoEvent extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  /// True when the data came from a social provider: the account step is
  /// already answered, so the flow jumps straight to the first fitness question.
  final bool skipAccountStep;

  const UpdateAccountInfoEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.skipAccountStep = false,
  });
}

class SelectGenderEvent extends RegisterEvent {
  final String gender;
  const SelectGenderEvent(this.gender);
}

class UpdateAgeEvent extends RegisterEvent {
  final int age;
  const UpdateAgeEvent(this.age);
}

class UpdateWeightEvent extends RegisterEvent {
  final int weight;
  const UpdateWeightEvent(this.weight);
}

class UpdateHeightEvent extends RegisterEvent {
  final int height;
  const UpdateHeightEvent(this.height);
}

class SelectGoalEvent extends RegisterEvent {
  final String goal;
  const SelectGoalEvent(this.goal);
}

class SelectActivityLevelEvent extends RegisterEvent {
  final String level;
  const SelectActivityLevelEvent(this.level);
}

class NextStepEvent extends RegisterEvent {
  const NextStepEvent();
}

class PreviousStepEvent extends RegisterEvent {
  const PreviousStepEvent();
}

class SubmitSignupEvent extends RegisterEvent {
  const SubmitSignupEvent();
}
