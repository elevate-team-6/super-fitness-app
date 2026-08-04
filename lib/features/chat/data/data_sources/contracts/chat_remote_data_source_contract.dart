import 'package:super_fitness/config/base_response/base_response.dart';
import '../../models/chat_event_model.dart';

/// Contract for the Remote Data Source of the Chat feature.
///
/// This layer is responsible for converting domain-specific requests into
/// API calls and returning models.
abstract interface class ChatRemoteDataSourceContract {
  /// Streams chat events from the remote server.
  ///
  /// [history] The conversation history as a list of maps (role and content).
  /// [userContext] Personalized data for the AI model.
  Stream<BaseResponse<ChatEventModel>> getChatResponseStream({
    required List<Map<String, String>> history,
    Map<String, dynamic>? userContext,
  });
}
