import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../view_model/chat_cubit.dart';
import '../view_model/chat_event.dart';
import '../view_model/chat_state.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().doEvent(const LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    return Drawer(
      backgroundColor: AppColors.black,
      width: 0.75.sw,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.previousConversations.tr(),
                    style: AppTextStyles.white18700,
                  ),
                  IconButton(
                    onPressed: () {
                      chatCubit.doEvent(const StartNewSessionEvent());
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.chat);
                    },
                    icon: const Icon(Icons.add, color: AppColors.primary),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    final history = state.history;
                    if (history.isEmpty) {
                      return Center(
                        child: Text(
                          'No previous conversations',
                          style: AppTextStyles.white13400.copyWith(
                            color: AppColors.white20,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.white.withValues(alpha: 0.1),
                        height: 24.h,
                      ),
                      itemBuilder: (context, index) {
                        final session = history[index];
                        final sessionId = session['id']!;
                        final isCurrent = state.currentSessionId == sessionId;

                        return GestureDetector(
                          onTap: () {
                            final navigator = Navigator.of(context);
                            chatCubit.doEvent(LoadSessionEvent(sessionId));
                            if (context.mounted) {
                              navigator.pop(); // Close drawer
                              navigator.pushNamed(AppRoutes.chat);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            color: Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.white20,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    session['title'] ?? 'Untitled',
                                    style: AppTextStyles.white13400.copyWith(
                                      color: isCurrent
                                          ? AppColors.primary
                                          : AppColors.white,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => chatCubit.doEvent(
                                    DeleteSessionEvent(sessionId),
                                  ),
                                  icon: Icon(
                                    Icons.delete,
                                    color: AppColors.red.withValues(alpha: 0.5),
                                    size: 16.sp,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
