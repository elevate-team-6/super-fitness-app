import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';

import '../../../../core/widgets/custom_snack_bar.dart';
import '../view_model/register_view_model/register_cubit.dart';
import '../view_model/register_view_model/register_event.dart';
import '../widgets/social_login_buttons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with UiEventHandler {
  late final StreamSubscription _uiEventSubscription;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _uiEventSubscription = context.read<RegisterCubit>().eventStream.listen(
      handleUiEvent,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _uiEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.authBackground,
      appBar: CustomAppBar(onBackPressed: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.signupWelcome.tr(),
                    style: AppTextStyles.white18400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.signupCreateAccount.tr(),
                    style: AppTextStyles.white20800,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            CustomGlassContainer(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.register.tr(),
                      style: AppTextStyles.white24700,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _firstNameController,
                      hintText: AppStrings.firstName.tr(),
                      prefixIconPath: AppIcons.person,
                      validator: AppValidations.validateFirstName,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _lastNameController,
                      hintText: AppStrings.lastName.tr(),
                      prefixIconPath: AppIcons.person,
                      validator: AppValidations.validateLastName,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _emailController,
                      hintText: AppStrings.email.tr(),
                      prefixIconPath: AppIcons.email,
                      validator: AppValidations.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: AppStrings.password.tr(),
                      prefixIconPath: AppIcons.lock,
                      obscureText: true,
                      validator: AppValidations.validatePassword,
                    ),
                    SizedBox(height: 32.h),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _firstNameController,
                        _lastNameController,
                        _emailController,
                        _passwordController,
                      ]),
                      builder: (context, child) {
                        final isValid =
                            AppValidations.validateFirstName(
                                  _firstNameController.text,
                                ) ==
                                null &&
                            AppValidations.validateLastName(
                                  _lastNameController.text,
                                ) ==
                                null &&
                            AppValidations.validateEmail(
                                  _emailController.text,
                                ) ==
                                null &&
                            AppValidations.validatePassword(
                                  _passwordController.text,
                                ) ==
                                null;

                        return ElevatedButton(
                          onPressed: isValid ? _onRegisterPressed : null,
                          child: child,
                        );
                      },
                      child: Text(
                        AppStrings.register.tr(),
                        style: AppTextStyles.white20500,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SocialLoginButtons(
                      onGoogleTap: () => context.read<RegisterCubit>().doEvent(
                        const GoogleLoginEvent(),
                      ),
                      onFacebookTap: () => context
                          .read<RegisterCubit>()
                          .doEvent(const FacebookLoginEvent()),
                      onAppleTap: ()=> CustomSnackBar.showSuccessMessage(
                          AppStrings.appleSignInIsComingSoon.tr()
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.loginPrompt.tr(),
                          style: AppTextStyles.white16500,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppStrings.login.tr(),
                            style: AppTextStyles.primary16500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _onRegisterPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<RegisterCubit>().doEvent(
      UpdateAccountInfoEvent(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
    context.read<RegisterCubit>().doEvent(NextStepEvent());
  }
}
