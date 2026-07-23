import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';

class MuscleGridItem extends StatelessWidget {
  final MuscleEntity muscle;
  final VoidCallback? onTap;

  const MuscleGridItem({
    super.key,
    required this.muscle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // 1. Background Image
            Positioned.fill(
              child: CustomCachedImage(
                imageUrl: muscle.image,
                fit: BoxFit.cover,
              ),
            ),

            // 2. Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Muscle Name
            Positioned(
              bottom: 16.h,
              left: 12.w,
              right: 12.w,
              child: Text(
                muscle.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.white20500.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
