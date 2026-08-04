import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/services/crashlytics_service.dart';
import 'package:super_fitness/core/network/ollama_exception.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import '../contracts/chat_remote_data_source_contract.dart';
import 'ollama/chat_degraded_mode_service.dart';
import '../../models/chat_event_model.dart';
import 'ollama/ollama_chat_client.dart';

@LazySingleton(as: ChatRemoteDataSourceContract)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSourceContract {
  final OllamaChatClient _ollamaRepo;
  final ChatDegradedModeService _degradedService;
  final CrashlyticsService _crashlyticsService;

  ChatRemoteDataSourceImpl(
    this._ollamaRepo,
    this._degradedService,
    this._crashlyticsService,
  );

  @override
  Stream<BaseResponse<ChatEventModel>> getChatResponseStream({
    required List<Map<String, String>> history,
    Map<String, dynamic>? userContext,
  }) async* {
    final lastMessage = history.isNotEmpty ? history.last['content'] ?? '' : '';
    if (kDebugMode) {
      debugPrint(
        'ChatRemoteDataSourceImpl: Starting response stream for message: $lastMessage',
      );
    }
    try {
      final response = await _ollamaRepo
          .getOllamaResponse(
            history: history,
            userContext: userContext ?? {},
            locale: Intl.getCurrentLocale(),
          )
          .timeout(const Duration(minutes: 2));

      if (kDebugMode) {
        debugPrint(
          'ChatRemoteDataSourceImpl: Received response from Ollama client',
        );
      }

      final String reply = response['reply'] ?? '';
      final List<String> exerciseRefs = List<String>.from(
        response['exercise_refs'] ?? [],
      );
      final List<String> mealRefs = List<String>.from(
        response['meal_refs'] ?? [],
      );
      final String? safetyFlag = response['safety_flag'];
      final Map<String, dynamic>? action = response['action'];

      if (kDebugMode) {
        debugPrint(
          'ChatRemoteDataSourceImpl: Yielding success response with ${reply.length} chars',
        );
      }

      yield SuccessBaseResponse(
        ChatEventModel(
          type: 'done',
          content: reply,
          exerciseRefs: exerciseRefs,
          mealRefs: mealRefs,
          action: action != null ? ChatActionModel.fromJson(action) : null,
          degraded: false,
          safetyFlag: safetyFlag,
          replyChars: reply.length,
        ),
      );
    } on OllamaConfigurationException {
      // Senior UI/UX: Specifically handle configuration errors without entering degraded mode
      yield ErrorBaseResponse(AppStrings.chatSessionError.tr());
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('ChatRemoteDataSourceImpl: Error caught in stream: $e');
      }
      await _crashlyticsService.recordError(
        e,
        stack,
        reason: "Ollama Integration Failure",
      );

      // E6: Invoke Degraded Mode on any failure
      try {
        if (kDebugMode) {
          debugPrint('ChatRemoteDataSourceImpl: Entering Degraded Mode...');
        }
        final lastUserMessage = history.isNotEmpty
            ? history.last['content'] ?? ''
            : '';
        final degradedResponse = await _degradedService.getDegradedResponse(
          lastUserMessage,
          Intl.getCurrentLocale(),
        );
        if (kDebugMode) {
          debugPrint('ChatRemoteDataSourceImpl: Yielding degraded response');
        }
        yield SuccessBaseResponse(degradedResponse);
      } catch (degradedError) {
        if (kDebugMode) {
          debugPrint(
            'ChatRemoteDataSourceImpl: Critical Failure - Degraded Mode failed: $degradedError',
          );
        }
        yield ErrorBaseResponse(e.toString());
      }
    }
  }
}
