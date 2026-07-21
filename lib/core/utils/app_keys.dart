abstract class AppKeys {
  static const String onboardingKey = 'onboarding';
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String rememberMeKey = 'remember_me';
  static const String authorizationKey = 'Authorization';
  static const String bearerPrefix = 'Bearer';
  static const String cacheDurationHours = 'cache_duration_hours';
  static const String emailKey = 'email';
  static const String userDataKey = 'user_data';

  // Nutrition (Groq)
  /// Baked in at build time, so editing env.json needs a full rebuild — a hot
  /// restart keeps the old value. Empty when the app was built without
  /// `--dart-define-from-file`, which the data source checks for.
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  /// Macros are a pure function of the recipe, which never changes, so they are
  /// cached forever and keyed by TheMealDB's meal id.
  static const String nutritionBoxName = 'meal_nutrition';
}
