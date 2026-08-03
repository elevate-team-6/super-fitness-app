import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../../../core/widgets/pressable.dart';

class MealCard extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.name,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 163.w,
        height: 160.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: image.isEmpty
                  ? const ColoredBox(color: AppColors.black80)
                  : CustomCachedImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholderIcon: AppIcons.meal,
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppColors.black80.withValues(alpha: 0.2),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.white16700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
