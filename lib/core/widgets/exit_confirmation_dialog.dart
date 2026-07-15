import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key, this.onConfirm});

  static Future<void> show(BuildContext context, {VoidCallback? onConfirm}) {
    return showDialog<void>(
      context: context,
      builder: (_) => ExitConfirmationDialog(onConfirm: onConfirm),
    );
  }

  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.black90,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      // Buttons live in the content so they stay on one row: AlertDialog's
      // `actions` bar wraps them onto separate lines once they get wide.
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.exitConfirmation.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.white24700.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.no.tr(),
                    style: AppTextStyles.white16500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    (onConfirm ?? SystemNavigator.pop)();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.yes.tr(),
                    style: AppTextStyles.white16500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
