import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/services/crashlytics_service.dart';

@lazySingleton
class OllamaConfig {
  final CrashlyticsService _crashlyticsService;

  OllamaConfig(this._crashlyticsService);

  static const String baseUrl = "https://api.ollama.com";
  static const String model = "gemma4:31b";

  /// Reads API Key from environment variables at compile time.
  /// Use --dart-define=OLLAMA_API_KEY=your_key when building/running.
  static const String apiKey = String.fromEnvironment('OLLAMA_API_KEY');

  bool get isConfigured => apiKey.isNotEmpty;

  Map<String, String> buildHeaders() {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  /// Validates the API Key and logs a warning or reports to Crashlytics.
  void validateConfig() {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint('WARNING: OLLAMA_API_KEY is not defined!');
        debugPrint(
          'Please run the app with --dart-define=OLLAMA_API_KEY=your_actual_key',
        );
      } else {
        _crashlyticsService.recordError(
          'OLLAMA_API_KEY is missing in Release build',
          StackTrace.current,
          reason: 'Configuration Error',
        );
      }
    }
  }
}
