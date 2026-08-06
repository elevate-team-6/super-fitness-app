import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import '../contracts/chat_local_data_source_contract.dart';

@LazySingleton(as: ChatLocalDataSourceContract)
class ChatLocalDataSourceImpl implements ChatLocalDataSourceContract {
  final SecureCacheHelper _secureCacheHelper;

  ChatLocalDataSourceImpl(this._secureCacheHelper);

  @override
  Future<BaseResponse<UserEntity?>> getCachedUser() {
    return ErrorHandler.handleApiCall(() async {
      final raw = await _secureCacheHelper.readData(key: AppKeys.userDataKey);
      if (raw == null || raw.isEmpty) return null;

      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    });
  }
}
