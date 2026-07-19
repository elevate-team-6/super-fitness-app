import 'package:equatable/equatable.dart';

class SocialAccountEntity extends Equatable {
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? photo;

  const SocialAccountEntity({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.photo,
  });

  @override
  List<Object?> get props => [uid, email, firstName, lastName, photo];
}
