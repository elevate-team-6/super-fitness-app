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
import '../data_sources/contracts/chat_history_data_source_contract.dart';
import '../data_sources/contracts/chat_local_data_source_contract.dart';
import '../data_sources/contracts/chat_remote_data_source_contract.dart';
import '../mappers/user_context_mapper.dart';
import '../models/chat_event_model.dart';
import '../models/chat_models.dart';

@LazySingleton(as: ChatRepoContract)
class ChatRepoImpl implements ChatRepoContract {
  final ChatRemoteDataSourceContract _remoteDataSource;
  final CatalogLocalDataSource _localDataSource;
  final ChatLocalDataSourceContract _chatLocalDataSource;
  final ChatHistoryDataSourceContract _chatHistoryDataSource;
  final CrashlyticsService _crashlyticsService;

  ChatRepoImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._chatLocalDataSource,
    this._chatHistoryDataSource,
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
    final userMessageId = const Uuid().v4();
    final userMessage = ChatMessageEntity(
      id: userMessageId,
      text: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // Senior Optimization: Parallel IO
    final results = await Future.wait([
      getCachedUser(),
      _chatHistoryDataSource.getSession(sessionId),
    ]);

    final userResult = results[0] as BaseResponse<UserEntity?>;
    final sessionResult = results[1] as BaseResponse<ChatSessionModel?>;

    UserEntity? currentUser;
    if (userResult is SuccessBaseResponse<UserEntity?>) {
      currentUser = userResult.data;
    }

    ChatSessionModel? session;
    if (sessionResult is SuccessBaseResponse<ChatSessionModel?>) {
      session = sessionResult.data;
    }

    // 1. Prepare Session Data in Memory
    bool isNewSession = session == null;
    if (isNewSession) {
      session = ChatSessionModel(
        id: sessionId,
        title: message.length > 30 ? "${message.substring(0, 30)}..." : message,
        messages: [],
        lastUpdatedAt: DateTime.now(),
      );
    }

    final updatedMessages = List<ChatMessageModel>.from(session.messages)
      ..add(ChatMessageModel.fromEntity(userMessage));

    // 2. Background Sync
    final saveTask = isNewSession
        ? _chatHistoryDataSource.saveSession(
            ChatSessionModel(
              id: session.id,
              title: session.title,
              messages: updatedMessages,
              lastUpdatedAt: DateTime.now(),
            ),
          )
        : _chatHistoryDataSource.updateSessionMessages(
            sessionId,
            updatedMessages,
          );

    // 3. Start AI Request
    final Map<String, dynamic>? userContext = currentUser?.toUserContextJson();
    final List<Map<String, String>> history = updatedMessages
        .map(
          (m) => {
            "role": m.sender == MessageSender.user.name ? "user" : "assistant",
            "content": m.text,
          },
        )
        .toList();

    final eventStream = _remoteDataSource.getChatResponseStream(
      history: history,
      userContext: userContext,
    );

    final assistantMessageId = const Uuid().v4();
    String currentText = "";
    List<ChatRefEntity> currentRefs = [];
    bool isDegraded = false;
    String? action;

    await for (final result in eventStream) {
      // ignore: unawaited_futures
      saveTask.catchError((e) {
        debugPrint('ChatRepoImpl: Sync Error: $e');
        return ErrorBaseResponse<void>(e.toString());
      });

      switch (result) {
        case SuccessBaseResponse<ChatEventModel>():
          final event = result.data!;

          if (event.content != null) {
            if (event.type == "token") {
              currentText += event.content!;
            } else {
              currentText = event.content!;
            }
          }

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
            id: assistantMessageId,
            text: currentText,
            sender: MessageSender.assistant,
            timestamp: DateTime.now(),
            refs: currentRefs,
            isDegraded: isDegraded,
            action: action,
          );

          yield SuccessBaseResponse(assistantMessage);

          if (event.type == "done" ||
              event.type == "refs" ||
              event.type == "error") {
            final finalMessages = List<ChatMessageModel>.from(updatedMessages);
            finalMessages.add(ChatMessageModel.fromEntity(assistantMessage));
            await _chatHistoryDataSource.updateSessionMessages(
              sessionId,
              finalMessages,
            );
          }

        case ErrorBaseResponse<ChatEventModel>():
          await _crashlyticsService.recordError(
            result.errorMessage,
            StackTrace.current,
          );
          yield ErrorBaseResponse(result.errorMessage);
      }
    }
  }

  @override
  Future<BaseResponse<List<ChatMessageEntity>>> getSessionMessages(
    String sessionId,
  ) async {
    final result = await _chatHistoryDataSource.getSession(sessionId);
    switch (result) {
      case SuccessBaseResponse<ChatSessionModel?>():
        final messages =
            result.data?.messages.map((e) => e.toEntity()).toList() ?? [];
        return SuccessBaseResponse(messages);
      case ErrorBaseResponse<ChatSessionModel?>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<List<Map<String, String>>>> getChatHistory() async {
    final result = await _chatHistoryDataSource.getSessions();
    switch (result) {
      case SuccessBaseResponse<List<ChatSessionModel>>():
        final history = result.data!
            .map((e) => {'id': e.id, 'title': e.title})
            .toList();
        return SuccessBaseResponse(history);
      case ErrorBaseResponse<List<ChatSessionModel>>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<void>> deleteSession(String id) async {
    return _chatHistoryDataSource.deleteSession(id);
  }

  @override
  Future<BaseResponse<void>> createSession(String id, String title) async {
    return _chatHistoryDataSource.saveSession(
      ChatSessionModel(
        id: id,
        title: title,
        messages: [],
        lastUpdatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<BaseResponse<void>> updateSessionTitle(String id, String title) async {
    return _chatHistoryDataSource.updateSessionTitle(id, title);
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
