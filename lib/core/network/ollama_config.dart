import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OllamaConfig {
  static const String baseUrl = "https://api.ollama.com";
  static const String model = "gemma4:31b";

  /// Reads API Key from environment variables at compile time.
  /// Use --dart-define=OLLAMA_API_KEY=your_key when building/running.
  static const String apiKey = String.fromEnvironment('OLLAMA_API_KEY');

  Map<String, String> buildHeaders() {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  /// Validates the API Key and logs a warning if missing.
  void validateConfig() {
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('WARNING: OLLAMA_API_KEY is not defined!');
        debugPrint(
          'Please run the app with --dart-define=OLLAMA_API_KEY=your_actual_key',
        );
      }
    }
  }
}
