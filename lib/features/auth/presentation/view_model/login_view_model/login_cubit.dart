import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/config/services/google_password_derivation.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:super_fitness/features/auth/presentation/widgets/google_signup_args.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final SignInUseCase _signInUseCase;
  final SecureCacheHelper _secureCacheHelper;
  final GoogleAuthService _googleAuthService;

  LoginCubit(
    this._signInUseCase,
    this._secureCacheHelper,
    this._googleAuthService,
  ) : super(const LoginState());

  void doIntent(LoginEvents event) {
    switch (event) {
      case TogglePasswordVisibilityEvent():
        _togglePasswordVisibility();
      case LoginEvent(:final request):
        _signIn(request);
      case GoogleLoginEvent():
        _signInWithGoogle();
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
      case SuccessBaseResponse<SignInEntity>():
        final entity = result.data ?? const SignInEntity();
        await _cacheUserSession(entity);
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

  /// Signs in with Google.
  ///
  /// Our backend has no Google endpoint yet, so we bridge it with the regular
  /// email/password endpoints and a password derived from the Google uid
  /// (see [GooglePasswordDerivation]). Signin doubles as the "does this user
  /// exist?" check: the API returns the same 401 for an unknown email and a
  /// wrong password, so a failure is treated as a first-time user and sends
  /// them into the register flow to fill in the fitness details Google can't
  /// provide.
  ///
  /// TODO(SF-XX): replace all of this with POST /auth/google once the backend
  /// can trade a Firebase ID token for one of our tokens.
  Future<void> _signInWithGoogle() async {
    emitUiEvent(ShowLoadingEvent());

    try {
      final account = await _googleAuthService.signIn();

      // The user dismissed the account picker — nothing to report.
      if (account == null) {
        emitUiEvent(HideLoadingEvent());
        return;
      }

      final password = GooglePasswordDerivation.fromUid(account.uid);
      final result = await _signInUseCase(
        SignInRequestModel(email: account.email, password: password),
      );

      emitUiEvent(HideLoadingEvent());

      switch (result) {
        // Returning user — straight into the app.
        case SuccessBaseResponse<SignInEntity>():
          final entity = result.data ?? const SignInEntity();
          await _cacheUserSession(entity);
          emitUiEvent(DisplaySuccessEvent(AppStrings.loginSuccess.tr()));
          emitUiEvent(
            NavigateEvent(
              AppRoutes.mainLayout,
              navigationType: NavigationType.pushAndRemoveUntil,
            ),
          );

        // First time with this Google account — collect the rest and sign up.
        case ErrorBaseResponse<SignInEntity>():
          emitUiEvent(
            NavigateEvent(
              AppRoutes.completeRegister,
              arguments: GoogleSignupArgs(
                firstName: account.firstName ?? '',
                lastName: account.lastName ?? '',
                email: account.email,
                password: password,
              ),
            ),
          );
      }
    } catch (_) {
      emitUiEvent(HideLoadingEvent());
      emitUiEvent(DisplayErrorEvent(AppStrings.somethingWentWrong.tr()));
    }
  }

  /// Persists the session after a successful login: the auth token and the full
  /// user data, so the app keeps the user signed in on the next launch
  /// (per the acceptance criteria).
  Future<void> _cacheUserSession(SignInEntity entity) async {
    final token = entity.token;
    if (token != null && token.isNotEmpty) {
      await _secureCacheHelper.writeData(key: AppKeys.tokenKey, value: token);
    }

    // Save the full user data locally so the app can use it offline / on resume.
    final user = entity.user;
    if (user == null) return;

    final userJson = jsonEncode(
      UserModel(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        gender: user.gender,
        age: user.age,
        weight: user.weight,
        height: user.height,
        activityLevel: user.activityLevel,
        goal: user.goal,
        photo: user.photo,
        createdAt: user.createdAt,
      ).toJson(),
    );
    await _secureCacheHelper.writeData(
      key: AppKeys.userDataKey,
      value: userJson,
    );

    final userId = user.id;
    if (userId != null) {
      await _secureCacheHelper.writeData(key: AppKeys.userIdKey, value: userId);
    }
  }
}
