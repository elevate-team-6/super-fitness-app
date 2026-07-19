import 'package:equatable/equatable.dart';

/// Represents the data collected from a social provider that is required
/// to pre-fill the registration process.
class SocialSignupEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const SocialSignupEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password];
}
