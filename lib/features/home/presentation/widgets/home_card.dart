import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';

class HomeHorizontalCard extends StatelessWidget {
  final String title;
  final String image;
  final String? placeholderIcon;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const HomeHorizontalCard({
    super.key,
    required this.title,
    required this.image,
    this.placeholderIcon,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? 104.w;
    final effectiveHeight = height ?? 104.h;
     return GestureDetector(
      onTap: onTap,
      child: Container(
        width: effectiveWidth,
        height: effectiveHeight,
        margin: EdgeInsetsDirectional.only(end: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomCachedImage(
                imageUrl: image,
                placeholderIcon: placeholderIcon,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 30.h,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    color: AppColors.black80.withValues(alpha: 0.5),
                    child: Text(
                      title,
                      style: AppTextStyles.white10500,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
