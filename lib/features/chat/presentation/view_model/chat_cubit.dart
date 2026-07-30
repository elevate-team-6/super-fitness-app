import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/use_cases/create_session_use_case.dart';
import '../../domain/use_cases/delete_session_use_case.dart';
import '../../domain/use_cases/get_chat_history_use_case.dart';
import '../../domain/use_cases/get_chat_user_use_case.dart';
import '../../domain/use_cases/get_session_messages_use_case.dart';
import '../../domain/use_cases/send_message_use_case.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@lazySingleton
class ChatCubit extends BaseCubit<ChatState, BaseUiEvent> {
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final GetSessionMessagesUseCase _getSessionMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final DeleteSessionUseCase _deleteSessionUseCase;
  final GetChatUserUseCase _getChatUserUseCase;

  ChatCubit(
    this._getChatHistoryUseCase,
    this._getSessionMessagesUseCase,
    this._sendMessageUseCase,
    this._createSessionUseCase,
    this._deleteSessionUseCase,
    this._getChatUserUseCase,
  ) : super(const ChatState()) {
    _loadUserData();
  }

  void doEvent(ChatEvent event) {
    switch (event) {
      case LoadHistoryEvent():
        _loadHistory();
      case StartNewSessionEvent():
        _startNewSession();
      case LoadSessionEvent():
        _loadSession(event.sessionId);
      case DeleteSessionEvent():
        _deleteSession(event.sessionId);
      case SendMessageEvent():
        _sendMessage(event.text);
      case ClearErrorEvent():
        _clearError();
    }
  }

  Future<void> _loadUserData() async {
    final user = await _getChatUserUseCase();
    emit(state.copyWith(user: user));
  }

  Future<void> _loadHistory() async {
    emit(state.copyWith(historyStatus: const BaseState(isLoading: true)));
    final result = await _getChatHistoryUseCase();
    switch (result) {
      case SuccessBaseResponse<List<Map<String, String>>>():
        emit(state.copyWith(historyStatus: BaseState(data: result.data)));
      case ErrorBaseResponse<List<Map<String, String>>>():
        emit(
          state.copyWith(
            historyStatus: BaseState(errorMessage: result.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _startNewSession() async {
    emit(
      state.copyWith(
        forceNullSession: true,
        messagesStatus: const BaseState(data: []),
        status: ChatStatus.initial,
      ),
    );
  }

  Future<void> _loadSession(String sessionId) async {
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        currentSessionId: sessionId,
        messagesStatus: const BaseState(isLoading: true),
      ),
    );
    final result = await _getSessionMessagesUseCase(sessionId);
    switch (result) {
      case SuccessBaseResponse<List<ChatMessageEntity>>():
        emit(
          state.copyWith(
            messagesStatus: BaseState(data: result.data),
            status: ChatStatus.success,
          ),
        );
      case ErrorBaseResponse<List<ChatMessageEntity>>():
        emit(
          state.copyWith(
            status: ChatStatus.failure,
            errorMessage: result.errorMessage,
            messagesStatus: BaseState(errorMessage: result.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    emitUiEvent(ShowLoadingEvent());
    final result = await _deleteSessionUseCase(sessionId);
    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<void>():
        if (state.currentSessionId == sessionId) {
          emit(
            state.copyWith(
              currentSessionId: null,
              messagesStatus: const BaseState(data: []),
            ),
          );
        }
        await _loadHistory();
      case ErrorBaseResponse<void>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    String? activeSessionId = state.currentSessionId;

    // Handle session creation if this is the first message
    if (activeSessionId == null) {
      activeSessionId = const Uuid().v4();
      final title = text.length > 30 ? "${text.substring(0, 30)}..." : text;
      final result = await _createSessionUseCase(activeSessionId, title);
      if (result is ErrorBaseResponse) {
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
        return;
      }
      emit(state.copyWith(currentSessionId: activeSessionId));
      await _loadHistory();
    }

    final sessionId = activeSessionId;
    final userMessage = ChatMessageEntity(
      id: const Uuid().v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    emit(
      state.copyWith(
        messagesStatus: BaseState(data: [...state.messages, userMessage]),
        status: ChatStatus.loading,
        lastPendingMessage: text,
      ),
    );

    try {
      final stream = _sendMessageUseCase(sessionId: sessionId, message: text);
      ChatMessageEntity? assistantMessage;
      bool hasError = false;

      await for (final result in stream) {
        switch (result) {
          case SuccessBaseResponse<ChatMessageEntity>():
            final updatedMessage = result.data!;
            if (assistantMessage == null) {
              assistantMessage = updatedMessage;
              emit(
                state.copyWith(
                  messagesStatus: BaseState(
                    data: [...state.messages, assistantMessage],
                  ),
                  status: ChatStatus.streaming,
                ),
              );
            } else {
              assistantMessage = updatedMessage;
              final updatedMessages = List<ChatMessageEntity>.from(
                state.messages,
              );
              final index = updatedMessages.indexWhere(
                (m) => m.id == assistantMessage!.id,
              );
              if (index != -1) {
                updatedMessages[index] = assistantMessage;
              }
              emit(
                state.copyWith(
                  messagesStatus: BaseState(data: updatedMessages),
                ),
              );
            }
          case ErrorBaseResponse<ChatMessageEntity>():
            hasError = true;
            emit(
              state.copyWith(
                status: ChatStatus.failure,
                errorMessage: result.errorMessage,
              ),
            );
            emitUiEvent(DisplayErrorEvent(result.errorMessage));
            return;
        }
      }

      if (!hasError &&
          (assistantMessage == null || assistantMessage.text.trim().isEmpty)) {
        emit(
          state.copyWith(
            status: ChatStatus.failure,
            errorMessage: AppStrings.chatUnexpectedError.tr(),
          ),
        );
        emitUiEvent(DisplayErrorEvent(AppStrings.chatUnexpectedError.tr()));
      } else {
        emit(
          state.copyWith(status: ChatStatus.success, lastPendingMessage: null),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()),
      );
      emitUiEvent(DisplayErrorEvent(e.toString()));
    }
  }

  void _clearError() {
    emit(state.copyWith(status: ChatStatus.initial, errorMessage: null));
  }
}
