import 'dart:convert';

import '../../core/utils/app_keys.dart';
import '../../features/auth/data/models/response/user_model.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../cache/secure_cache_helper.dart';
import '../di/di.dart';

class AuthService {
  static Future<bool> isLoggedIn() async {
    final secureCacheHelper = getIt<SecureCacheHelper>();
    final token = await secureCacheHelper.readData(key: AppKeys.tokenKey);

    return token != null && token.isNotEmpty;
  }

  /// The user stored at sign-in / sign-up, or null when nothing was cached —
  /// which is also the case for sessions that started before caching existed,
  /// so callers must handle null rather than assume a logged-in user has one.
  static Future<UserEntity?> getCachedUser() async {
    final secureCacheHelper = getIt<SecureCacheHelper>();
    final raw = await secureCacheHelper.readData(key: AppKeys.userDataKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    } catch (_) {
      // A payload written by an older build may no longer parse; treat it as
      // absent instead of taking the screen down with it.
      return null;
    }
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
    await secureCacheHelper.deleteData(key: AppKeys.userDataKey);
  }
}
