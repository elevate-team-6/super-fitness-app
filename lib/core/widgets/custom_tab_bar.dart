import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final EdgeInsetsGeometry? padding;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isScrollable = tabs.length > 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: isScrollable,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w),
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
        labelPadding: isScrollable
            ? EdgeInsets.symmetric(horizontal: 4.w)
            : EdgeInsets.zero,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: tabs
            .map((title) => Tab(
                  height: 30.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(title),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
