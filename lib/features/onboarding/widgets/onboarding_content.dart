import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_glass_container.dart';
import '../models/onboarding_model.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingModel model;
  final int itemCount;
  final int currentIndex;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingContent({
    super.key,
    required this.model,
    required this.itemCount,
    required this.currentIndex,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirst = currentIndex == 0;
    final bool isLast = currentIndex == itemCount - 1;

    return CustomGlassContainer(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
      borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            model.title.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.white24700,
          ),
          SizedBox(height: 12.h),
          Text(
            model.description.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.white13400,
          ),
          SizedBox(height: 24.h),
          _OnboardingIndicator(
            itemCount: itemCount,
            currentIndex: currentIndex,
          ),
          SizedBox(height: 32.h),
          isFirst
              ? ElevatedButton(
                  onPressed: onNext,
                  child: Text(
                    isLast ? AppStrings.doIt.tr() : AppStrings.next.tr(),
                    style: AppTextStyles.white16500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Row(
                  children: [
                    if (!isFirst) ...[
                      SizedBox(
                        width: 93,
                        child: OutlinedButton(
                          onPressed: onBack,
                          child: Text(
                            AppStrings.back.tr(),
                            style: AppTextStyles.white16500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(85.w, 40.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        onPressed: onNext,
                        child: Text(
                          isLast ? AppStrings.doIt.tr() : AppStrings.next.tr(),
                          style: AppTextStyles.white16500.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const _OnboardingIndicator({
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: isActive ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.white40,
            borderRadius: BorderRadius.circular(100.r),
          ),
        );
      }),
    );
  }
}
