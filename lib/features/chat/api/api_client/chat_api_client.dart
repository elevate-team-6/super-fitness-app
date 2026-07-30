import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_end_points.dart';
import '../../../../../core/utils/app_keys.dart';
import '../../../../../core/utils/app_params.dart';

/// [ChatApiClient] is the low-level network client responsible for handling
/// HTTP requests and SSE (Server-Sent Events) streaming for the Chat feature.
///
/// This represents the 4th layer in our architecture, isolating the [http] package
/// dependencies from the Data Sources.
@lazySingleton
class ChatApiClient {
  final http.Client _client = http.Client();

  /// Establishes a POST request for SSE streaming.
  ///
  /// [message] The user's input message.
  /// [token] The authorization token.
  /// [userContext] Optional context containing physical attributes and goals.
  Future<http.StreamedResponse> getChatResponse({
    required String message,
    required String token,
    Map<String, dynamic>? userContext,
  }) async {
    final request = http.Request(
      'POST',
      Uri.parse(AppEndPoints.chatGatewayUrl),
    );

    // Using constants from AppKeys instead of hardcoded strings
    request.headers.addAll({
      AppKeys.authorizationKey: "${AppKeys.bearerPrefix} $token",
      "Accept": "text/event-stream",
      "Content-Type": "application/json",
      "Cache-Control": "no-cache",
    });

    final Map<String, dynamic> body = {ApiParameters.message: message};
    if (userContext != null) {
      body.addAll(userContext);
    }
    request.body = jsonEncode(body);

    return _client.send(request);
  }

  /// Closes the underlying HTTP client.
  void close() {
    _client.close();
  }
}
