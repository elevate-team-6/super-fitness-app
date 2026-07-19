sealed class ForgotPasswordEvents {}

class UpdateStepEvent extends ForgotPasswordEvents {
  final int step;
  UpdateStepEvent(this.step);
}

class StartResendTimerEvent extends ForgotPasswordEvents {}

class DecrementTimerEvent extends ForgotPasswordEvents {}

class UpdateForgotPasswordInfoEvent extends ForgotPasswordEvents {
  final String? email;
  final String? otpCode;
  final String? newPassword;

  UpdateForgotPasswordInfoEvent({this.email, this.otpCode, this.newPassword});
}

class ForgotPasswordEvent extends ForgotPasswordEvents {}

class VerifyResetCodeEvent extends ForgotPasswordEvents {}

class ResetPasswordEvent extends ForgotPasswordEvents {}
