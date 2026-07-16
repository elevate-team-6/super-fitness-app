import 'package:injectable/injectable.dart';

import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../../core/utils/app_routes.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../data/models/request/signup_request.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/signup_use_case.dart';
import 'register_event.dart';
import 'register_state.dart';

@lazySingleton
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  final SignupUseCase _signupUseCase;

  RegisterCubit(this._signupUseCase) : super(const RegisterState());

  void doEvent(RegisterEvent event) {
    switch (event) {
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
    }
  }

  void _updateAccountInfo(UpdateAccountInfoEvent event) {
    emit(
      state.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        // A social provider already answered the account step.
        currentStep: event.skipAccountStep ? 1 : state.currentStep,
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

    if (result is SuccessBaseResponse<UserEntity>) {
      emit(state.copyWith(signupStatus: BaseState(data: result.data)));
      emitUiEvent(DisplaySuccessEvent(AppStrings.registerSuccess));
    } else if (result is ErrorBaseResponse<UserEntity>) {
      emit(
        state.copyWith(
          signupStatus: BaseState(errorMessage: result.errorMessage),
        ),
      );
      emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }
}
