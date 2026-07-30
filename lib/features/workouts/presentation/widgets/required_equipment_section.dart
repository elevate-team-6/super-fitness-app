import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';

class RequiredEquipmentSection extends StatelessWidget {
  final ExerciseEntity exercise;

  const RequiredEquipmentSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final secondary = exercise.secondaryEquipment
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final allEquipment = [
      if (exercise.primaryEquipment.isNotEmpty) exercise.primaryEquipment,
      ...secondary,
    ];

    if (allEquipment.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.requiredEquipment.tr(),
            style: AppTextStyles.white18700,
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: allEquipment.map((equipment) {
              final isPrimary = equipment == exercise.primaryEquipment;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isPrimary
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.handyman_rounded,
                      color: isPrimary ? AppColors.primary : AppColors.white,
                      size: 22.r,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      equipment.trim(),
                      style: isPrimary
                          ? AppTextStyles.primary16500.copyWith(
                              fontWeight: FontWeight.w700,
                            )
                          : AppTextStyles.white14700,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
