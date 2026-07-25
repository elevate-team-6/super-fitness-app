import '../../core/utils/app_keys.dart';
import '../cache/secure_cache_helper.dart';
import '../di/di.dart';

class AuthService {
  static Future<bool> isLoggedIn() async {
    final secureCacheHelper = getIt<SecureCacheHelper>();
    final token = await secureCacheHelper.readData(key: AppKeys.tokenKey);

    return token != null && token.isNotEmpty;
  }

  static Future<bool> isOnboardingCompleted() async {
    final secureCacheHelper = getIt<SecureCacheHelper>();
    final result = await secureCacheHelper.readData(key: AppKeys.onboardingKey);
    return result == 'true';
  }

  static Future<void> setOnboardingCompleted() async {
    final secureCacheHelper = getIt<SecureCacheHelper>();
    await secureCacheHelper.writeData(
      key: AppKeys.onboardingKey,
      value: 'true',
    );
  }

  static Future<void> logout() async {
    final secureCacheHelper = getIt<SecureCacheHelper>();
    await secureCacheHelper.deleteData(key: AppKeys.tokenKey);
  }
}
