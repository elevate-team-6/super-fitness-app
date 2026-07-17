import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/core/widgets/custom_snack_bar.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';
import 'package:super_fitness/features/auth/presentation/widgets/otp_verification_widget.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;

  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen>
    with UiEventHandler {
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
    super.dispose();
  }

  void _verifyCode(String code) {
    FocusScope.of(context).unfocus();

    if (code.length != 6) {
      CustomSnackBar.showErrorMessage(AppStrings.otpCodeInvalid);
      return;
    }

    context.read<ForgotPasswordCubit>().doEvent(
      VerifyResetCodeEvent(email: widget.email, resetCode: code),
    );
  }

  void _resendCode() {
    context.read<ForgotPasswordCubit>().doEvent(
      ForgotPasswordEvent(email: widget.email),
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
                  AppStrings.otpCode,
                  style: AppTextStyles.white24500,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  AppStrings.enterOtp,
                  style: AppTextStyles.white20500,
                ),
              ),

              SizedBox(height: 20.h),

              CustomGlassContainer(
                child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  buildWhen: (previous, current) =>
                      previous.verifyResetCodeState !=
                      current.verifyResetCodeState,
                  builder: (context, state) {
                    return OtpVerificationWidget(
                      isLoading: state.verifyResetCodeState.isLoading,
                      onCompleted: _verifyCode,
                      onResend: _resendCode,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
