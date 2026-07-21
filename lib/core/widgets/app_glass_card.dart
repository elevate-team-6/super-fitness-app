import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_glass_container.dart';

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomGlassContainer(
      width: width,
      height: height,
      blur: 20,
      opacity: 0.2,
      borderRadius: borderRadius ?? BorderRadius.circular(16.r),
      padding: padding ?? EdgeInsets.all(12.w),
      child: child,
    );
  }
}
