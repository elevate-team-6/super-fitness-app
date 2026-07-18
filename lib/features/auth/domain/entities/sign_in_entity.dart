import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

class SignInEntity extends Equatable {
  final String? message;
  final String? token;
  final UserEntity? user;

  const SignInEntity({this.message, this.token, this.user});

  @override
  List<Object?> get props => [message, token, user];
}
