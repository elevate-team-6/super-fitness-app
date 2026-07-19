import 'package:super_fitness/features/auth/domain/entities/social_signup_entity.dart';

sealed class RegisterEvent {
  const RegisterEvent();
}

class InitializeFromSocialEvent extends RegisterEvent {
  final SocialSignupEntity socialData;
  const InitializeFromSocialEvent(this.socialData);
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

class GoogleLoginEvent extends RegisterEvent {
  const GoogleLoginEvent();
}

class FacebookLoginEvent extends RegisterEvent {
  const FacebookLoginEvent();
}
