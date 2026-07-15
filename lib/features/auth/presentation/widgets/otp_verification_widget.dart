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

  const OtpVerificationWidget({
    super.key,
    required this.onCompleted,
    required this.onResend,
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

        Text(AppStrings.dontRecieveCode, style: AppTextStyles.white16500),

        SizedBox(height: 8.h),

        GestureDetector(
          onTap: widget.isLoading ? null : widget.onResend,
          child: Text(
            AppStrings.resendCode,
            style: AppTextStyles.primary20500.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
