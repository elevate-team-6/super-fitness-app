import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool? centerTitle;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.onBackPressed,
    this.actions,
    this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      leading: onBackPressed != null
          ? Padding(
              padding: EdgeInsetsDirectional.only(start: 16.w),
              child: Center(
                child: GestureDetector(
                  onTap: onBackPressed,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      AppIcons.back,
                      width: 12.w,
                      height: 12.w,
                    ),
                  ),
                ),
              ),
            )
          : null,
      leadingWidth: onBackPressed != null ? 56.w : null,
      title: _buildTitle(),
      actions: actions != null ? [...actions!, SizedBox(width: 16.w)] : null,
    );
  }

  Widget _buildTitle() {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: centerTitle == true
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title is String ? title : '', style: AppTextStyles.white16500),
          Text(subtitle!, style: AppTextStyles.white24700),
        ],
      );
    }

    if (title is String) {
      return Text(title, style: AppTextStyles.white20500);
    }

    if (title is Widget) {
      return title;
    }

    return Image.asset(AppIcons.fitnessAppIcon, height: 48.h);
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (subtitle != null ? 20.h : 0));
}
