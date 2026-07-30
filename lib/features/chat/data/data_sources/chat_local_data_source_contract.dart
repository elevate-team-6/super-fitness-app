import '../../../../config/base_response/base_response.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../models/hive/chat_hive_models.dart';

/// Contract for the Local Data Source of the Chat feature.
///
/// Handles persistent storage of chat sessions and messages using Hive.
abstract interface class ChatLocalDataSourceContract {
  /// Retrieves the cached user data if available.
  Future<BaseResponse<UserEntity?>> getCachedUser();

  /// Saves a new chat session to local storage.
  Future<BaseResponse<void>> saveSession(ChatSessionHiveModel session);

  /// Updates the message list of an existing session.
  Future<BaseResponse<void>> updateSessionMessages(
    String sessionId,
    List<ChatMessageHiveModel> messages,
  );

  /// Updates the title of an existing session.
  Future<BaseResponse<void>> updateSessionTitle(String sessionId, String title);

  /// Retrieves all saved chat sessions, sorted by last update time.
  Future<BaseResponse<List<ChatSessionHiveModel>>> getSessions();

  /// Retrieves a specific chat session by its ID.
  Future<BaseResponse<ChatSessionHiveModel?>> getSession(String sessionId);

  /// Deletes a specific chat session and its messages.
  Future<BaseResponse<void>> deleteSession(String sessionId);

  /// Clears all chat-related data from local storage.
  Future<BaseResponse<void>> clearAll();
}
