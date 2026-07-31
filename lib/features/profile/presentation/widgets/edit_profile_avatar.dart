import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';

class EditProfileAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final File? selectedImage;
  final VoidCallback onPickImage;

  const EditProfileAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final size = 110.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: SizedBox(
                width: size,
                height: size,
                child: selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                    : photoUrl.isEmpty
                    ? ColoredBox(
                        color: AppColors.black80,
                        child: Padding(
                          padding: EdgeInsets.all(28.w),
                          child: SvgPicture.asset(
                            AppIcons.person,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      )
                    : CustomCachedImage(
                        imageUrl: photoUrl,
                        width: size,
                        height: size,
                        placeholderIcon: AppIcons.person,
                      ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onPickImage,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black90.withValues(alpha: 0.6),
                    border: Border.all(color: AppColors.primary, width: 1.5.w),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16.w,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (name.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(name, style: AppTextStyles.white20800),
        ],
      ],
    );
  }
}
