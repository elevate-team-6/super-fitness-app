import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool isSliver;

  const CustomGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: crossAxisSpacing ?? 16.w,
      mainAxisSpacing: mainAxisSpacing ?? 16.h,
      childAspectRatio: 163 / 160,
    );

    if (isSliver) {
      return SliverPadding(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        sliver: SliverGrid(
          gridDelegate: gridDelegate,
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      gridDelegate: gridDelegate,
      itemBuilder: itemBuilder,
    );
  }
}
