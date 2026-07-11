import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_strings.dart';

class ExitAppDialog extends StatelessWidget {
  const ExitAppDialog({super.key});

  /// بيعرض الـ dialog ويرجّع true لو المستخدم اختار يخرج
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const ExitAppDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // AlertDialog automatically uses dialogTheme from AppTheme
      title: Text(AppStrings.exitAppTitle.tr(), textAlign: TextAlign.center),
      content: Text(
        AppStrings.exitAppMessage.tr(),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppStrings.no.tr()),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppStrings.yes.tr()),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.w),
    );
  }
}
