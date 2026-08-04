import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../view_model/chat_state.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final ChatStatus status;
  final VoidCallback onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.status,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        status == ChatStatus.loading || status == ChatStatus.streaming;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        // Align items to the bottom as the field grows
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 50.h),
              decoration: BoxDecoration(
                color: AppColors.black90.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.white14400,
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: AppStrings.typeAMessage.tr(),
                  hintStyle: AppTextStyles.white13400.copyWith(
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: Container(
              width: 50.w,
              height: 50.w,
              margin: EdgeInsets.only(bottom: 0.h),
              // Stay at the bottom
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_outlined,
                color: isLoading
                    ? AppColors.white.withValues(alpha: 0.5)
                    : AppColors.white,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
