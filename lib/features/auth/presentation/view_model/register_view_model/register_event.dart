sealed class RegisterEvent {
  const RegisterEvent();
}

class UpdateAccountInfoEvent extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const UpdateAccountInfoEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
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

/// Fills the account step from a Google account and jumps straight to the
/// first fitness question — the user never sees the email/password step.
class PrefillFromGoogleEvent extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  PrefillFromGoogleEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}
