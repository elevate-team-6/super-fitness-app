import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_shimmer.dart';

class HomeSectionsShimmer extends StatelessWidget {
  const HomeSectionsShimmer._();

  static Widget userInfoShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppShimmer(width: 120.w, height: 16.h),
        SizedBox(height: 8.h),
        AppShimmer(width: 200.w, height: 24.h),
      ],
    );
  }

  static Widget recommendationToday() {
    return SizedBox(
      height: 104.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(end: 12.w),
          child: AppShimmer(
            width: 104.w,
            height: 104.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  static Widget upcomingWorkoutsTabs() {
    return SizedBox(
      height: 32.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(end: 8.w),
          child: AppShimmer(
            width: 80.w,
            height: 32.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  static Widget upcomingWorkoutsList() {
    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(end: 12.w),
          child: AppShimmer(
            width: 80.w,
            height: 80.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  static Widget recommendationForYou() {
    return SizedBox(
      height: 104.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(end: 12.w),
          child: AppShimmer(
            width: 104.w,
            height: 104.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  static Widget popularTraining() {
    return SizedBox(
      height: 175.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(end: 16.w),
          child: AppShimmer(
            width: 200.w,
            height: 175.h,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
