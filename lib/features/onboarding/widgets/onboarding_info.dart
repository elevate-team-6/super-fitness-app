import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/onboarding/widgets/onboarding_indicator.dart';

import '../../../core/widgets/custom_glass_container.dart';
import '../screens/onboarding_screen.dart';

class OnboardingInfo extends StatelessWidget {
  final OnboardingModel model;
  final int itemCount;
  final int currentIndex;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingInfo({
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
            model.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.white24700,
          ),
          SizedBox(height: 12.h),
          Text(
            model.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.white13400,
          ),
          SizedBox(height: 24.h),
          OnboardingIndicator(itemCount: itemCount, currentIndex: currentIndex),
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
                      Spacer(),
                      SizedBox(
                        width: 93,
                        child: ElevatedButton(
                          onPressed: onNext,
                          child: Text(
                            isLast
                                ? AppStrings.doIt.tr()
                                : AppStrings.next.tr(),
                            style: AppTextStyles.white16500.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
