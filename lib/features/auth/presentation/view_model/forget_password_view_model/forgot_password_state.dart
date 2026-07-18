import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

class ForgotPasswordState extends Equatable {
  final int currentStep;
  final int resendTimer;
  final String email;
  final String otpCode;
  final String newPassword;
  final BaseState<ForgetPasswordEntity> forgotPasswordState;
  final BaseState<ForgetPasswordEntity> verifyResetCodeState;
  final BaseState<ForgetPasswordEntity> resetPasswordState;

  const ForgotPasswordState({
    this.currentStep = 0,
    this.resendTimer = 0,
    this.email = '',
    this.otpCode = '',
    this.newPassword = '',
    this.forgotPasswordState = const BaseState(),
    this.verifyResetCodeState = const BaseState(),
    this.resetPasswordState = const BaseState(),
  });

  ForgotPasswordState copyWith({
    int? currentStep,
    int? resendTimer,
    String? email,
    String? otpCode,
    String? newPassword,
    BaseState<ForgetPasswordEntity>? forgotPasswordState,
    BaseState<ForgetPasswordEntity>? verifyResetCodeState,
    BaseState<ForgetPasswordEntity>? resetPasswordState,
  }) {
    return ForgotPasswordState(
      currentStep: currentStep ?? this.currentStep,
      resendTimer: resendTimer ?? this.resendTimer,
      email: email ?? this.email,
      otpCode: otpCode ?? this.otpCode,
      newPassword: newPassword ?? this.newPassword,
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      verifyResetCodeState: verifyResetCodeState ?? this.verifyResetCodeState,
      resetPasswordState: resetPasswordState ?? this.resetPasswordState,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    resendTimer,
    email,
    otpCode,
    newPassword,
    forgotPasswordState,
    verifyResetCodeState,
    resetPasswordState,
  ];
}
