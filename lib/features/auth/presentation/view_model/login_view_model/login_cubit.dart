import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/social_signup_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import 'package:super_fitness/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final SignInUseCase _signInUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;

  LoginCubit(
    this._signInUseCase,
    this._googleSignInUseCase,
    this._facebookSignInUseCase,
  ) : super(const LoginState());

  void doIntent(LoginEvents event) {
    switch (event) {
      case TogglePasswordVisibilityEvent():
        _togglePasswordVisibility();
      case LoginEvent(:final request):
        _signIn(request);
      case GoogleLoginEvent():
        _signInWithGoogle();
      case FacebookLoginEvent():
        _signInWithFacebook();
    }
  }

  void _togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _signIn(SignInRequestModel request) async {
    emitUiEvent(ShowLoadingEvent());

    final result = await _signInUseCase(request);

    emitUiEvent(HideLoadingEvent());

    _handleSignInResult(result);
  }

  Future<void> _signInWithGoogle() async {
    emitUiEvent(ShowLoadingEvent());

    final result = await _googleSignInUseCase();

    emitUiEvent(HideLoadingEvent());

    _handleSignInResult(result);
  }

  Future<void> _signInWithFacebook() async {
    emitUiEvent(ShowLoadingEvent());

    final result = await _facebookSignInUseCase();

    emitUiEvent(HideLoadingEvent());

    _handleSignInResult(result);
  }

  void _handleSignInResult(BaseResponse<dynamic> result) {
    switch (result) {
      case SuccessBaseResponse<SignInEntity>():
        emitUiEvent(DisplaySuccessEvent(AppStrings.loginSuccess.tr()));
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
          ),
        );
      case SuccessBaseResponse<SocialSignupEntity>():
        emitUiEvent(
          NavigateEvent(
            AppRoutes.completeRegister,
            arguments: CompleteRegisterArgs(socialData: result.data),
          ),
        );
      case SuccessBaseResponse():
        // Handle unexpected success types if any
        break;
      case ErrorBaseResponse():
        emitUiEvent(DisplayErrorEvent(result.errorMessage.tr()));
    }
  }
}
