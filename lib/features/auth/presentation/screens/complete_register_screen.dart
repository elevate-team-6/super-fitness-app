import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/features/profile/domain/entities/complete_register_mode.dart';
import 'package:super_fitness/features/profile/domain/entities/edit_profile_section.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart'
    as edit_event;
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_state.dart';

import '../view_model/register_view_model/register_cubit.dart';
import '../view_model/register_view_model/register_event.dart';
import '../view_model/register_view_model/register_state.dart';
import '../widgets/custom_horizontal_wheel_picker.dart';
import '../widgets/gender_selection_view.dart';
import '../widgets/multi_step_progress_header.dart';
import '../widgets/selectable_option_list.dart';

class CompleteRegisterScreen extends StatefulWidget {
  final CompleteRegisterMode mode;
  final EditProfileSection? section;

  const CompleteRegisterScreen({
    super.key,
    this.mode = CompleteRegisterMode.register,
    this.section,
  });

  @override
  State<CompleteRegisterScreen> createState() =>
      _CompleteRegisterScreenState();
}

class _CompleteRegisterScreenState extends State<CompleteRegisterScreen>
    with UiEventHandler {
  late final PageController _pageController;
  late final StreamSubscription _uiEventSubscription;

  bool get _isEditMode => widget.mode == CompleteRegisterMode.edit;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final cubit = context.read<EditProfileCubit>();
      _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);

      int initialPage = 0;
      if (widget.section != null) {
        switch (widget.section!) {
          case EditProfileSection.gender:
            initialPage = 0;
          case EditProfileSection.age:
            initialPage = 1;
          case EditProfileSection.weight:
            initialPage = 2;
          case EditProfileSection.height:
            initialPage = 3;
          case EditProfileSection.goal:
            initialPage = 4;
          case EditProfileSection.activity:
            initialPage = 5;
        }
      }
      _pageController = PageController(initialPage: initialPage);
    } else {
      final cubit = context.read<RegisterCubit>();
      _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);

      final currentStep = cubit.state.currentStep;
      _pageController = PageController(
        initialPage: currentStep > 0 ? currentStep - 1 : 0,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditMode) {
      return AppScaffold(
        backgroundImage: AppImages.authBackground,
        appBar: CustomAppBar(onBackPressed: () => Navigator.pop(context)),
        body: BlocBuilder<EditProfileCubit, EditProfileState>(
          builder: (context, state) {
            return _buildContent(
              currentStep: 1,
              gender: state.gender,
              onGenderSelected:
                  (g) => context.read<EditProfileCubit>().doEvent(
                    edit_event.UpdateGenderEvent(g),
                  ),
              age: state.age,
              onAgeChanged:
                  (a) => context.read<EditProfileCubit>().doEvent(
                    edit_event.UpdateAgeEvent(a),
                  ),
              weight: state.weight,
              onWeightChanged:
                  (w) => context.read<EditProfileCubit>().doEvent(
                    edit_event.UpdateWeightEvent(w),
                  ),
              height: state.height,
              onHeightChanged:
                  (h) => context.read<EditProfileCubit>().doEvent(
                    edit_event.UpdateHeightEvent(h),
                  ),
              goal: state.goal,
              onGoalSelected:
                  (g) => context.read<EditProfileCubit>().doEvent(
                    edit_event.UpdateGoalEvent(g),
                  ),
              activityLevel: state.activityLevel,
              onActivitySelected:
                  (l) => context.read<EditProfileCubit>().doEvent(
                    edit_event.UpdateActivityEvent(l),
                  ),
              isStepValid: true,
              buttonText: AppStrings.save.tr(),
              onButtonPressed: () {
                dynamic result;
                switch (widget.section) {
                  case EditProfileSection.gender:
                    result = state.gender;
                  case EditProfileSection.age:
                    result = state.age;
                  case EditProfileSection.weight:
                    result = state.weight;
                  case EditProfileSection.height:
                    result = state.height;
                  case EditProfileSection.goal:
                    result = state.goal;
                  case EditProfileSection.activity:
                    result = state.activityLevel;
                  case null:
                    break;
                }
                Navigator.pop(context, result);
              },
            );
          },
        ),
      );
    }

    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen:
          (previous, current) => previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state.currentStep > 0 && state.currentStep <= 6) {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              state.currentStep - 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: AppScaffold(
        backgroundImage: AppImages.authBackground,
        appBar: CustomAppBar(
          onBackPressed: () {
            final cubit = context.read<RegisterCubit>();
            if (cubit.state.currentStep > 1) {
              cubit.doEvent(const PreviousStepEvent());
            } else {
              cubit.doEvent(const PreviousStepEvent());
              Navigator.pop(context);
            }
          },
        ),
        body: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            return _buildContent(
              currentStep: state.currentStep,
              gender: state.gender,
              onGenderSelected:
                  (g) => context.read<RegisterCubit>().doEvent(
                    SelectGenderEvent(g),
                  ),
              age: state.age,
              onAgeChanged:
                  (a) => context.read<RegisterCubit>().doEvent(
                    UpdateAgeEvent(a),
                  ),
              weight: state.weight,
              onWeightChanged:
                  (w) => context.read<RegisterCubit>().doEvent(
                    UpdateWeightEvent(w),
                  ),
              height: state.height,
              onHeightChanged:
                  (h) => context.read<RegisterCubit>().doEvent(
                    UpdateHeightEvent(h),
                  ),
              goal: state.goal,
              onGoalSelected:
                  (g) => context.read<RegisterCubit>().doEvent(
                    SelectGoalEvent(g),
                  ),
              activityLevel: state.activityLevel,
              onActivitySelected:
                  (l) => context.read<RegisterCubit>().doEvent(
                    SelectActivityLevelEvent(l),
                  ),
              isStepValid: _isStepValid(state),
              buttonText:
                  (state.currentStep < 6
                          ? AppStrings.next
                          : AppStrings.done)
                      .tr(),
              onButtonPressed: () {
                if (state.currentStep < 6) {
                  context.read<RegisterCubit>().doEvent(
                    const NextStepEvent(),
                  );
                } else {
                  context.read<RegisterCubit>().doEvent(
                    const SubmitSignupEvent(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent({
    required int currentStep,
    required String gender,
    required ValueChanged<String> onGenderSelected,
    required int age,
    required ValueChanged<int> onAgeChanged,
    required int weight,
    required ValueChanged<int> onWeightChanged,
    required int height,
    required ValueChanged<int> onHeightChanged,
    required String goal,
    required ValueChanged<String> onGoalSelected,
    required String activityLevel,
    required ValueChanged<String> onActivitySelected,
    required bool isStepValid,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        MultiStepProgressHeader(
          currentStep: currentStep,
          title: _getTitle(currentStep),
          subtitle: _getSubtitle(currentStep),
          showProgress: !_isEditMode,
        ),
        SizedBox(height: 24.h),
        CustomGlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ExpandablePageView(
                  animationDuration: const Duration(milliseconds: 500),
                  animationCurve: Curves.fastOutSlowIn,
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GenderSelectionView(
                      selectedGender: gender,
                      onGenderSelected: onGenderSelected,
                    ),
                    CustomHorizontalWheelPicker(
                      minValue: 16,
                      maxValue: 90,
                      selectedValue: age,
                      unit: AppStrings.year.tr(),
                      onValueChanged: onAgeChanged,
                    ),
                    CustomHorizontalWheelPicker(
                      minValue: 30,
                      maxValue: 250,
                      selectedValue: weight,
                      unit: AppStrings.kg.tr(),
                      onValueChanged: onWeightChanged,
                    ),
                    CustomHorizontalWheelPicker(
                      minValue: 100,
                      maxValue: 250,
                      selectedValue: height,
                      unit: AppStrings.cm.tr(),
                      onValueChanged: onHeightChanged,
                    ),
                    SelectableOptionList(
                      options: const [
                        AppStrings.gainWeight,
                        AppStrings.loseWeight,
                        AppStrings.getFitter,
                        AppStrings.gainMoreFlexible,
                        AppStrings.learnTheBasic,
                      ],
                      selectedOption: goal,
                      onOptionSelected: onGoalSelected,
                    ),
                    SelectableOptionList(
                      options: const [
                        AppStrings.sedentary,
                        AppStrings.lightlyActive,
                        AppStrings.moderatelyActive,
                        AppStrings.veryActive,
                        AppStrings.extraActive,
                      ],
                      selectedOption: activityLevel,
                      onOptionSelected: onActivitySelected,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: isStepValid ? onButtonPressed : null,
                child: Text(buttonText, style: AppTextStyles.white20500),
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  bool _isStepValid(RegisterState state) {
    switch (state.currentStep) {
      case 1:
        return state.gender.isNotEmpty;
      case 2:
        return state.age > 0;
      case 3:
        return state.weight > 0;
      case 4:
        return state.height > 0;
      case 5:
        return state.goal.isNotEmpty;
      case 6:
        return state.activityLevel.isNotEmpty;
      default:
        return true;
    }
  }

  String _getTitle(int step) {
    if (_isEditMode) {
      switch (widget.section) {
        case EditProfileSection.gender:
          return AppStrings.editGender;
        case EditProfileSection.age:
          return AppStrings.editAge;
        case EditProfileSection.weight:
          return AppStrings.editWeight;
        case EditProfileSection.height:
          return AppStrings.editHeight;
        case EditProfileSection.goal:
          return AppStrings.editGoal;
        case EditProfileSection.activity:
          return AppStrings.editActivity;
        case null:
          return '';
      }
    }
    switch (step) {
      case 1:
        return AppStrings.tellUsAboutYourself;
      case 2:
        return AppStrings.ageTitle;
      case 3:
        return AppStrings.weightTitle;
      case 4:
        return AppStrings.heightTitle;
      case 5:
        return AppStrings.goalTitle;
      case 6:
        return AppStrings.activityLevelTitle;
      default:
        return '';
    }
  }

  String? _getSubtitle(int step) {
    if (_isEditMode) return null;
    switch (step) {
      case 1:
        return AppStrings.genderTitle;
      case 2:
      case 3:
      case 4:
      case 5:
        return AppStrings.personalizationDesc;
      case 6:
        return null;
      default:
        return '';
    }
  }
}
