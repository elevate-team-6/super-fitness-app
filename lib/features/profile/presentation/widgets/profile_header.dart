import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';

/// Avatar + name block above the menu.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String photo;

  const ProfileHeader({super.key, required this.name, this.photo = ''});

  @override
  Widget build(BuildContext context) {
    final size = 110.w;

    return Column(
      children: [
        ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: photo.isEmpty
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
                    imageUrl: photo,
                    width: size,
                    height: size,
                    placeholderIcon: AppIcons.person,
                  ),
          ),
        ),
        if (name.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(name, style: AppTextStyles.white20800),
        ],
      ],
    );
  }
}
