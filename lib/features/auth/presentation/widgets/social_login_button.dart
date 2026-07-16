import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final VoidCallback? onTap;

  const SocialLoginButton({super.key, this.assetPath, this.icon, this.onTap})
    : assert(assetPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      customBorder: const CircleBorder(),
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.black80,
        ),
        child: assetPath != null
            ? Padding(
                padding: EdgeInsets.all(12.w),
                child: Image.asset(assetPath!, fit: BoxFit.contain),
              )
            : Icon(icon, color: AppColors.white, size: 20.sp),
      ),
    );
  }
}
