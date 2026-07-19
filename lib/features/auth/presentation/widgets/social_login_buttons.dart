import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onFacebookTap;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  const SocialLoginButtons({
    super.key,
    this.onFacebookTap,
    this.onGoogleTap,
    this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(endIndent: 32, indent: 40)),
            Text(AppStrings.or.tr(), style: AppTextStyles.white13400),
            const Expanded(child: Divider(endIndent: 40, indent: 32)),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(iconPath: AppIcons.facebook, onTap: onFacebookTap),
            SizedBox(width: 16.w),
            _SocialButton(iconPath: AppIcons.google, onTap: onGoogleTap),
            SizedBox(width: 16.w),
            _SocialButton(iconPath: AppIcons.apple, onTap: onAppleTap),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onTap;

  const _SocialButton({required this.iconPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 36.w,
        height: 36.h,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppColors.black80,
        ),
        child: Center(
          child: SvgPicture.asset(iconPath, width: 24.w, height: 24.h),
        ),
      ),
    );
  }
}
