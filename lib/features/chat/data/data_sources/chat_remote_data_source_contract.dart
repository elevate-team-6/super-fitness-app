import '../../../../config/base_response/base_response.dart';
import '../models/chat_event_model.dart';

/// Contract for the Remote Data Source of the Chat feature.
///
/// This layer is responsible for converting domain-specific requests into
/// API calls and returning models.
abstract interface class ChatRemoteDataSourceContract {
  /// Streams chat events from the remote server.
  ///
  /// [message] The message sent by the user.
  /// [token] Valid JWT token for authentication.
  /// [userContext] Personalized data for the AI model.
  Stream<BaseResponse<ChatEventModel>> getChatResponseStream({
    required String message,
    required String token,
    Map<String, dynamic>? userContext,
  });
}
