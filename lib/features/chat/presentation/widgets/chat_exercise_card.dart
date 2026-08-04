import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../domain/entities/chat_ref_entity.dart';

class ChatExerciseCard extends StatelessWidget {
  final ChatRefEntity ref;
  final VoidCallback? onTap;

  const ChatExerciseCard({super.key, required this.ref, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ref.isSnapshot ? null : onTap,
      child: Container(
        width: 160.w,
        height: 240.h,
        // Reverted to original height
        decoration: BoxDecoration(
          color: AppColors.black90.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image - Full width
            SizedBox(
              width: double.infinity,
              height: 120.h,
              child: CustomCachedImage(
                imageUrl: ref.image ?? '',
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: AppColors.black80,
                  child: Icon(
                    Icons.fitness_center,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    size: 40.r,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: SingleChildScrollView(
                  // Added to prevent overflow
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.white14700,
                      ),
                      SizedBox(height: 8.h),
                      if (ref.muscleGroup != null &&
                          ref.muscleGroup!.isNotEmpty)
                        Text(
                          ref.muscleGroup!,
                          style: AppTextStyles.white12500.copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (ref.difficulty != null && ref.difficulty!.isNotEmpty)
                        Text(
                          ref.difficulty!,
                          style: AppTextStyles.white10500.copyWith(
                            color: AppColors.white.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Snapshot Badge
            if (ref.isSnapshot)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4.h),
                color: AppColors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Text(
                    AppStrings.preview.tr(),
                    style: AppTextStyles.white8500.copyWith(letterSpacing: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
