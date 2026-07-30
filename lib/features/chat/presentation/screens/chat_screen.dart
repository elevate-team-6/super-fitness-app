import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_cubit.dart';
import 'package:super_fitness/features/chat/presentation/view_model/chat_state.dart';

import '../widgets/active_chat_view.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.chatBackground,
      appBar: CustomAppBar(
        onBackPressed: () => Navigator.pop(context),
        title: Text(AppStrings.chat.tr(), style: AppTextStyles.white18700),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.streaming ||
              state.status == ChatStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
          }
          if (state.status == ChatStatus.failure &&
              state.lastPendingMessage != null) {
            _controller.text = state.lastPendingMessage!;
          }
        },
        builder: (context, state) {
          return ActiveChatView(
            messageController: _controller,
            state: state,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
}
