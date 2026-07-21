import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_glass_card.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/exercise_entity.dart';

class ExerciseGridCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback onTap;

  const ExerciseGridCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          width: 160.w,
          height: 220.h,
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: CustomCachedImage(
                  imageUrl: exercise.image,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Bottom Content
              Positioned(
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                child: AppGlassCard(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        exercise.name,
                        style: AppTextStyles.white12700,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
