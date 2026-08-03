import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import '../contracts/chat_local_data_source_contract.dart';
import '../../models/hive/chat_hive_models.dart';

/// Implementation of [ChatLocalDataSourceContract] using the [Hive] database.
@LazySingleton(as: ChatLocalDataSourceContract)
class ChatLocalDataSourceImpl implements ChatLocalDataSourceContract {
  static const String _boxName = 'chat_sessions_box';
  final SecureCacheHelper _secureCacheHelper;
  Box<Map>? _box;

  ChatLocalDataSourceImpl(this._secureCacheHelper);

  @visibleForTesting
  Box<Map>? testBox;

  /// Internal helper to access the Hive box for chat sessions.
  Future<Box<Map>> _getBox() async {
    if (testBox != null) return testBox!;
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Map>(_boxName);
    return _box!;
  }

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
      final box = await _getBox();
      await box.put(session.id, session.toJson());
    });
  }

  @override
  Future<BaseResponse<void>> updateSessionMessages(
    String sessionId,
    List<ChatMessageHiveModel> messages,
  ) {
    return ErrorHandler.handleApiCall(() async {
      final box = await _getBox();
      final sessionData = box.get(sessionId);
      if (sessionData != null) {
        final session = ChatSessionHiveModel.fromJson(sessionData);
        final updatedSession = ChatSessionHiveModel(
          id: session.id,
          title: session.title,
          messages: messages,
          lastUpdatedAt: DateTime.now(),
        );
        await box.put(sessionId, updatedSession.toJson());
      }
    });
  }

  @override
  Future<BaseResponse<void>> updateSessionTitle(
    String sessionId,
    String title,
  ) {
    return ErrorHandler.handleApiCall(() async {
      final box = await _getBox();
      final sessionData = box.get(sessionId);
      if (sessionData != null) {
        final session = ChatSessionHiveModel.fromJson(sessionData);
        final updatedSession = ChatSessionHiveModel(
          id: session.id,
          title: title,
          messages: session.messages,
          lastUpdatedAt: DateTime.now(),
        );
        await box.put(sessionId, updatedSession.toJson());
      }
    });
  }

  @override
  Future<BaseResponse<List<ChatSessionHiveModel>>> getSessions() {
    return ErrorHandler.handleApiCall(() async {
      final box = await _getBox();
      final sessions = box.values
          .map((e) => ChatSessionHiveModel.fromJson(e))
          .toList();

      sessions.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
      return sessions;
    });
  }

  @override
  Future<BaseResponse<ChatSessionHiveModel?>> getSession(String sessionId) {
    return ErrorHandler.handleApiCall(() async {
      final box = await _getBox();
      final data = box.get(sessionId);
      if (data == null) return null;
      return ChatSessionHiveModel.fromJson(data);
    });
  }

  @override
  Future<BaseResponse<void>> deleteSession(String sessionId) {
    return ErrorHandler.handleApiCall(() async {
      final box = await _getBox();
      await box.delete(sessionId);
    });
  }

  @override
  Future<BaseResponse<void>> clearAll() {
    return ErrorHandler.handleApiCall(() async {
      final box = await _getBox();
      await box.clear();
    });
  }
}
