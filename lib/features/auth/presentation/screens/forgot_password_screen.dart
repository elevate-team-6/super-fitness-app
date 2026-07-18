import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';
import 'package:super_fitness/features/auth/presentation/widgets/otp_verification_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with UiEventHandler {
  late final PageController _pageController;
  late final StreamSubscription<BaseUiEvent> _uiEventSubscription;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ForgotPasswordCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);
    _pageController = PageController(initialPage: cubit.state.currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiEventSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onBackPressed() {
    final cubit = context.read<ForgotPasswordCubit>();
    if (cubit.state.currentStep > 0) {
      cubit.doEvent(UpdateStepEvent(cubit.state.currentStep - 1));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: AppScaffold(
        backgroundImage: AppImages.authBackground,
        appBar: CustomAppBar(onBackPressed: _onBackPressed),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20.h),
            child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 120.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSubtitle(state.currentStep).tr(),
                            style: AppTextStyles.white20500,
                          ),
                          Text(
                            _getTitle(state.currentStep).tr(),
                            style: AppTextStyles.white24500,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomGlassContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
                      ),
                      child: ExpandablePageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: [
                          _buildEmailStep(state),
                          _buildOtpStep(state),
                          _buildPasswordStep(state),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(ForgotPasswordState state) {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: AppStrings.email.tr(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: AppValidations.validateEmail,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: SvgPicture.asset(AppIcons.email),
          ),
        ),
        SizedBox(height: 24.h),
        AnimatedBuilder(
          animation: _emailController,
          builder: (context, child) {
            final isValid =
                AppValidations.validateEmail(_emailController.text) == null;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        context.read<ForgotPasswordCubit>().doEvent(
                          UpdateForgotPasswordInfoEvent(
                            email: _emailController.text.trim(),
                          ),
                        );
                        context.read<ForgotPasswordCubit>().doEvent(
                          ForgotPasswordEvent(),
                        );
                      }
                    : null,
                child: Text(AppStrings.sentOtP.tr()),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtpStep(ForgotPasswordState state) {
    return OtpVerificationWidget(
      isLoading: state.verifyResetCodeState.isLoading,
      resendTimer: state.resendTimer,
      onCompleted: (code) {
        context.read<ForgotPasswordCubit>().doEvent(
          UpdateForgotPasswordInfoEvent(otpCode: code),
        );
        context.read<ForgotPasswordCubit>().doEvent(VerifyResetCodeEvent());
      },
      onResend: () {
        context.read<ForgotPasswordCubit>().doEvent(ForgotPasswordEvent());
      },
    );
  }

  Widget _buildPasswordStep(ForgotPasswordState state) {
    return Column(
      children: [
        CustomTextField(
          controller: _passwordController,
          hintText: AppStrings.password.tr(),
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: AppValidations.validatePassword,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: SvgPicture.asset(AppIcons.lock),
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: AppStrings.password.tr(),
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (value) => AppValidations.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: SvgPicture.asset(AppIcons.lock),
          ),
        ),
        SizedBox(height: 24.h),
        AnimatedBuilder(
          animation: Listenable.merge([
            _passwordController,
            _confirmPasswordController,
          ]),
          builder: (context, child) {
            final isValid =
                AppValidations.validatePassword(_passwordController.text) ==
                    null &&
                AppValidations.validateConfirmPassword(
                      _confirmPasswordController.text,
                      _passwordController.text,
                    ) ==
                    null;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        context.read<ForgotPasswordCubit>().doEvent(
                          UpdateForgotPasswordInfoEvent(
                            newPassword: _passwordController.text.trim(),
                          ),
                        );
                        context.read<ForgotPasswordCubit>().doEvent(
                          ResetPasswordEvent(),
                        );
                      }
                    : null,
                child: Text(AppStrings.confirm.tr()),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getTitle(int step) {
    switch (step) {
      case 0:
        return AppStrings.forgetPassword;
      case 1:
        return AppStrings.otpCode;
      case 2:
        return AppStrings.createNewPassword;
      default:
        return '';
    }
  }

  String _getSubtitle(int step) {
    switch (step) {
      case 0:
        return AppStrings.enterEmail;
      case 1:
        return AppStrings.enterOtp;
      case 2:
        return AppStrings.passwordMoreCharacter;
      default:
        return '';
    }
  }
}
