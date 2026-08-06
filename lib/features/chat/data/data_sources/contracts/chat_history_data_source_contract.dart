import 'package:super_fitness/config/base_response/base_response.dart';
import '../../models/chat_models.dart';

/// Contract for the Chat History Data Source (Remote Persistence).
abstract interface class ChatHistoryDataSourceContract {
  /// Saves a new chat session.
  Future<BaseResponse<void>> saveSession(ChatSessionModel session);

  /// Updates the message list of an existing session.
  Future<BaseResponse<void>> updateSessionMessages(
    String sessionId,
    List<ChatMessageModel> messages,
  );

  /// Updates the title of an existing session.
  Future<BaseResponse<void>> updateSessionTitle(String sessionId, String title);

  /// Retrieves all saved chat sessions, sorted by last update time.
  Future<BaseResponse<List<ChatSessionModel>>> getSessions();

  /// Retrieves a specific chat session by its ID.
  Future<BaseResponse<ChatSessionModel?>> getSession(String sessionId);

  /// Deletes a specific chat session and its messages.
  Future<BaseResponse<void>> deleteSession(String sessionId);

  /// Clears all chat-related data.
  Future<BaseResponse<void>> clearAll();
}
