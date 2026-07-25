import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgIcon extends StatelessWidget {
  final String iconPath;
  final double? size;
  final Color? color;

  const CustomSvgIcon({
    super.key,
    required this.iconPath,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final double effectiveSize = size ?? iconTheme.size ?? 24.0;
    final Color effectiveColor = color ?? iconTheme.color ?? Colors.black;

    return SvgPicture.asset(
      iconPath,
      width: effectiveSize,
      height: effectiveSize,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
