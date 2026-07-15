import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';

class LoginForm extends StatelessWidget {
  static const Key emailFieldKey = Key('login_email_field');
  static const Key passwordFieldKey = Key('login_password_field');

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback? onForgetPasswordTap;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.onForgetPasswordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            key: emailFieldKey,
            controller: emailController,
            hintText: AppStrings.email.tr(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: AppValidations.validateEmail,
          ),
          SizedBox(height: 16.h),
          BlocSelector<LoginCubit, LoginState, bool>(
            selector: (state) => state.obscurePassword,
            builder: (context, isObscured) {
              return CustomTextField(
                key: passwordFieldKey,
                controller: passwordController,
                hintText: AppStrings.password.tr(),
                obscureText: isObscured,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: AppValidations.validatePassword,
                suffixIcon: IconButton(
                  onPressed: () => context.read<LoginCubit>().doIntent(
                    const TogglePasswordVisibilityEvent(),
                  ),
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.white,
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onForgetPasswordTap,
              child: Text(AppStrings.forgetPassword.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
