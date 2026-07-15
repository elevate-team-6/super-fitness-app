sealed class ForgotPasswordEvents {}

class ForgotPasswordEvent extends ForgotPasswordEvents {
  final String email;

  ForgotPasswordEvent({required this.email});
}

class VerifyResetCodeEvent extends ForgotPasswordEvents {
  final String resetCode;
  final String email;

  VerifyResetCodeEvent({required this.resetCode, required this.email});
}

class ResetPasswordEvent extends ForgotPasswordEvents {
  final String email;
  final String newPassword;

  ResetPasswordEvent({required this.email, required this.newPassword});
}
