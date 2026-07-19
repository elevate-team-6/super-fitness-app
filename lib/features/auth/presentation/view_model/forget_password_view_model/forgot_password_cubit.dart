import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:super_fitness/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:super_fitness/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'forgot_password_events.dart';
import 'forgot_password_state.dart';

@injectable
class ForgotPasswordCubit extends BaseCubit<ForgotPasswordState, BaseUiEvent> {
  final ForgetPasswordUseCase _forgotPasswordUseCase;
  final VerifyResetCodeUseCase _verifyResetCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  Timer? _resendTimer;

  ForgotPasswordCubit({
    required ForgetPasswordUseCase forgotPasswordUseCase,
    required VerifyResetCodeUseCase verifyResetCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _forgotPasswordUseCase = forgotPasswordUseCase,
       _verifyResetCodeUseCase = verifyResetCodeUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       super(const ForgotPasswordState());

  void doEvent(ForgotPasswordEvents event) {
    switch (event) {
      case UpdateStepEvent():
        emit(state.copyWith(currentStep: event.step));
      case StartResendTimerEvent():
        _startResendTimer();
      case DecrementTimerEvent():
        _decrementTimer();
      case UpdateForgotPasswordInfoEvent():
        emit(
          state.copyWith(
            email: event.email ?? state.email,
            otpCode: event.otpCode ?? state.otpCode,
            newPassword: event.newPassword ?? state.newPassword,
          ),
        );
      case ForgotPasswordEvent():
        _forgotPassword();
      case VerifyResetCodeEvent():
        _verifyResetCode();
      case ResetPasswordEvent():
        _resetPassword();
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    emit(state.copyWith(resendTimer: 30));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      doEvent(DecrementTimerEvent());
    });
  }

  void _decrementTimer() {
    if (state.resendTimer > 0) {
      emit(state.copyWith(resendTimer: state.resendTimer - 1));
    } else {
      _resendTimer?.cancel();
    }
  }

  Future<void> _forgotPassword() async {
    emitUiEvent(ShowLoadingEvent());
    emit(state.copyWith(forgotPasswordState: const BaseState(isLoading: true)));

    final response = await _forgotPasswordUseCase(email: state.email);

    emitUiEvent(HideLoadingEvent());
    emit(state.copyWith(forgotPasswordState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.verificationCodeSentToYourEmail.tr()),
        );
        emit(state.copyWith(currentStep: 1));
        _startResendTimer();

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  Future<void> _verifyResetCode() async {
    emitUiEvent(ShowLoadingEvent());
    emit(
      state.copyWith(verifyResetCodeState: const BaseState(isLoading: true)),
    );

    final response = await _verifyResetCodeUseCase(resetCode: state.otpCode);

    emitUiEvent(HideLoadingEvent());
    emit(state.copyWith(verifyResetCodeState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplaySuccessEvent(AppStrings.verificationCodeIsCorrect.tr()));
        emit(state.copyWith(currentStep: 2));

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  Future<void> _resetPassword() async {
    emitUiEvent(ShowLoadingEvent());
    emit(state.copyWith(resetPasswordState: const BaseState(isLoading: true)));

    final response = await _resetPasswordUseCase(
      email: state.email,
      newPassword: state.newPassword,
    );

    emitUiEvent(HideLoadingEvent());
    emit(state.copyWith(resetPasswordState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplaySuccessEvent(AppStrings.passwordResetSuccessfully.tr()));

        emitUiEvent(
          NavigateEvent(
            AppRoutes.login,
            navigationType: NavigationType.pushAndRemoveUntil,
            predicate: (_) => false,
          ),
        );
        await close();

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
