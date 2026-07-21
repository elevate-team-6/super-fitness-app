import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_colors.dart';

import '../utils/app_assets.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  final BorderRadius? borderRadius;

  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,

      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),

      // No Expanded here: CachedNetworkImage hands this widget to a SizedBox,
      // not a Flex, so an Expanded throws a ParentDataWidget assertion on every
      // failed load. The ColoredBox fills whatever the caller constrained us to.
      errorWidget: (context, url, error) =>
          errorWidget ??
          ColoredBox(
            color: AppColors.orange30,
            child: Center(
              child: SvgPicture.asset(
                AppIcons.workOut,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
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
}
