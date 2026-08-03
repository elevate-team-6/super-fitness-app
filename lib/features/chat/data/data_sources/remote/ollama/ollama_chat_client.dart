import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/network/ollama_config.dart';
import 'ollama_fast_path_classifier.dart';
import '../../../retrieval/catalog_retrieval_service.dart';
import 'ollama_system_prompt_builder.dart';
import 'ollama_tool_definitions.dart';
import 'ollama_vocabulary_builder.dart';

@lazySingleton
class OllamaChatClient {
  final OllamaConfig _config;
  final CatalogRetrievalService _retrievalService;
  final OllamaSystemPromptBuilder _promptBuilder;
  final OllamaVocabularyBuilder _vocabularyBuilder;
  final OllamaFastPathClassifier _classifier;
  final http.Client _client = http.Client();

  OllamaChatClient(
    this._config,
    this._retrievalService,
    this._promptBuilder,
    this._vocabularyBuilder,
    this._classifier,
  );

  Future<Map<String, dynamic>> getOllamaResponse({
    required List<Map<String, String>> history,
    required Map<String, dynamic> userContext,
    required String locale,
  }) async {
    final vocabularyBlock = await _vocabularyBuilder.buildVocabularyBlock();
    final systemPrompt = _promptBuilder.build(
      locale: locale,
      userContext: userContext,
      vocabularyBlock: vocabularyBlock,
    );

    // Senior Optimization: Sliding Window (last 10 messages to keep context focused)
    final slidingHistory = history.length > ChatConstants.chatHistoryWindowSize
        ? history.sublist(history.length - ChatConstants.chatHistoryWindowSize)
        : history;

    final List<Map<String, dynamic>> messages = [
      {"role": "system", "content": systemPrompt},
      ...slidingHistory,
    ];

    if (kDebugMode) {
      debugPrint(
        'OllamaChatClient: Full Messages being sent: ${jsonEncode(messages)}',
      );
    }

    final String lastUserMessage = history.isNotEmpty
        ? history.last['content'] ?? ''
        : '';
    final List<String> candidateIds = [];
    final List<String> candidateBlocks = [];

    // --- Phase 1: Fast Path Classification (E6) ---
    final fastPathFilters = _classifier.classify(lastUserMessage);
    if (fastPathFilters != null) {
      if (kDebugMode) {
        debugPrint('OllamaChatClient: Fast Path Triggered: $fastPathFilters');
      }
      final results = await _retrievalService.searchExercisesByFilters(
        muscleGroup: fastPathFilters['muscle_group'],
        equipment: fastPathFilters['equipment'],
      );
      candidateIds.addAll(results.map((e) => e['id'].toString()));
      candidateBlocks.add(_retrievalService.serializeExerciseCards(results));

      messages.add({
        "role": "assistant",
        "tool_calls": [
          {
            "function": {
              "name": "search_exercises",
              "arguments": fastPathFilters,
            },
          },
        ],
      });
      messages.add({
        "role": "tool",
        "content": _retrievalService.serializeExerciseCards(results),
      });
    }

    // --- Phase 2: Iterative Tool Processing (Support Multi-turn) ---
    for (int turn = 0; turn < ChatConstants.maxOllamaTurns; turn++) {
      if (kDebugMode) {
        debugPrint('OllamaChatClient: Starting Turn ${turn + 1}...');
      }

      final response = await _client
          .post(
            Uri.parse('${OllamaConfig.baseUrl}/api/chat'),
            headers: _config.buildHeaders(),
            body: jsonEncode({
              "model": OllamaConfig.model,
              "messages": messages,
              "tools": [searchExercisesTool, searchMealsTool, searchByTextTool],
              "format": "json",
              // Only force JSON on later turns if we suspect it's ready
              "stream": false,
              "think": false,
            }),
          )
          .timeout(turn == 0
              ? ChatConstants.ollamaFirstTurnTimeout
              : ChatConstants.ollamaSubsequentTurnTimeout);

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
            'OllamaChatClient: Turn failed with status ${response.statusCode}: ${response.body}',
          );
        }
        throw Exception('Ollama Request Failed: ${response.body}');
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final assistantMessage = data['message'] as Map<String, dynamic>;
      final List<dynamic>? toolCalls = assistantMessage['tool_calls'];

