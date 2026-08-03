import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';

@Injectable(as: ProfileLocalDataSourceContract)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSourceContract {
  final SecureCacheHelper _secureCacheHelper;

  const ProfileLocalDataSourceImpl(this._secureCacheHelper);

  @override
  Future<UserEntity?> getCachedUser() async {
    final raw = await _secureCacheHelper.readData(key: AppKeys.profileDataKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) => _secureCacheHelper.writeData(
    key: AppKeys.profileDataKey,
    value: jsonEncode(user.toJson()),
  );
}
