import '../../../domain/entities/social_account_entity.dart';

/// Profile data we get back from a social provider (Google, Facebook, ...).
/// Everything else the signup needs — gender, age, weight, height, goal,
/// activityLevel — has to be collected from the onboarding screens.
class SocialAccountModel {
  /// Stable per-account id from Firebase Auth. Same value on any device, which
  /// is what lets us derive a repeatable password for our own API.
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? photo;

  const SocialAccountModel({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.photo,
  });

  SocialAccountEntity toEntity() {
    return SocialAccountEntity(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      photo: photo,
    );
  }
}
