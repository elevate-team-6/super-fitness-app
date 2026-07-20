import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class MealNutritionStat {
  final String value;

  final String labelKey;

  const MealNutritionStat({required this.value, required this.labelKey});
}

class MealNutritionBar extends StatelessWidget {
  final List<MealNutritionStat> stats;

  const MealNutritionBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < stats.length; index++) ...[
          if (index > 0) SizedBox(width: 24.w),
          Expanded(child: _StatChip(stat: stats[index])),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final MealNutritionStat stat;

  const _StatChip({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.white13500.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            stat.labelKey.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.primary10500.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
