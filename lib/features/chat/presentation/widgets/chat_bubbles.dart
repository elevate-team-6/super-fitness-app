import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'ref_carousel.dart';

class AssistantBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const AssistantBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: const AssetImage(AppImages.coachProfile),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black90.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.r),
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: AppTextStyles.white14400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 30.w), // Space on the right
              ],
            ),
          ),
          if (message.refs.isNotEmpty) ...[
            SizedBox(height: 16.h),
            RefCarousel(refs: message.refs),
          ],
        ],
      ),
    );
  }
}

class UserBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final String? userImage;

  const UserBubble({super.key, required this.message, this.userImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 12.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 30.w), // Space on the left
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.red.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Text(message.text, style: AppTextStyles.white14400),
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.black80,
            backgroundImage: userImage != null && userImage!.startsWith('http')
                ? NetworkImage(userImage!)
                : null,
            child: userImage == null || !userImage!.startsWith('http')
                ? Icon(Icons.person, color: AppColors.white, size: 20.sp)
                : null,
          ),
        ],
      ),
    );
  }
}
