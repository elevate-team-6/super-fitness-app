import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with UiEventHandler {
  late final StreamSubscription<BaseUiEvent> _uiEventSubscription;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ChangePasswordCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);

    _oldPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    context.read<ChangePasswordCubit>().doEvent(
      UpdatePasswordsEvent(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  void dispose() {
    _uiEventSubscription.cancel();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.authBackground,
      appBar: CustomAppBar(onBackPressed: () => Navigator.pop(context)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20.h),
          child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
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
                          AppStrings.enterPasswordDetails.tr(),
                          style: AppTextStyles.white18400,
                        ),
                        Text(
                          AppStrings.changeYourPassword.tr(),
                          style: AppTextStyles.white2020500,
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
                    child: Column(
                      children: [
                        // Old Password Field
                        CustomTextField(
                          controller: _oldPasswordController,
                          hintText: AppStrings.oldPassword.tr(),
                          obscureText: state.obscureOldPassword,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(AppIcons.lock),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => context
                                .read<ChangePasswordCubit>()
                                .doEvent(ToggleOldPasswordVisibilityEvent()),
                            icon: Icon(
                              state.obscureOldPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // New Password Field
                        CustomTextField(
                          controller: _newPasswordController,
                          hintText: AppStrings.newPassword.tr(),
                          obscureText: state.obscureNewPassword,
                          textInputAction: TextInputAction.next,
                          validator: AppValidations.validatePassword,
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(AppIcons.lock),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => context
                                .read<ChangePasswordCubit>()
                                .doEvent(ToggleNewPasswordVisibilityEvent()),
                            icon: Icon(
                              state.obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: AppStrings.confirmPassword.tr(),
                          obscureText: state.obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              AppValidations.validateConfirmPassword(
                                value,
                                _newPasswordController.text,
                              ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(AppIcons.lock),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                context.read<ChangePasswordCubit>().doEvent(
                                  ToggleConfirmPasswordVisibilityEvent(),
                                ),
                            icon: Icon(
                              state.obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),

                        // Same-as-old hint
                        if (state.newPassword.isNotEmpty &&
                            state.oldPassword.isNotEmpty &&
                            state.newPassword == state.oldPassword)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                AppStrings.passwordSameAsOld.tr(),
                                style: AppTextStyles.white13500.copyWith(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 24.h),

                        // Change Password Button — reads isFormValid from state only
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isFormValid
                                ? () => context
                                      .read<ChangePasswordCubit>()
                                      .doEvent(ChangePasswordEvent())
                                : null,
                            child: Text(AppStrings.changePassword.tr()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
