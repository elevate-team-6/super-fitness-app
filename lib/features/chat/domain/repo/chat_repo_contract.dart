import '../../../../config/base_response/base_response.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/chat_message_entity.dart';

abstract interface class ChatRepoContract {
  /// Retrieves the cached user data.
  Future<BaseResponse<UserEntity?>> getCachedUser();

  Stream<BaseResponse<ChatMessageEntity>> sendMessage({
    required String sessionId,
    required String message,
  });

  Future<BaseResponse<List<ChatMessageEntity>>> getSessionMessages(
    String sessionId,
  );

  /// Returns list of {id, title}
  Future<BaseResponse<List<Map<String, String>>>> getChatHistory();

  Future<BaseResponse<void>> deleteSession(String id);

  Future<BaseResponse<void>> createSession(String id, String title);

  Future<BaseResponse<void>> updateSessionTitle(String id, String title);
}
