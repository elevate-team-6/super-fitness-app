import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

class TechnicalSpecsGrid extends StatelessWidget {
  final ExerciseEntity exercise;

  const TechnicalSpecsGrid({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            AppStrings.technicalSpecs.tr(),
            style: AppTextStyles.white18700,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.8,
          children: [
            _TechTile(
              icon: Icons.front_hand_rounded,
              label: AppStrings.grip.tr(),
              value: exercise.grip,
            ),
            _TechTile(
              icon: Icons.person_rounded,
              label: AppStrings.posture.tr(),
              value: exercise.posture,
            ),
            _TechTile(
              icon: Icons.settings_rounded,
              label: AppStrings.mechanics.tr(),
              value: exercise.mechanics,
            ),
            _TechTile(
              icon: Icons.bolt_rounded,
              label: AppStrings.forceType.tr(),
              value: exercise.forceType,
            ),
          ],
        ),
      ],
    );
  }
}

class _TechTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TechTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.white12500.copyWith(
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isEmpty ? AppStrings.na.tr() : value,
                  style: AppTextStyles.white14700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
