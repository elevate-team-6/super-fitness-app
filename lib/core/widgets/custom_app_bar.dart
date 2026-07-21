import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'custom_cached_image.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool? centerTitle;
  final double? height;
  final String? backgroundImage;
  final bool showGradientShadow;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.onBackPressed,
    this.actions,
    this.centerTitle,
    this.height,
    this.backgroundImage,
    this.showGradientShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (backgroundImage != null) {
      return _buildImageAppBar(context);
    }

    return AppBar(
      centerTitle: centerTitle,
      leading: _buildLeading(),
      leadingWidth: onBackPressed != null ? 56.w : null,
      title: _buildTitle(),
      actions: actions != null ? [...actions!, SizedBox(width: 16.w)] : null,
    );
  }

  Widget _buildLeading() {
    if (onBackPressed == null) return const SizedBox.shrink();
    return Padding(
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
    );
  }

  Widget _buildImageAppBar(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: AppColors.black,
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: CustomCachedImage(
              imageUrl: backgroundImage!,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Shadow
          if (showGradientShadow)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (onBackPressed != null) _buildLeading(),
                      const Spacer(),
                      ...?actions,
                    ],
                  ),
                  const Spacer(),
                  _buildTitleContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleContent() {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: centerTitle == true
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title is String ? title : '', style: AppTextStyles.white24700),
          SizedBox(height: 4.h),
          Text(
            subtitle!,
            style: AppTextStyles.white13500,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (title is String) {
      return Text(title, style: AppTextStyles.white24700);
    }

    if (title is Widget) {
      return title;
    }

    return const SizedBox.shrink();
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
    height ??
        (backgroundImage != null
            ? 350.h
            : (kToolbarHeight + (subtitle != null ? 20.h : 0))),
  );
}
