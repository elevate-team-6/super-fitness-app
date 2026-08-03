import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/services/crashlytics_service.dart';
import '../../../../core/data/local/sqlite/catalog_local_data_source.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/youtube_url.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../workouts/domain/entities/exercise_entity.dart' as workout;
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_ref_entity.dart';
import '../../domain/repo/chat_repo_contract.dart';
import '../data_sources/contracts/chat_local_data_source_contract.dart';
import '../data_sources/contracts/chat_remote_data_source_contract.dart';
import '../mappers/user_context_mapper.dart';
import '../models/chat_event_model.dart';
import '../models/hive/chat_hive_models.dart';

@LazySingleton(as: ChatRepoContract)
class ChatRepoImpl implements ChatRepoContract {
  final ChatRemoteDataSourceContract _remoteDataSource;
  final CatalogLocalDataSource _localDataSource;
  final ChatLocalDataSourceContract _chatLocalDataSource;
  final CrashlyticsService _crashlyticsService;

  ChatRepoImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._chatLocalDataSource,
    this._crashlyticsService,
  );

  @override
  Future<BaseResponse<UserEntity?>> getCachedUser() {
    return _chatLocalDataSource.getCachedUser();
  }

  @override
  Stream<BaseResponse<ChatMessageEntity>> sendMessage({
    required String sessionId,
    required String message,
  }) async* {
    // 1. Save User Message Locally
    final userMessage = ChatMessageEntity(
      id: const Uuid().v4(),
      text: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final sessionResult = await _chatLocalDataSource.getSession(sessionId);
    ChatSessionHiveModel? session;

    if (sessionResult is SuccessBaseResponse<ChatSessionHiveModel?>) {
      session = sessionResult.data;
    }

    // Defensive: If session doesn't exist yet, create it to avoid losing messages
    if (session == null) {
      final newSession = ChatSessionHiveModel(
        id: sessionId,
        title: message.length > 30 ? "${message.substring(0, 30)}..." : message,
        messages: [],
        lastUpdatedAt: DateTime.now(),
      );
      await _chatLocalDataSource.saveSession(newSession);
      session = newSession;
    }

    final updatedMessages = List<ChatMessageHiveModel>.from(session.messages)
      ..add(ChatMessageHiveModel.fromEntity(userMessage));
    await _chatLocalDataSource.updateSessionMessages(
      sessionId,
      updatedMessages,
    );

    final messageId = const Uuid().v4();
    String currentText = "";
    List<ChatRefEntity> currentRefs = [];
    bool isDegraded = false;
    String? action;

    // Senior Optimization: Parallel IO
    final results = await Future.wait([
      getCachedUser(),
      _chatLocalDataSource.getSession(sessionId),
    ]);

    final userResult = results[0] as BaseResponse<UserEntity?>;
    final sessionQueryResult = results[1] as BaseResponse<ChatSessionHiveModel?>;

    final Map<String, dynamic>? userContext =
        (userResult is SuccessBaseResponse<UserEntity?>)
            ? userResult.data?.toUserContextJson()
            : null;
            
    if (kDebugMode) {
      debugPrint('ChatRepoImpl: User Context for Ollama: $userContext');
    }

    // Build History Map for Ollama
    List<Map<String, String>> history = [];
    if (sessionQueryResult is SuccessBaseResponse<ChatSessionHiveModel?>) {
      final sessionData = sessionQueryResult.data;
      if (sessionData != null) {
        history = sessionData.messages.map((m) => {
          "role": m.sender == MessageSender.user.name ? "user" : "assistant",
          "content": m.text,
        }).toList();
      }
    }

    final eventStream = _remoteDataSource.getChatResponseStream(
      history: history,
      userContext: userContext,
    );

    await for (final result in eventStream) {
      switch (result) {
        case SuccessBaseResponse<ChatEventModel>():
          final event = result.data!;
          if (kDebugMode) {
            debugPrint('ChatRepoImpl: Received SuccessBaseResponse with event type: ${event.type}');
          }
          
          // Handle text content: append if token-based, replace if consolidated
          if (event.content != null) {
            if (event.type == "token") {
              currentText += event.content!;
            } else {
              currentText = event.content!;
            }
            if (kDebugMode) {
              debugPrint('ChatRepoImpl: Updated currentText (length: ${currentText.length})');
            }
          }

          // Handle references: triggered on 'refs' or consolidated 'done'
          if (event.type == "refs" || event.type == "done") {
            action =
                event.action?.label ??
                (event.action?.type != "none" ? event.action?.type : null);

            if (event.exerciseRefs != null || event.mealRefs != null) {
              currentRefs = await _hydrateRefs(event);
            }
          }

          if (event.type == "done") {
            isDegraded = event.degraded ?? false;
          } else if (event.type == "error") {
            yield ErrorBaseResponse(
              event.message ?? AppStrings.serverError.tr(),
            );
            continue;
          }

          final assistantMessage = ChatMessageEntity(
            id: messageId,
            text: currentText,
            sender: MessageSender.assistant,
            timestamp: DateTime.now(),
            refs: currentRefs,
            isDegraded: isDegraded,
            action: action,
          );

          yield SuccessBaseResponse(assistantMessage);

          // Senior-Level Optimization: Only update local storage on critical events or end of stream
          // to avoid overwhelming Hive during fast token streaming.
          if (event.type == "done" ||
              event.type == "refs" ||
              event.type == "error") {
            final currentSessionResult = await _chatLocalDataSource.getSession(
              sessionId,
            );
            if (currentSessionResult
                is SuccessBaseResponse<ChatSessionHiveModel?>) {
              final currentSession = currentSessionResult.data;
              if (currentSession != null) {
                final messages = List<ChatMessageHiveModel>.from(
                  currentSession.messages,
                );
                final existingIndex = messages.indexWhere(
                  (m) => m.id == messageId,
                );
                if (existingIndex != -1) {
                  messages[existingIndex] = ChatMessageHiveModel.fromEntity(
                    assistantMessage,
                  );
                } else {
                  messages.add(
                    ChatMessageHiveModel.fromEntity(assistantMessage),
                  );
                }
                await _chatLocalDataSource.updateSessionMessages(
                  sessionId,
                  messages,
                );
              }
            }
          }

        case ErrorBaseResponse<ChatEventModel>():
          await _crashlyticsService.recordError(
            result.errorMessage,
            StackTrace.current,
            reason: "Chat Remote Error",
            information: ["SessionID: $sessionId"],
          );
          yield ErrorBaseResponse(result.errorMessage);
      }
    }
  }

  @override
  Future<BaseResponse<List<ChatMessageEntity>>> getSessionMessages(
    String sessionId,
  ) async {
    final result = await _chatLocalDataSource.getSession(sessionId);
    switch (result) {
      case SuccessBaseResponse<ChatSessionHiveModel?>():
        final messages =
            result.data?.messages.map((e) => e.toEntity()).toList() ?? [];
        return SuccessBaseResponse(messages);
      case ErrorBaseResponse<ChatSessionHiveModel?>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<Map<String, String>>>> getChatHistory() async {
    final result = await _chatLocalDataSource.getSessions();
    switch (result) {
      case SuccessBaseResponse<List<ChatSessionHiveModel>>():
        final history = result.data!
            .map((e) => {'id': e.id, 'title': e.title})
            .toList();
        return SuccessBaseResponse(history);
      case ErrorBaseResponse<List<ChatSessionHiveModel>>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<void>> deleteSession(String id) async {
    return _chatLocalDataSource.deleteSession(id);
  }

  @override
  Future<BaseResponse<void>> createSession(String id, String title) async {
    return _chatLocalDataSource.saveSession(
      ChatSessionHiveModel(
        id: id,
        title: title,
        messages: [],
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<BaseResponse<void>> updateSessionTitle(String id, String title) async {
    return _chatLocalDataSource.updateSessionTitle(id, title);
  }

  Future<List<ChatRefEntity>> _hydrateRefs(ChatEventModel event) async {
    final List<ChatRefEntity> hydratedRefs = [];

    // 1. Process Exercises
    if (event.exerciseRefs != null && event.exerciseRefs!.isNotEmpty) {
      final localExercises = await _localDataSource.getExercisesByIds(
        event.exerciseRefs!,
      );

      for (final id in event.exerciseRefs!) {
        final localMatch = localExercises
            .where((e) => e.id.toString() == id)
            .firstOrNull;
        if (localMatch != null) {
          final videoUrl =
              localMatch.shortYoutubeDemonstrationLink ??
              localMatch.inDepthYoutubeExplanationLink;
          hydratedRefs.add(
            ChatRefEntity(
              id: localMatch.id.toString(),
              name: localMatch.exercise ?? "",
              image: YoutubeUrl.thumbnailUrlOf(videoUrl),
              videoUrl: videoUrl,
              muscleGroup: localMatch.targetMuscleGroup,
              difficulty: localMatch.difficultyLevel,
              type: ChatRefType.exercise,
              isSnapshot: false,
              exerciseInfo: workout.ExerciseEntity(
                id: localMatch.id ?? '',
                exercise: localMatch.exercise ?? '',
                difficultyLevel: localMatch.difficultyLevel ?? '',
                targetMuscleGroup: localMatch.targetMuscleGroup ?? '',
                primeMoverMuscle: localMatch.primeMoverMuscle ?? '',
                primaryEquipment: localMatch.primaryEquipment ?? '',
                secondaryEquipment: localMatch.secondaryEquipment ?? '',
                posture: localMatch.posture ?? '',
                grip: localMatch.grip ?? '',
                forceType: localMatch.forceType ?? '',
                secondaryMuscles: localMatch.secondaryMuscles ?? '',
                tertiaryMuscles: localMatch.tertiaryMuscles ?? '',
                bodyRegion: localMatch.bodyRegion ?? '',
                mechanics: localMatch.mechanics ?? '',
                laterality: localMatch.laterality ?? '',
                primaryExerciseClassification:
                    localMatch.primaryExerciseClassification ?? '',
                shortYoutubeDemonstrationLink:
                    localMatch.shortYoutubeDemonstrationLink ?? '',
                inDepthYoutubeExplanationLink:
                    localMatch.inDepthYoutubeExplanationLink ?? '',
              ),
            ),
          );
        }
      }
    }

    // 2. Process Meals
    if (event.mealRefs != null && event.mealRefs!.isNotEmpty) {
      final localMeals = await _localDataSource.getMealsByIds(event.mealRefs!);

      for (final id in event.mealRefs!) {
        final localMatch = localMeals.where((m) => m.idMeal == id).firstOrNull;
        if (localMatch != null) {
          hydratedRefs.add(
            ChatRefEntity(
              id: localMatch.idMeal ?? "",
              name: localMatch.strMeal ?? "",
              image: localMatch.strMealThumb,
              type: ChatRefType.meal,
              isSnapshot: false,
            ),
          );
        }
      }
    }

    return hydratedRefs;
  }
}
