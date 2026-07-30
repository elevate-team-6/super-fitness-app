import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;

  const CustomGlassContainer({
    super.key,
    required this.child,
    this.blur = 34.6,
    this.opacity = 0.1,
    this.color = AppColors.black80,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(50);

    final surface = Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: effectiveBorderRadius,
        border: border,
      ),
      child: child,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        // A BackdropFilter drops its backdrop once it moves inside a scroll
        // viewport, so callers in a scrollable pass `blur: 0` and lean on the
        // tint alone — the same escape hatch AppScaffold offers.
        child: blur <= 0
            ? surface
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: surface,
              ),
      ),
    );
  }
}
