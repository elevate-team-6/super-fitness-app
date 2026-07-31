import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class TappableEditField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const TappableEditField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.white16500,
            children: [
              TextSpan(text: '$label ('),
              TextSpan(
                text: AppStrings.tapToEdit.tr(),
                style: AppTextStyles.primary16500,
              ),
              const TextSpan(text: ')'),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.5),
                width: 1.w,
              ),
              color: AppColors.white.withValues(alpha: 0.05),
            ),
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.white16500,
            ),
          ),
        ),
      ],
    );
  }
}
