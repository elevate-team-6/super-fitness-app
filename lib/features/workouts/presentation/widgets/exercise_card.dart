import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: AppColors.black80.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ── Thumbnail ──
            SizedBox(
              width: 110.w,
              height: 110.h,
              child: CustomCachedImage(
                imageUrl: exercise.shortYoutubeDemonstrationLink,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: AppColors.black70,
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 28.r,
                  ),
                ),
              ),
            ),

            // ── Content ──
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exercise.exercise,
                      style: AppTextStyles.white16700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${exercise.mechanics} • ${exercise.laterality}',
                      style: AppTextStyles.white13400,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      exercise.primeMoverMuscle,
                      style: AppTextStyles.white13400.copyWith(
                        color: AppColors.white60,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ── Play Button ──
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(
                Icons.play_circle_filled_rounded,
                color: AppColors.primary,
                size: 40.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
