import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

class ChangePasswordState extends Equatable {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool obscureOldPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool isFormValid;
  final BaseState<ForgetPasswordEntity> changePasswordState;

  const ChangePasswordState({
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureOldPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    this.isFormValid = false,
    this.changePasswordState = const BaseState(),
  });

  ChangePasswordState copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? obscureOldPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool? isFormValid,
    BaseState<ForgetPasswordEntity>? changePasswordState,
  }) {
    return ChangePasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureOldPassword: obscureOldPassword ?? this.obscureOldPassword,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isFormValid: isFormValid ?? this.isFormValid,
      changePasswordState: changePasswordState ?? this.changePasswordState,
    );
  }

  @override
  List<Object?> get props => [
    oldPassword,
    newPassword,
    confirmPassword,
    obscureOldPassword,
    obscureNewPassword,
    obscureConfirmPassword,
    isFormValid,
    changePasswordState,
  ];
}
