import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../profile/domain/repo/profile_repo_contract.dart';
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
  final ProfileRepoContract _profileRepo;

  StreamSubscription? _userSubscription;

  ChatCubit(
    this._getChatHistoryUseCase,
    this._getSessionMessagesUseCase,
    this._sendMessageUseCase,
    this._createSessionUseCase,
    this._deleteSessionUseCase,
    this._getChatUserUseCase,
    this._profileRepo,
  ) : super(
        const ChatState(
          historyStatus: BaseState(isLoading: true),
          messagesStatus: BaseState(data: []),
        ),
      ) {
    _loadUserData();
    _subscribeToUserChanges();
  }

  void _subscribeToUserChanges() {
    _userSubscription = _profileRepo.userStream.listen((user) {
      if (user != null) {
        emit(state.copyWith(user: user));
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
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

  // --- Send Message Flow (Refactored) ---

  Future<void> _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    // 1. Ensure we have an active session
    final sessionId = await _ensureActiveSession(cleanText);
    if (sessionId == null) return;

    // 2. Emit user message immediately for UX
    _emitUserMessageState(cleanText);

    // 3. Listen to the assistant stream and wait for it (Await this)
    try {
      await _listenToAssistantStream(sessionId, cleanText);
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()),
      );
      emitUiEvent(DisplayErrorEvent(e.toString()));
    }
  }

  Future<String?> _ensureActiveSession(String firstMessage) async {
    if (state.currentSessionId != null) return state.currentSessionId;

    final newId = const Uuid().v4();
    final title = firstMessage.length > 30
        ? "${firstMessage.substring(0, 30)}..."
        : firstMessage;

    final result = await _createSessionUseCase(newId, title);
    if (result is ErrorBaseResponse) {
      emitUiEvent(DisplayErrorEvent(result.errorMessage));
      return null;
    }

    emit(state.copyWith(currentSessionId: newId));
    await _loadHistory();
    return newId;
  }

  void _emitUserMessageState(String text) {
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
  }

  Future<void> _listenToAssistantStream(String sessionId, String text) async {
    final stream = _sendMessageUseCase(sessionId: sessionId, message: text);
    ChatMessageEntity? assistantMessage;
    bool hasError = false;

    await for (final result in stream) {
      if (kDebugMode) {
        debugPrint('ChatCubit: Received result from stream: $result');
      }

      switch (result) {
        case SuccessBaseResponse<ChatMessageEntity>():
          assistantMessage = _handleStreamResult(
            result.data!,
            assistantMessage,
          );
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

    _finalizeStream(hasError, assistantMessage);
  }

  ChatMessageEntity _handleStreamResult(
    ChatMessageEntity updatedMessage,
    ChatMessageEntity? currentAssistantMessage,
  ) {
    if (currentAssistantMessage == null) {
      final message = updatedMessage;
      emit(
        state.copyWith(
          messagesStatus: BaseState(data: [...state.messages, message]),
          status: ChatStatus.streaming,
        ),
      );
      return message;
    } else {
      final message = updatedMessage;
      final updatedMessages = List<ChatMessageEntity>.from(state.messages);
      final index = updatedMessages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        updatedMessages[index] = message;
      }
      emit(state.copyWith(messagesStatus: BaseState(data: updatedMessages)));
      return message;
    }
  }

  void _finalizeStream(bool hasError, ChatMessageEntity? assistantMessage) {
    if (hasError) return;

    if (assistantMessage == null || assistantMessage.text.trim().isEmpty) {
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
  }

  void _clearError() {
    emit(state.copyWith(status: ChatStatus.initial, clearError: true));
  }
}
