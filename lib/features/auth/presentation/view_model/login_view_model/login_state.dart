import 'package:equatable/equatable.dart';

final class LoginState extends Equatable {
  final bool obscurePassword;

  const LoginState({this.obscurePassword = true});

  LoginState copyWith({bool? obscurePassword}) {
    return LoginState(obscurePassword: obscurePassword ?? this.obscurePassword);
  }

  @override
  List<Object?> get props => [obscurePassword];
}
