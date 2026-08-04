abstract class AppConstants {
  static const String appName = 'Super Fitness';
  static const String translationsPath = 'assets/translations';
  static const String arabicCode = 'ar';
  static const String englishCode = 'en';

  // Profile web views
  // Static pages hosted by the team, opened in-app rather than in a browser.
  static const String _webViewsBaseUrl =
      'https://elevate-flutter-team.github.io/fitness-app-webviews';
  static const String securityUrl = '$_webViewsBaseUrl/security.html';
  static const String privacyPolicyUrl =
      '$_webViewsBaseUrl/privacy-policy.html';
  static const String helpUrl = '$_webViewsBaseUrl/help.html';

  // api images base url
  static const String imageBaseUrl = 'https://flower.elevateegy.com/uploads/';
  static const String googleServerClientId =
      '448039353489-bkp3ljjv378kqh8mgv3he22lcjtj08bp.apps.googleusercontent.com';
}

// --- Ollama Chat Configuration ---
class ChatConstants {
  static const int maxOllamaTurns = 5;
  static const Duration ollamaFirstTurnTimeout = Duration(seconds: 30);
  static const Duration ollamaSubsequentTurnTimeout = Duration(seconds: 60);
  static const int chatHistoryWindowSize = 10;
}
