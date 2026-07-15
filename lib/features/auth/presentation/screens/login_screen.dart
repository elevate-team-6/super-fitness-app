import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/services/exit_app_dialog.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/widgets/login_form.dart';
import 'package:super_fitness/features/auth/presentation/widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with UiEventHandler {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context.read<LoginCubit>().eventStream.listen(
      handleUiEvent,
    );
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void onFillTextField(String text) {
    _emailController.text = text;
  }

  void _onLoginPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<LoginCubit>().doIntent(
      LoginEvent(
        SignInRequestModel(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ExitAppDialog.show(context);
      },
      child: AppScaffold(
        backgroundImage: AppImages.authBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(AppImages.fitnessAppLogo, height: 64.h),
                SizedBox(height: 56.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.heyThere.tr(),
                      style: AppTextStyles.white16500.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.welcomeBack.tr(),
                      style: AppTextStyles.white24700.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                CustomGlassContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.login.tr(),
                        style: AppTextStyles.white24700,
                      ),
                      SizedBox(height: 16.h),
                      LoginForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onForgetPasswordTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgetPassword,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 56),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: Text(
                                    AppStrings.orText.tr(),
                                    style: AppTextStyles.white13400.copyWith(
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialLoginButton(assetPath: AppIcons.facebook),
                              SizedBox(width: 16.w),
                              SocialLoginButton(
                                assetPath: AppIcons.google,
                                onTap: () => context
                                    .read<LoginCubit>()
                                    .doIntent(const GoogleLoginEvent()),
                              ),
                              SizedBox(width: 16.w),
                              SocialLoginButton(icon: Icons.apple),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Login button — enabled only when the form is valid.
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _emailController,
                          _passwordController,
                        ]),
                        builder: (context, child) {
                          final isValid =
                              AppValidations.validateEmail(
                                    _emailController.text,
                                  ) ==
                                  null &&
                              AppValidations.validatePassword(
                                    _passwordController.text,
                                  ) ==
                                  null;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isValid ? _onLoginPressed : null,
                              child: child,
                            ),
                          );
                        },
                        child: Text(AppStrings.login.tr()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAccount.tr(),
                            style: AppTextStyles.white13400.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              AppStrings.register.tr(),
                              style: AppTextStyles.primary13500.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
