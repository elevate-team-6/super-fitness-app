import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import '../../models/hive/chat_hive_models.dart';
import '../../services/chat_firestore_service.dart';
import '../contracts/chat_local_data_source_contract.dart';

@LazySingleton(as: ChatLocalDataSourceContract)
class ChatFirestoreDataSourceImpl implements ChatLocalDataSourceContract {
  final ChatFirestoreService _firestoreService;
  final SecureCacheHelper _secureCacheHelper;

  ChatFirestoreDataSourceImpl(this._firestoreService, this._secureCacheHelper);

  @override
  Future<BaseResponse<UserEntity?>> getCachedUser() {
    return ErrorHandler.handleApiCall(() async {
      final raw = await _secureCacheHelper.readData(key: AppKeys.userDataKey);
      if (raw == null || raw.isEmpty) return null;

      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json).toEntity();
    });
  }

  @override
  Future<BaseResponse<void>> saveSession(ChatSessionHiveModel session) {
    return ErrorHandler.handleApiCall(() async {
      await _firestoreService.saveSession(session);
    });
  }

  @override
  Future<BaseResponse<void>> updateSessionMessages(
    String sessionId,
    List<ChatMessageHiveModel> messages,
  ) {
    return ErrorHandler.handleApiCall(() async {
      await _firestoreService.updateSessionMessages(sessionId, messages);
    });
  }

  @override
  Future<BaseResponse<void>> updateSessionTitle(
    String sessionId,
    String title,
  ) {
    return ErrorHandler.handleApiCall(() async {
      await _firestoreService.updateSessionTitle(sessionId, title);
    });
  }

  @override
  Future<BaseResponse<List<ChatSessionHiveModel>>> getSessions() {
    return ErrorHandler.handleApiCall(() async {
      return await _firestoreService.getSessions();
    });
  }

  @override
  Future<BaseResponse<ChatSessionHiveModel?>> getSession(String sessionId) {
    return ErrorHandler.handleApiCall(() async {
      return await _firestoreService.getSession(sessionId);
    });
  }

  @override
  Future<BaseResponse<void>> deleteSession(String sessionId) {
    return ErrorHandler.handleApiCall(() async {
      await _firestoreService.deleteSession(sessionId);
    });
  }

  @override
  Future<BaseResponse<void>> clearAll() {
    // This might need careful thought. For Firestore, we might not want to clear everything
    // or we might want to delete all user sessions.
    return ErrorHandler.handleApiCall(() async {
      final sessions = await _firestoreService.getSessions();
      for (final session in sessions) {
        await _firestoreService.deleteSession(session.id);
      }
    });
  }
}
