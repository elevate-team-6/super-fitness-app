import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class OtpVerificationWidget extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final VoidCallback onResend;
  final bool isLoading;
  final int resendTimer;

  const OtpVerificationWidget({
    super.key,
    required this.onCompleted,
    required this.onResend,
    required this.resendTimer,
    this.isLoading = false,
  });

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = AppColors.primary;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 36,
      textStyle: AppTextStyles.white20500,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.white, width: 2.5)),
      ),
    );

    return Column(
      children: [
        Pinput(
          length: 6,
          controller: _pinController,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: brandOrange, width: 3)),
            ),
          ),
          submittedPinTheme: defaultPinTheme.copyWith(
            textStyle: AppTextStyles.primary20500,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: brandOrange, width: 3)),
            ),
          ),
          showCursor: true,
          cursor: Container(width: 2, height: 24, color: brandOrange),

          onChanged: (_) {
            setState(() {});
          },

          onCompleted: (_) {
            setState(() {});
          },
        ),

        SizedBox(height: 32.h),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading || _pinController.text.length < 6
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    widget.onCompleted(_pinController.text.trim());
                  },
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.confirm),
          ),
        ),

        SizedBox(height: 16.h),

        Text(AppStrings.dontRecieveCode.tr(), style: AppTextStyles.white16500),

        SizedBox(height: 8.h),

        TextButton(
          onPressed: (widget.isLoading || widget.resendTimer > 0)
              ? null
              : widget.onResend,
          child: Text(
            widget.resendTimer > 0
                ? "${AppStrings.resendCode.tr()} (${widget.resendTimer}s)"
                : AppStrings.resendCode.tr(),
            style: AppTextStyles.primary20500.copyWith(
              decorationColor: (widget.isLoading || widget.resendTimer > 0)
                  ? AppColors.white.withValues(alpha: 0.5)
                  : AppColors.primary,
              color: (widget.isLoading || widget.resendTimer > 0)
                  ? AppColors.white.withValues(alpha: 0.5)
                  : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
