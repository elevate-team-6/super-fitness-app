import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with UiEventHandler {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  StreamSubscription<BaseUiEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = context.read<ForgotPasswordCubit>().eventStream.listen(
      handleUiEvent,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ForgotPasswordCubit>().doEvent(
      ResetPasswordEvent(
        email: widget.email,
        newPassword: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(AppImages.lancherLogo, height: 120.h),
              ),

              SizedBox(height: 65.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  AppStrings.passwordMoreCharacter,
                  style: AppTextStyles.white20500,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  AppStrings.createNewPassword,
                  style: AppTextStyles.white24500,
                ),
              ),

              SizedBox(height: 5.h),

              CustomGlassContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _passwordController,
                        hintText: AppStrings.password,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 5.w,
                            top: 12.h,
                            bottom: 12.h,
                          ),
                          child: SvgPicture.asset(AppIcons.lock),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: AppValidations.validatePassword,
                      ),

                      SizedBox(height: 20.h),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: AppStrings.password,
                        obscureText: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 5.w,
                            top: 12.h,
                            bottom: 12.h,
                          ),
                          child: SvgPicture.asset(AppIcons.lock),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            AppValidations.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),

                      SizedBox(height: 30.h),

                      BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                        buildWhen: (previous, current) =>
                            previous.resetPasswordState !=
                            current.resetPasswordState,
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.resetPasswordState.isLoading
                                  ? null
                                  : _submit,
                              child: state.resetPasswordState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(AppStrings.confirm),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
