import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

class MealTimeCard extends StatelessWidget {
  final MealTime mealTime;
  final VoidCallback onTap;

  const MealTimeCard({super.key, required this.mealTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 100.h,
        margin: EdgeInsetsDirectional.only(end: 12.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomCachedImage(
              imageUrl: mealTime.thumbnail,
              placeholder: const ColoredBox(color: AppColors.black80),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  mealTime.labelKey.tr(),
                  style: AppTextStyles.white13500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
