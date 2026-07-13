import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class OnboardingSkipButton extends StatelessWidget {
  final PageController pageController;
  final int currentIndex;
  final int itemCount;

  const OnboardingSkipButton({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= itemCount - 1) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: TextButton(
          onPressed: () {
            pageController.animateToPage(
              itemCount - 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: Text(AppStrings.skip.tr(), style: AppTextStyles.white13500),
        ),
      ),
    );
  }
}
