sealed class ChangePasswordEvents {}

class UpdatePasswordsEvent extends ChangePasswordEvents {
  final String? oldPassword;
  final String? newPassword;
  final String? confirmPassword;

  UpdatePasswordsEvent({
    this.oldPassword,
    this.newPassword,
    this.confirmPassword,
  });
}

class ChangePasswordEvent extends ChangePasswordEvents {}

class ToggleOldPasswordVisibilityEvent extends ChangePasswordEvents {}

class ToggleNewPasswordVisibilityEvent extends ChangePasswordEvents {}

class ToggleConfirmPasswordVisibilityEvent extends ChangePasswordEvents {}
