import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_colors.dart';

import '../utils/app_assets.dart';
import 'app_shimmer.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  final BorderRadius? borderRadius;

  final Widget? placeholder;
  final Widget? errorWidget;
  final String? placeholderIcon;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),

      // No Expanded here: CachedNetworkImage hands this widget to a SizedBox,
      // not a Flex, so an Expanded throws a ParentDataWidget assertion on every
      // failed load. The ColoredBox fills whatever the caller constrained us to.
      errorWidget: (context, url, error) =>
          errorWidget ??
          ColoredBox(
            color: AppColors.black80,
            child: Center(
              child: SvgPicture.asset(
                placeholderIcon ?? AppIcons.workOut,
                width: 72.w,
                height: 72.w,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withValues(alpha: 0.5),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppShimmer(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          borderRadius: borderRadius ?? BorderRadius.circular(20.r),
          baseColor: AppColors.white.withValues(alpha: 0.05),
          highlightColor: AppColors.white.withValues(alpha: 0.12),
        ),
        SvgPicture.asset(
          placeholderIcon ?? AppIcons.workOut,
          width: 60.w,
          height: 60.w,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            AppColors.primary.withValues(alpha: 0.5),
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}
