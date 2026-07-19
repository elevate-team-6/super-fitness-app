import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/app_text_styles.dart';

class LanguageSwitchWidget extends StatelessWidget {
  const LanguageSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if EasyLocalization is available (useful for tests and avoiding crashes)
    Locale? currentLocale;
    try {
      currentLocale = context.locale;
    } catch (e) {
      currentLocale = null;
    }

    if (currentLocale == null) {
      return const SizedBox.shrink();
    }

    final isArabic = currentLocale.languageCode == AppConstants.arabicCode;

    return GestureDetector(
      onTap: () {
        if (isArabic) {
          context.setLocale(const Locale(AppConstants.englishCode));
        } else {
          context.setLocale(const Locale(AppConstants.arabicCode));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white30.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          currentLocale.languageCode.toUpperCase(),
          style: AppTextStyles.primary20500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
