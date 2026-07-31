import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

class EditProfileState extends Equatable {
  final UserEntity? originalUser;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final int age;
  final int weight;
  final int height;
  final String goal;
  final String activityLevel;
  final File? selectedImage;
  final BaseState<UserEntity> updateProfileState;

  const EditProfileState({
    this.originalUser,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.gender = '',
    this.age = 20,
    this.weight = 70,
    this.height = 170,
    this.goal = '',
    this.activityLevel = '',
    this.selectedImage,
    this.updateProfileState = const BaseState(),
  });

  bool get isFormValid =>
      AppValidations.validateFirstName(firstName) == null &&
      AppValidations.validateLastName(lastName) == null &&
      AppValidations.validateEmail(email) == null;

  bool get hasChanges {
    if (originalUser == null) return false;
    final orig = originalUser!;

    if (selectedImage != null) return true;

    if (firstName.trim() != (orig.firstName ?? '').trim()) return true;
    if (lastName.trim() != (orig.lastName ?? '').trim()) return true;
    if (email.trim() != (orig.email ?? '').trim()) return true;
    if (gender != (orig.gender ?? '')) return true;

    final int origAge = orig.age ?? 20;
    if (age != origAge) return true;

    final int origWeight = orig.weight?.toInt() ?? 70;
    if (weight != origWeight) return true;

    final int origHeight = orig.height?.toInt() ?? 170;
    if (height != origHeight) return true;

    if (goal != (orig.goal ?? '')) return true;

    final String currentApiLevel = _mapToApiActivityLevel(activityLevel);
    final String origApiLevel = _mapToApiActivityLevel(orig.activityLevel ?? '');
    if (currentApiLevel != origApiLevel) return true;

    return false;
  }

  static String _mapToApiActivityLevel(String level) {
    switch (level) {
      case AppStrings.sedentary:
      case 'level1':
        return 'level1';
      case AppStrings.lightlyActive:
      case 'level2':
        return 'level2';
      case AppStrings.moderatelyActive:
      case 'level3':
        return 'level3';
      case AppStrings.veryActive:
      case 'level4':
        return 'level4';
      case AppStrings.extraActive:
      case 'level5':
        return 'level5';
      default:
        return level;
    }
  }

  EditProfileState copyWith({
    UserEntity? originalUser,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    int? age,
    int? weight,
    int? height,
    String? goal,
    String? activityLevel,
    File? selectedImage,
    bool clearSelectedImage = false,
    BaseState<UserEntity>? updateProfileState,
  }) {
    return EditProfileState(
      originalUser: originalUser ?? this.originalUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      selectedImage: clearSelectedImage ? null : (selectedImage ?? this.selectedImage),
      updateProfileState: updateProfileState ?? this.updateProfileState,
    );
  }

  @override
  List<Object?> get props => [
    originalUser,
    firstName,
    lastName,
    email,
    gender,
    age,
    weight,
    height,
    goal,
    activityLevel,
    selectedImage,
    updateProfileState,
  ];
}
