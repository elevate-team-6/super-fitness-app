import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/change_password_use_case.dart';
import 'change_password_events.dart';
import 'change_password_state.dart';

@injectable
class ChangePasswordCubit
    extends BaseCubit<ChangePasswordState, BaseUiEvent> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordCubit(this._changePasswordUseCase)
      : super(const ChangePasswordState());

  void doEvent(ChangePasswordEvents event) {
    switch (event) {
      case UpdatePasswordsEvent():
        _updatePasswords(event);
      case ChangePasswordEvent():
        _changePassword();
      case ToggleOldPasswordVisibilityEvent():
        emit(state.copyWith(obscureOldPassword: !state.obscureOldPassword));
      case ToggleNewPasswordVisibilityEvent():
        emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));
      case ToggleConfirmPasswordVisibilityEvent():
        emit(
          state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
        );
    }
  }

  void _updatePasswords(UpdatePasswordsEvent event) {
    emit(
      state.copyWith(
        oldPassword: event.oldPassword ?? state.oldPassword,
        newPassword: event.newPassword ?? state.newPassword,
        confirmPassword: event.confirmPassword ?? state.confirmPassword,
      ),
    );
    _validateForm();
  }

  void _validateForm() {
    final oldNotEmpty = state.oldPassword.isNotEmpty;
    final newValid =
        AppValidations.validatePassword(state.newPassword) == null;
    final confirmMatches =
        AppValidations.validateConfirmPassword(
              state.confirmPassword,
              state.newPassword,
            ) ==
            null;
    final notSameAsOld = state.newPassword != state.oldPassword;

    emit(
      state.copyWith(
        isFormValid: oldNotEmpty && newValid && confirmMatches && notSameAsOld,
      ),
    );
  }

  Future<void> _changePassword() async {
    emitUiEvent(ShowLoadingEvent());
    emit(
      state.copyWith(changePasswordState: const BaseState(isLoading: true)),
    );

    final response = await _changePasswordUseCase(
      password: state.oldPassword,
      newPassword: state.newPassword,
    );

    emitUiEvent(HideLoadingEvent());
    emit(state.copyWith(changePasswordState: const BaseState()));

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.changePasswordSuccess.tr()),
        );
        emitUiEvent(NavigateEvent('', navigationType: NavigationType.pop));

      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage.tr()));
    }
  }
}
