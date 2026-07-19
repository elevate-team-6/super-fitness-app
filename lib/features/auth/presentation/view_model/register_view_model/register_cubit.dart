import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../../core/utils/app_routes.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../data/models/request/signup_request.dart';
import '../../../domain/entities/social_signup_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/sign_in_entity.dart';
import '../../../domain/use_cases/facebook_sign_in_use_case.dart';
import '../../../domain/use_cases/google_sign_in_use_case.dart';
import '../../../domain/use_cases/signup_use_case.dart';
import 'register_event.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  final SignupUseCase _signupUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;

  RegisterCubit(
    this._signupUseCase,
    this._googleSignInUseCase,
    this._facebookSignInUseCase,
  ) : super(const RegisterState());

  void doEvent(RegisterEvent event) {
    switch (event) {
      case InitializeFromSocialEvent():
        _initializeFromSocial(event);
      case UpdateAccountInfoEvent():
        _updateAccountInfo(event);
      case SelectGenderEvent():
        _selectGender(event);
      case UpdateAgeEvent():
        _updateAge(event);
      case UpdateWeightEvent():
        _updateWeight(event);
      case UpdateHeightEvent():
        _updateHeight(event);
      case SelectGoalEvent():
        _selectGoal(event);
      case SelectActivityLevelEvent():
        _selectActivityLevel(event);
      case NextStepEvent():
        _onNextStep();
      case PreviousStepEvent():
        _onPreviousStep();
      case SubmitSignupEvent():
        _onSubmit();
      case GoogleLoginEvent():
        _signInWithGoogle();
      case FacebookLoginEvent():
        _signInWithFacebook();
    }
  }

  void _updateAccountInfo(UpdateAccountInfoEvent event) {
    emit(
      state.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
      ),
    );
  }

  void _initializeFromSocial(InitializeFromSocialEvent event) {
    emit(
      state.copyWith(
        firstName: event.socialData.firstName,
        lastName: event.socialData.lastName,
        email: event.socialData.email,
        password: event.socialData.password,
        currentStep: 1, // Skip the first screen (Account Info)
      ),
    );
  }

  void _selectGender(SelectGenderEvent event) {
    emit(state.copyWith(gender: event.gender));
  }

  void _updateAge(UpdateAgeEvent event) {
    emit(state.copyWith(age: event.age));
  }

  void _updateWeight(UpdateWeightEvent event) {
    emit(state.copyWith(weight: event.weight));
  }

  void _updateHeight(UpdateHeightEvent event) {
    emit(state.copyWith(height: event.height));
  }

  void _selectGoal(SelectGoalEvent event) {
    emit(state.copyWith(goal: event.goal));
  }

  void _selectActivityLevel(SelectActivityLevelEvent event) {
    emit(state.copyWith(activityLevel: event.level));
  }

  void _onNextStep() {
    if (state.currentStep < 6) {
      if (state.currentStep == 0) {
        emitUiEvent(
          NavigateEvent(
            AppRoutes.completeRegister,
            navigationType: NavigationType.push,
            arguments: CompleteRegisterArgs(cubit: this),
          ),
        );
      }
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onSubmit() async {
    emit(state.copyWith(signupStatus: const BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());

    final String activityLevel;
    switch (state.activityLevel) {
      case AppStrings.sedentary:
        activityLevel = 'level1';
      case AppStrings.lightlyActive:
        activityLevel = 'level2';
      case AppStrings.moderatelyActive:
        activityLevel = 'level3';
      case AppStrings.veryActive:
        activityLevel = 'level4';
      case AppStrings.extraActive:
        activityLevel = 'level5';
      default:
        activityLevel = state.activityLevel;
    }

    final request = SignupRequest(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      password: state.password,
      rePassword: state.password,
      gender: state.gender,
      height: state.height,
      weight: state.weight,
      age: state.age,
      goal: state.goal,
      activityLevel: activityLevel,
    );
    final result = await _signupUseCase(request);

    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<UserEntity>():
        emit(state.copyWith(signupStatus: BaseState(data: result.data)));
        emitUiEvent(DisplaySuccessEvent(AppStrings.registerSuccess.tr()));
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
            predicate: (route) => false,
          ),
        );
      case ErrorBaseResponse<UserEntity>():
        emit(
          state.copyWith(
            signupStatus: BaseState(errorMessage: result.errorMessage.tr()),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage.tr()));
    }
  }

  Future<void> _signInWithGoogle() async {
    emitUiEvent(ShowLoadingEvent());
    final result = await _googleSignInUseCase();
    emitUiEvent(HideLoadingEvent());
    _handleSocialResult(result);
  }

  Future<void> _signInWithFacebook() async {
    emitUiEvent(ShowLoadingEvent());
    final result = await _facebookSignInUseCase();
    emitUiEvent(HideLoadingEvent());
    _handleSocialResult(result);
  }

  void _handleSocialResult(BaseResponse<dynamic> result) {
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
        _initializeFromSocial(InitializeFromSocialEvent(result.data!));
        emitUiEvent(
          NavigateEvent(
            AppRoutes.completeRegister,
            arguments: CompleteRegisterArgs(cubit: this),
          ),
        );
      case ErrorBaseResponse():
        emitUiEvent(DisplayErrorEvent(result.errorMessage.tr()));
      case SuccessBaseResponse():
        break;
    }
  }
}
