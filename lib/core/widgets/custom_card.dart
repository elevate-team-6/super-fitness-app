import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'custom_cached_image.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage =
        image.startsWith('http://') || image.startsWith('https://');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 163.w,
        height: 160.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: isNetworkImage
                  ? CustomCachedImage(imageUrl: image, fit: BoxFit.cover)
                  : Image.asset(image, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.w,
                      horizontal: 16.h,
                    ),
                    child: Text(
                      title,
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