      messages.add(assistantMessage);

      if (toolCalls == null || toolCalls.isEmpty) {
        // No more tools, this is the final answer
        if (kDebugMode) {
          debugPrint(
            'OllamaChatClient: No more tool calls. Processing final answer.',
          );
        }
        final String rawContent = assistantMessage['content'] ?? '';
        final String cleanedContent = _cleanJsonResponse(rawContent);

        Map<String, dynamic> finalJson;
        try {
          finalJson = jsonDecode(cleanedContent) as Map<String, dynamic>;
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              'OllamaChatClient: Failed to parse final JSON, returning raw as reply. Error: $e',
            );
          }
          finalJson = {
            "reply": cleanedContent,
            "exercise_refs": [],
            "meal_refs": [],
            "action": {"type": "none"},
            "safety_flag": "none",
          };
        }

        final List<String> exerciseRefs =
            (finalJson['exercise_refs'] as List? ?? [])
                .map((e) => e.toString())
                .where((id) => candidateIds.contains(id))
                .toList();

        final List<String> mealRefs = (finalJson['meal_refs'] as List? ?? [])
            .map((e) => e.toString())
            .where((id) => candidateIds.contains(id))
            .toList();

        return {
          ...finalJson,
          'exercise_refs': exerciseRefs,
          'meal_refs': mealRefs,
        };
      }

      // Execute Tool Calls
      if (kDebugMode) {
        debugPrint(
          'OllamaChatClient: Executing ${toolCalls.length} tool calls...',
        );
      }
      for (final dynamic call in toolCalls) {
        final Map<String, dynamic> callMap = call as Map<String, dynamic>;
        final Map<String, dynamic> func =
            callMap['function'] as Map<String, dynamic>;
        final args = func['arguments'] as Map<String, dynamic>;
        String toolResult = "NO_MATCHES_FOUND";

        if (func['name'] == 'search_exercises') {
          final results = await _retrievalService.searchExercisesByFilters(
            muscleGroup: args['muscle_group'] as String?,
            equipment: args['equipment'] as String?,
            maxDifficulty: args['max_difficulty'] as int?,
            movementPattern: args['movement_pattern'] as String?,
            bodyRegion: args['body_region'] as String?,
            mechanics: args['mechanics'] as String?,
            excludeEquipment: args['exclude_equipment'] as String?,
            limit: (args['limit'] as int?) ?? 6,
          );
          candidateIds.addAll(results.map((e) => e['id'].toString()));
          toolResult = _retrievalService.serializeExerciseCards(results);
        } else if (func['name'] == 'search_meals') {
          final results = await _retrievalService.searchMealsByFilters(
            category: args['category'] as String?,
            area: args['area'] as String?,
            minProtein: (args['min_protein'] as num?)?.toDouble(),
            maxKcal: (args['max_kcal'] as num?)?.toDouble(),
            vegetarian: args['vegetarian'] as bool?,
            vegan: args['vegan'] as bool?,
            glutenFree: args['gluten_free'] as bool?,
            excludeIngredient: args['exclude_ingredient'] as String?,
            limit: (args['limit'] as int?) ?? 6,
          );
          candidateIds.addAll(results.map((e) => e['id'].toString()));
          toolResult = _retrievalService.serializeMealCards(results);
        } else if (func['name'] == 'search_by_text') {
          // Fallback to searching all exercises if text search is used
          final results = await _retrievalService.searchExercisesByFilters(
            limit: 6,
          );
          candidateIds.addAll(results.map((e) => e['id'].toString()));
          toolResult = _retrievalService.serializeExerciseCards(results);
        }

        messages.add({"role": "tool", "content": toolResult});
      }

      // If we are at the last turn and still have tool calls, we must force a reply
      if (turn == ChatConstants.maxOllamaTurns - 1) {
        if (kDebugMode) {
          debugPrint('OllamaChatClient: Max turns reached. Forcing Turn B.');
        }
      }
    }

    throw Exception(
      'Ollama failed to provide a final answer within ${ChatConstants.maxOllamaTurns} turns.',
    );
  }

  String _cleanJsonResponse(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith("```")) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```json\s*|^```\s*'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'```\s*$'), '');
    }
    return cleaned.trim();
  }
}
