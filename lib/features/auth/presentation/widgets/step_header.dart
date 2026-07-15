import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class StepHeader extends StatelessWidget {
  final int currentStep;
  final String title;
  final String? subtitle;

  const StepHeader({
    super.key,
    required this.currentStep,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50.w,
              height: 50.w,
              child: CircularProgressIndicator(
                value: currentStep / 6,
                backgroundColor: AppColors.white.withValues(alpha: 0.1),
                color: AppColors.primary,
                strokeWidth: 5.w,
              ),
            ),
            Text(
              '$currentStep/6',
              style: AppTextStyles.white13500.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.tr().toUpperCase(),
              style: AppTextStyles.white20800,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!.tr(),
                style: AppTextStyles.white18400,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
