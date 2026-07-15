import 'package:injectable/injectable.dart';
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
      case ForgotPasswordEvent():
        _forgotPassword(event.email);

      case VerifyResetCodeEvent():
        _verifyResetCode(event.resetCode, event.email);

      case ResetPasswordEvent():
        _resetPassword(event.email, event.newPassword);
    }
  }

  Future<void> _forgotPassword(String email) async {
    emit(state.copyWith(forgotPasswordState: const BaseState(isLoading: true)));

    final response = await _forgotPasswordUseCase(email: email);

    emit(state.copyWith(forgotPasswordState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.verificationCodeSentToYourEmail),
        );

        emitUiEvent(NavigateEvent(AppRoutes.verifyResetCode, arguments: email));

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }

  Future<void> _verifyResetCode(String resetCode, String email) async {
    emit(
      state.copyWith(verifyResetCodeState: const BaseState(isLoading: true)),
    );

    final response = await _verifyResetCodeUseCase(resetCode: resetCode);

    emit(state.copyWith(verifyResetCodeState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplaySuccessEvent(AppStrings.verificationCodeIsCorrect));

        emitUiEvent(NavigateEvent(AppRoutes.resetPassword, arguments: email));

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }

  Future<void> _resetPassword(String email, String newPassword) async {
    emit(state.copyWith(resetPasswordState: const BaseState(isLoading: true)));

    final response = await _resetPasswordUseCase(
      email: email,
      newPassword: newPassword,
    );

    emit(state.copyWith(resetPasswordState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplaySuccessEvent(AppStrings.passwordResetSuccessfully));

        emitUiEvent(
          NavigateEvent(
            AppRoutes.login,
            navigationType: NavigationType.pushAndRemoveUntil,
            predicate: (_) => false,
          ),
        );

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }
}
