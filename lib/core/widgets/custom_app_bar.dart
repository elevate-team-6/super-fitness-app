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
  final double? height;
  final String? backgroundImage;
  final Widget? bottomContent;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.onBackPressed,
    this.actions,
    this.centerTitle,
    this.height,
    this.backgroundImage,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    if (backgroundImage != null) {
      return _buildImageAppBar(context);
    }
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
                      matchTextDirection: true,
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

  Widget _buildImageAppBar(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20.r),
        ),
        image: DecorationImage(
          image: AssetImage(backgroundImage!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: const [
                  AppColors.black80,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onBackPressed != null)
                        GestureDetector(
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
                              matchTextDirection: true,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (actions != null)
                        Row(mainAxisSize: MainAxisSize.min, children: actions!)
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: centerTitle == true
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        title is Widget
                            ? title
                            : Text(
                                title.toString(),
                                style: AppTextStyles.white31500,
                                textAlign: centerTitle == true
                                    ? TextAlign.center
                                    : TextAlign.start,
                              ),
                      if (subtitle != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          subtitle!,
                          style: AppTextStyles.white16500,
                          textAlign: centerTitle == true
                              ? TextAlign.center
                              : TextAlign.start,
                        ),
                      ],
                      if (bottomContent != null) ...[
                      SizedBox(height: 8.h),
                        bottomContent!,
                      ],
                      SizedBox(height: 8.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
  Size get preferredSize => Size.fromHeight(
    height ?? (backgroundImage != null ? 400.h : (kToolbarHeight + (subtitle != null ? 20.h : 0))),
  );
}
