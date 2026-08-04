import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_glass_container.dart';
import '../../presentation/view_model/chat_cubit.dart';
import '../../presentation/view_model/chat_state.dart';

class ChatWelcomeView extends StatelessWidget {
  final VoidCallback onGetStarted;

  const ChatWelcomeView({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, chatState) {
        final userName =
            (chatState.user?.firstName != null &&
                chatState.user!.firstName!.isNotEmpty)
            ? chatState.user!.firstName!
            : AppStrings.athlete.tr();
        return Column(
          children: [
            SizedBox(height: 100.h),
            Text(
              AppStrings.hi.tr(args: [userName]),
              style: AppTextStyles.white18500,
            ),
            Text(AppStrings.smartCoach.tr(), style: AppTextStyles.white24700),
            SizedBox(height: 24.h),
            Expanded(
              child: Center(
                child: Image.asset(
                  AppImages.smartCoach,
                  height: 0.5.sh,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            CustomGlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.howCanIAssistYouToday.tr(),
                    style: AppTextStyles.white20800,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: onGetStarted,
                    child: Text(AppStrings.getStarted.tr()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 120.h), // Spacing for bottom nav
          ],
        );
      },
    );
  }
}
