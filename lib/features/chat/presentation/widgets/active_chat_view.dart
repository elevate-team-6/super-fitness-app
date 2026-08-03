import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/app_assets.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../view_model/chat_cubit.dart';
import '../view_model/chat_event.dart';
import '../view_model/chat_state.dart';
import 'chat_bubbles.dart';
import 'chat_input_field.dart';
import 'typing_indicator.dart';

class ActiveChatView extends StatelessWidget {
  final ChatState state;
  final ScrollController scrollController;
  final TextEditingController messageController;

  const ActiveChatView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.messageController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          state.messages.isEmpty
              ? Expanded(
                  child: Center(
                    child: Lottie.asset(
                      AppLottie.aiChatBot,
                      height: 0.8.sh,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    itemCount:
                        state.messages.length +
                        (state.status == ChatStatus.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const TypingIndicator();
                      }
                      final message = state.messages[index];
                      return message.sender == MessageSender.assistant
                          ? AssistantBubble(message: message)
                          : UserBubble(
                              message: message,
                              userImage: state.user?.photo,
                            );
                    },
                  ),
                ),
          ChatInputField(
            controller: messageController,
            status: state.status,
            onSend: () {
              final text = messageController.text.trim();
              if (text.isNotEmpty) {
                messageController.clear();
                context.read<ChatCubit>().doEvent(SendMessageEvent(text));
              }
            },
          ),
        ],
      ),
    );
  }
}
