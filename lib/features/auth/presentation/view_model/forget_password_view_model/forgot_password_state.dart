import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

class ForgotPasswordState extends Equatable {
  final BaseState<ForgetPasswordEntity> forgotPasswordState;
  final BaseState<ForgetPasswordEntity> verifyResetCodeState;
  final BaseState<ForgetPasswordEntity> resetPasswordState;

  const ForgotPasswordState({
    this.forgotPasswordState = const BaseState(),
    this.verifyResetCodeState = const BaseState(),
    this.resetPasswordState = const BaseState(),
  });

  ForgotPasswordState copyWith({
    BaseState<ForgetPasswordEntity>? forgotPasswordState,
    BaseState<ForgetPasswordEntity>? verifyResetCodeState,
    BaseState<ForgetPasswordEntity>? resetPasswordState,
  }) {
    return ForgotPasswordState(
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      verifyResetCodeState: verifyResetCodeState ?? this.verifyResetCodeState,
      resetPasswordState: resetPasswordState ?? this.resetPasswordState,
    );
  }

  @override
  List<Object?> get props => [
    forgotPasswordState,
    verifyResetCodeState,
    resetPasswordState,
  ];
}
