import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class CustomEmptyStateView extends StatelessWidget {
  final String message;
  final String? subtitle;
  final String lottiePath;
  final VoidCallback? onRetry;
  final String? retryText;
  final double? imageSize;

  const CustomEmptyStateView({
    super.key,
    required this.message,
    this.subtitle,
    this.lottiePath =
        AppLottie.loading, // temporary until we have other lottie files
    this.onRetry,
    this.retryText,
    this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild this widget's texts when the locale changes (no state reset).
    context.locale;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottiePath,
              width: imageSize ?? 200.w,
              height: imageSize ?? 200.h,
              repeat: true,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.black16500,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.white2016500,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(
                  retryText ?? AppStrings.retry.tr(),
                  style: AppTextStyles.white2016500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
