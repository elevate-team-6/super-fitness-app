import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/services/facebook_auth_service.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/config/services/social_account_data.dart';
import 'package:super_fitness/config/services/social_password_derivation.dart';
import 'package:super_fitness/config/services/social_signup_args.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final SignInUseCase _signInUseCase;
  final GoogleAuthService _googleAuthService;
  final FacebookAuthService _facebookAuthService;

  LoginCubit(
    this._signInUseCase,
    this._googleAuthService,
    this._facebookAuthService,
  ) : super(const LoginState());

  void doIntent(LoginEvents event) {
    switch (event) {
      case TogglePasswordVisibilityEvent():
        _togglePasswordVisibility();
      case LoginEvent(:final request):
        _signIn(request);
      case GoogleLoginEvent():
        _signInWithSocial(_googleAuthService.signIn);
      case FacebookLoginEvent():
        _signInWithSocial(_facebookAuthService.signIn);
    }
  }

  void _togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _signIn(SignInRequestModel request) async {
    emitUiEvent(ShowLoadingEvent());

    final result = await _signInUseCase(request);

    emitUiEvent(HideLoadingEvent());

    switch (result) {
      // The repo has already persisted the session by this point.
      case SuccessBaseResponse<SignInEntity>():
        emitUiEvent(DisplaySuccessEvent(AppStrings.loginSuccess.tr()));
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
          ),
        );
      case ErrorBaseResponse<SignInEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _signInWithSocial(
    Future<SocialAccountData?> Function() signIn,
  ) async {
    emitUiEvent(ShowLoadingEvent());

    try {
      final account = await signIn();

      // The user dismissed the provider's sheet — nothing to report.
      if (account == null) {
        emitUiEvent(HideLoadingEvent());
        return;
      }

      final password = SocialPasswordDerivation.fromEmail(account.email);
      final result = await _signInUseCase(
        SignInRequestModel(email: account.email, password: password),
      );

      emitUiEvent(HideLoadingEvent());

      switch (result) {
        // Returning user — straight into the app. The repo has already
        // persisted the session by this point.
        case SuccessBaseResponse<SignInEntity>():
          emitUiEvent(DisplaySuccessEvent(AppStrings.loginSuccess.tr()));
          emitUiEvent(
            NavigateEvent(
              AppRoutes.mainLayout,
              navigationType: NavigationType.pushAndRemoveUntil,
            ),
          );

        // First time with this account — collect the rest and sign up.
        case ErrorBaseResponse<SignInEntity>():
          emitUiEvent(
            NavigateEvent(
              AppRoutes.completeRegister,
              arguments: SocialSignupArgs(
                firstName: account.firstName ?? '',
                lastName: account.lastName ?? '',
                email: account.email,
                password: password,
              ),
            ),
          );
      }
    } catch (e) {
      emitUiEvent(HideLoadingEvent());

      String errorMessage = AppStrings.somethingWentWrong.tr();
      if (e is Exception) {
        // Strip "Exception: " prefix if present
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      emitUiEvent(DisplayErrorEvent(errorMessage));
    }
  }
}
