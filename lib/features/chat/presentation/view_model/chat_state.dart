import 'package:equatable/equatable.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

enum ChatStatus { initial, loading, streaming, success, failure }

class ChatState extends Equatable {
  // BaseStates for different operations
  final BaseState<List<Map<String, String>>> historyStatus;
  final BaseState<List<ChatMessageEntity>> messagesStatus;
  final BaseState<ChatMessageEntity> sendMessageStatus;

  // General State
  final ChatStatus status;
  final String? errorMessage;
  final String? lastPendingMessage;
  final String? currentSessionId;
  final UserEntity? user;

  // Helper getters to maintain UI compatibility
  List<Map<String, String>> get history => historyStatus.data ?? [];
  List<ChatMessageEntity> get messages => messagesStatus.data ?? [];

  const ChatState({
    this.historyStatus = const BaseState(),
    this.messagesStatus = const BaseState(),
    this.sendMessageStatus = const BaseState(),
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.lastPendingMessage,
    this.currentSessionId,
    this.user,
  });

  ChatState copyWith({
    BaseState<List<Map<String, String>>>? historyStatus,
    BaseState<List<ChatMessageEntity>>? messagesStatus,
    BaseState<ChatMessageEntity>? sendMessageStatus,
    ChatStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? lastPendingMessage,
    String? currentSessionId,
    bool forceNullSession = false,
    UserEntity? user,
  }) {
    return ChatState(
      historyStatus: historyStatus ?? this.historyStatus,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastPendingMessage: lastPendingMessage ?? this.lastPendingMessage,
      currentSessionId: forceNullSession
          ? null
          : (currentSessionId ?? this.currentSessionId),
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
    historyStatus,
    messagesStatus,
    sendMessageStatus,
    status,
    errorMessage,
    lastPendingMessage,
    currentSessionId,
    user,
  ];
}
