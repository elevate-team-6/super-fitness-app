import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/config/services/firestore_service.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import '../../models/chat_models.dart';
import '../contracts/chat_history_data_source_contract.dart';

@LazySingleton(as: ChatHistoryDataSourceContract)
class ChatFirestoreDataSourceImpl implements ChatHistoryDataSourceContract {
  final FirestoreService _firestoreService;
  final SecureCacheHelper _secureCacheHelper;
  String? _cachedUid;

  ChatFirestoreDataSourceImpl(this._firestoreService, this._secureCacheHelper);

  // --- Paths Logic ---
  String _userPath(String userId) => 'users/$userId/chat_sessions';

  String _sessionPath(String userId, String sessionId) =>
      '${_userPath(userId)}/$sessionId';

  Future<String> _getUserId() async {
    if (_cachedUid != null) return _cachedUid!;

    final raw = await _secureCacheHelper.readData(key: AppKeys.userDataKey);
    if (raw == null || raw.isEmpty) throw Exception('User not logged in');

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final userId = json['id'] ?? json['_id'];
    if (userId == null) throw Exception('User ID not found in cache');

    _cachedUid = userId.toString();
    return _cachedUid!;
  }

  @override
  Future<BaseResponse<void>> saveSession(ChatSessionModel session) {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      await _firestoreService.setData(
        path: _sessionPath(uid, session.id),
        data: session.toJson(),
      );
    });
  }

  @override
  Future<BaseResponse<void>> updateSessionMessages(
    String sessionId,
    List<ChatMessageModel> messages,
  ) {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      await _firestoreService.updateData(
        path: _sessionPath(uid, sessionId),
        data: {
          'messages': messages.map((e) => e.toJson()).toList(),
          'lastUpdatedAt': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<BaseResponse<void>> updateSessionTitle(
    String sessionId,
    String title,
  ) {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      await _firestoreService.updateData(
        path: _sessionPath(uid, sessionId),
        data: {
          'title': title,
          'lastUpdatedAt': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<BaseResponse<List<ChatSessionModel>>> getSessions() {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      final querySnapshot = await _firestoreService.getCollection(
        path: _userPath(uid),
        queryBuilder: (query) =>
            query.orderBy('lastUpdatedAt', descending: true),
      );

      return querySnapshot.docs
          .map((doc) => ChatSessionModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<BaseResponse<ChatSessionModel?>> getSession(String sessionId) {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      final doc = await _firestoreService.getDocument(
        path: _sessionPath(uid, sessionId),
      );
      if (!doc.exists || doc.data() == null) return null;
      return ChatSessionModel.fromJson(doc.data()!);
    });
  }

  @override
  Future<BaseResponse<void>> deleteSession(String sessionId) {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      await _firestoreService.deleteData(path: _sessionPath(uid, sessionId));
    });
  }

  @override
  Future<BaseResponse<void>> clearAll() {
    return ErrorHandler.handleApiCall(() async {
      final uid = await _getUserId();
      final sessionsResult = await getSessions();
      if (sessionsResult is SuccessBaseResponse<List<ChatSessionModel>>) {
        for (final session in sessionsResult.data!) {
          await _firestoreService.deleteData(
            path: _sessionPath(uid, session.id),
          );
        }
      }
    });
  }
}
