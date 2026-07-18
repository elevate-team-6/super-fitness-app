import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';

sealed class LoginEvents extends Equatable {
  const LoginEvents();

  @override
  List<Object?> get props => [];
}

class TogglePasswordVisibilityEvent extends LoginEvents {
  const TogglePasswordVisibilityEvent();
}

class LoginEvent extends LoginEvents {
  final SignInRequestModel request;

  const LoginEvent(this.request);

  @override
  List<Object?> get props => [request];
}
