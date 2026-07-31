import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? highlight;
  final Widget? trailing;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.highlight,
    this.trailing,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: isHighlighted
                      ? AppTextStyles.primary16500.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        )
                      : AppTextStyles.white16500.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  children: highlight == null
                      ? null
                      : [
                          TextSpan(
                            text: ' ($highlight)',
                            style: AppTextStyles.primary16500,
                          ),
                        ],
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  size: 22.sp,
                ),
          ],
        ),
      ),
    );
  }
}
