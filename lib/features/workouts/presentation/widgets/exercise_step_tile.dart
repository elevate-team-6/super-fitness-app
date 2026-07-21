import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../domain/entities/exercise_entity.dart';

class ExerciseStepTile extends StatelessWidget {
  final ExerciseEntity exercise;
  final String reps;
  final VoidCallback onPlayTap;

  const ExerciseStepTile({
    super.key,
    required this.exercise,
    this.reps = '3 Groups * 15 Times',
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.black80,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 80.w,
              height: 80.w,
              child: CustomCachedImage(
                imageUrl: exercise.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppTextStyles.white16700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  reps,
                  style: AppTextStyles.primary12500,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Lorem Ipsum Dolor Sit Amet Consectetur.',
                  style: AppTextStyles.white6012500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Play Button
          GestureDetector(
            onTap: onPlayTap,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.white,
                size: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
