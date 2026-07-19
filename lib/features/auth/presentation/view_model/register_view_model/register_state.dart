import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/user_entity.dart';

class RegisterState extends Equatable {
  // Handles Loading, Success (UserEntity), and Error
  final BaseState<UserEntity> signupStatus;

  // Form Data
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;
  final int age;
  final int weight;
  final int height;
  final String goal;
  final String activityLevel;

  // Multi-step navigation (0-6)
  final int currentStep;

  const RegisterState({
    this.signupStatus = const BaseState(),
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.gender = '',
    this.age = 20,
    this.weight = 70,
    this.height = 170,
    this.goal = '',
    this.activityLevel = '',
    this.currentStep = 0,
  });

  RegisterState copyWith({
    BaseState<UserEntity>? signupStatus,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? gender,
    int? age,
    int? weight,
    int? height,
    String? goal,
    String? activityLevel,
    int? currentStep,
  }) {
    return RegisterState(
      signupStatus: signupStatus ?? this.signupStatus,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object?> get props => [
    signupStatus,
    firstName,
    lastName,
    email,
    password,
    gender,
    age,
    weight,
    height,
    goal,
    activityLevel,
    currentStep,
  ];
}
