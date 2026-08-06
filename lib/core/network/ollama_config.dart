import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/services/crashlytics_service.dart';
import 'package:super_fitness/config/services/remote_config_service.dart';
import 'package:super_fitness/core/utils/remote_config_keys.dart';

@lazySingleton
class OllamaConfig {
  final CrashlyticsService _crashlyticsService;
  final RemoteConfigService _remoteConfigService;

  OllamaConfig(this._crashlyticsService, this._remoteConfigService);

  static const String baseUrl = "https://api.ollama.com";
  static const String model = "gemma4:31b";

  /// Reads API Key from Firebase Remote Config.
  String get apiKey =>
      _remoteConfigService.getString(RemoteConfigKeys.ollamaApiKey);

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
        debugPrint('WARNING: OLLAMA_API_KEY is not defined in Remote Config!');
        debugPrint(
          'Please add "OLLAMA_API_KEY" to your Firebase Remote Config console.',
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
