import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

abstract class CustomSnackBar {
  static void showSuccessMessage(String msg) => _show(msg, true);
  static void showErrorMessage(String msg) => _show(msg, false);

  static void _show(String msg, bool isSuccess) {
    BotToast.showCustomNotification(
      duration: const Duration(seconds: 4),
      align: Alignment.topCenter,
      toastBuilder: (cancelFunc) => _FitnessSnackBar(
        msg: msg,
        isSuccess: isSuccess,
        cancelFunc: cancelFunc,
      ),
    );
  }
}

class _FitnessSnackBar extends StatelessWidget {
  final String msg;
  final bool isSuccess;
  final VoidCallback cancelFunc;

  const _FitnessSnackBar({
    required this.msg,
    required this.isSuccess,
    required this.cancelFunc,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isSuccess ? AppColors.primary : AppColors.red;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(1.w), // Border effect
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.black90.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                children: [
                  // Fitness-themed status icon
                  _buildIcon(accentColor),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSuccess
                              ? AppStrings.success.tr()
                              : AppStrings.oops.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          msg,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: cancelFunc,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: AppColors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isSuccess
              ? Icons.offline_bolt_rounded
              : Icons.report_gmailerrorred_rounded,
          color: color,
          size: 24.sp,
        ),
      ),
    );
  }
}
