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

import '../view_model/register_view_model/register_cubit.dart';
import '../view_model/register_view_model/register_event.dart';
import '../view_model/register_view_model/register_state.dart';
import '../widgets/custom_horizontal_wheel_picker.dart';
import '../widgets/gender_selection_view.dart';
import '../widgets/selectable_option_list.dart';
import '../widgets/step_header.dart';

class CompleteRegisterScreen extends StatefulWidget {
  const CompleteRegisterScreen({super.key});

  @override
  State<CompleteRegisterScreen> createState() => _CompleteRegisterScreenState();
}

class _CompleteRegisterScreenState extends State<CompleteRegisterScreen>
    with UiEventHandler {
  late final PageController _pageController;
  late final StreamSubscription _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RegisterCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);

    final currentStep = cubit.state.currentStep;
    _pageController = PageController(
      initialPage: currentStep > 0 ? currentStep - 1 : 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
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
              cubit.doEvent(PreviousStepEvent());
            } else {
              cubit.doEvent(PreviousStepEvent()); // Goes back to step 0
              Navigator.pop(context);
            }
          },
        ),
        body: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            return Column(
              children: [
                SizedBox(height: 40.h),
                StepHeader(
                  currentStep: state.currentStep,
                  title: _getTitle(state.currentStep),
                  subtitle: _getSubtitle(state.currentStep),
                ),
                SizedBox(height: 24.h),
                CustomGlassContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
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
                              selectedGender: state.gender,
                              onGenderSelected: (gender) {
                                context.read<RegisterCubit>().doEvent(
                                  SelectGenderEvent(gender),
                                );
                              },
                            ),
                            CustomHorizontalWheelPicker(
                              minValue: 16,
                              maxValue: 90,
                              selectedValue: state.age,
                              unit: AppStrings.year.tr(),
                              onValueChanged: (age) {
                                context.read<RegisterCubit>().doEvent(
                                  UpdateAgeEvent(age),
                                );
                              },
                            ),
                            CustomHorizontalWheelPicker(
                              minValue: 30,
                              maxValue: 250,
                              selectedValue: state.weight,
                              unit: AppStrings.kg.tr(),
                              onValueChanged: (weight) {
                                context.read<RegisterCubit>().doEvent(
                                  UpdateWeightEvent(weight),
                                );
                              },
                            ),
                            CustomHorizontalWheelPicker(
                              minValue: 100,
                              maxValue: 250,
                              selectedValue: state.height,
                              unit: AppStrings.cm.tr(),
                              onValueChanged: (height) {
                                context.read<RegisterCubit>().doEvent(
                                  UpdateHeightEvent(height),
                                );
                              },
                            ),
                            SelectableOptionList(
                              options: const [
                                AppStrings.gainWeight,
                                AppStrings.loseWeight,
                                AppStrings.getFitter,
                                AppStrings.gainMoreFlexible,
                                AppStrings.learnTheBasic,
                              ],
                              selectedOption: state.goal,
                              onOptionSelected: (goal) {
                                context.read<RegisterCubit>().doEvent(
                                  SelectGoalEvent(goal),
                                );
                              },
                            ),
                            SelectableOptionList(
                              options: const [
                                AppStrings.sedentary,
                                AppStrings.lightlyActive,
                                AppStrings.moderatelyActive,
                                AppStrings.veryActive,
                                AppStrings.extraActive,
                              ],
                              selectedOption: state.activityLevel,
                              onOptionSelected: (level) {
                                context.read<RegisterCubit>().doEvent(
                                  SelectActivityLevelEvent(level),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _isStepValid(state)
                            ? () {
                                if (state.currentStep < 6) {
                                  context.read<RegisterCubit>().doEvent(
                                    NextStepEvent(),
                                  );
                                } else {
                                  context.read<RegisterCubit>().doEvent(
                                    SubmitSignupEvent(),
                                  );
                                }
                              }
                            : null,
                        child: Text(
                          (state.currentStep < 6
                                  ? AppStrings.next
                                  : AppStrings.done)
                              .tr(),
                          style: AppTextStyles.white20500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            );
          },
        ),
      ),
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
