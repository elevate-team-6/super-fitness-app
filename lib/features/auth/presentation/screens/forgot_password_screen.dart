import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with UiEventHandler {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();

    _uiEventSubscription = context
        .read<ForgotPasswordCubit>()
        .eventStream
        .listen(handleUiEvent);
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ForgotPasswordCubit>().doEvent(
      ForgotPasswordEvent(email: _emailController.text.trim()),
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

              SizedBox(height: 85.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  AppStrings.enterEmail,
                  style: AppTextStyles.white20500,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  AppStrings.forgetPassword,
                  style: AppTextStyles.white24500,
                ),
              ),

              SizedBox(height: 20.h),

              CustomGlassContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: AppValidations.validateEmail,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 5.w,
                            top: 12.h,
                            bottom: 12.h,
                          ),
                          child: SvgPicture.asset(AppIcons.email),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                        listenWhen: (previous, current) =>
                            previous.forgotPasswordState !=
                            current.forgotPasswordState,
                        listener: (context, state) {
                          if (!state.forgotPasswordState.isLoading) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.verifyResetCode,
                              arguments: _emailController.text.trim(),
                            );
                          }
                        },
                        buildWhen: (previous, current) =>
                            previous.forgotPasswordState !=
                            current.forgotPasswordState,
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.forgotPasswordState.isLoading
                                  ? null
                                  : _sendOtp,
                              child: state.forgotPasswordState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(AppStrings.sentOtP),
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
