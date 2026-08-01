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

  /// Deliberately separate from [userDataKey], which sign-in fills in. The
  /// profile tab has to see an empty cache on its first visit so it fetches
  /// `/auth/profile-data` once instead of settling for the sign-in copy.
  static const String profileDataKey = 'profile_data';
  static String userNameKey = 'userName';
  static String userImageKey = 'userImage';
}
