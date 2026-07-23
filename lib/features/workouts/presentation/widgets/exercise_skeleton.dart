import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';

class ExerciseSkeleton extends StatelessWidget {
  const ExerciseSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.black80,
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            color: AppColors.black70,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkeletonLine(width: 140.w, height: 14.h),
                SizedBox(height: 8.h),
                _SkeletonLine(width: 100.w, height: 12.h),
                SizedBox(height: 6.h),
                _SkeletonLine(width: 80.w, height: 12.h),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.black70,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.black70,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
