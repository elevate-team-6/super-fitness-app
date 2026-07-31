import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

class MuscleTargetingSection extends StatelessWidget {
  final ExerciseEntity exercise;

  const MuscleTargetingSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final secondary = exercise.secondaryMuscles
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final tertiary = exercise.tertiaryMuscles
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final allSecondary = [...secondary, ...tertiary];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.musclesTargeted.tr(),
            style: AppTextStyles.white18700,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.primeMover.tr(),
            style: AppTextStyles.white13400.copyWith(
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  exercise.primeMoverMuscle,
                  style: AppTextStyles.primary16500.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (allSecondary.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              AppStrings.secondary.tr(),
              style: AppTextStyles.white13400.copyWith(
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: allSecondary.map((muscle) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(muscle.trim(), style: AppTextStyles.white13500),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
