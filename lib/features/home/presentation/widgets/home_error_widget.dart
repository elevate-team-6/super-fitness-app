import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

class HomeErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.white16500,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: 88.w,
              child: ElevatedButton(
                onPressed: onRetry,
                child: Text(AppStrings.retry.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
