import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

sealed class EditProfileEvents extends Equatable {
  const EditProfileEvents();

  @override
  List<Object?> get props => [];
}

class InitializeProfileEvent extends EditProfileEvents {
  final UserEntity user;
  const InitializeProfileEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateFirstNameEvent extends EditProfileEvents {
  final String firstName;
  const UpdateFirstNameEvent(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

class UpdateLastNameEvent extends EditProfileEvents {
  final String lastName;
  const UpdateLastNameEvent(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

class UpdateEmailEvent extends EditProfileEvents {
  final String email;
  const UpdateEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class UpdateImageEvent extends EditProfileEvents {
  final File image;
  const UpdateImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class UpdateGenderEvent extends EditProfileEvents {
  final String gender;
  const UpdateGenderEvent(this.gender);

  @override
  List<Object?> get props => [gender];
}

class UpdateAgeEvent extends EditProfileEvents {
  final int age;
  const UpdateAgeEvent(this.age);

  @override
  List<Object?> get props => [age];
}

class UpdateWeightEvent extends EditProfileEvents {
  final int weight;
  const UpdateWeightEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

class UpdateHeightEvent extends EditProfileEvents {
  final int height;
  const UpdateHeightEvent(this.height);

  @override
  List<Object?> get props => [height];
}

class UpdateGoalEvent extends EditProfileEvents {
  final String goal;
  const UpdateGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateActivityEvent extends EditProfileEvents {
  final String activityLevel;
  const UpdateActivityEvent(this.activityLevel);

  @override
  List<Object?> get props => [activityLevel];
}

class SaveProfileEvent extends EditProfileEvents {
  const SaveProfileEvent();
}
