import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/network/ollama_config.dart';
import 'package:super_fitness/core/network/ollama_exception.dart';
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
    // 1. Validation & Safety
    _validateConfiguration();

    final List<Map<String, dynamic>> messages = await _prepareMessages(
      history,
      userContext,
      locale,
    );

    final List<String> candidateIds = [];

    // 2. Fast Path (E6)
    await _handleFastPath(history, messages, candidateIds);

    // 3. Iterative Tool Loop
    for (int turn = 0; turn < ChatConstants.maxOllamaTurns; turn++) {
      final response = await _callOllamaApi(messages, turn);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final assistantMessage = data['message'] as Map<String, dynamic>;
      final List<dynamic>? toolCalls = assistantMessage['tool_calls'];

      messages.add(assistantMessage);

      if (toolCalls == null || toolCalls.isEmpty) {
        return _processFinalResponse(assistantMessage, candidateIds);
      }

      await _processToolCalls(toolCalls, messages, candidateIds);
    }

    throw Exception(
      'Ollama failed to provide a final answer within ${ChatConstants.maxOllamaTurns} turns.',
    );
  }

  void _validateConfiguration() {
    if (!_config.isConfigured) {
      throw OllamaConfigurationException(
        'Ollama is not configured. Please check your API Key.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _prepareMessages(
    List<Map<String, String>> history,
    Map<String, dynamic> userContext,
    String locale,
  ) async {
    final vocabularyBlock = await _vocabularyBuilder.buildVocabularyBlock();
    final systemPrompt = _promptBuilder.build(
      locale: locale,
      userContext: userContext,
      vocabularyBlock: vocabularyBlock,
    );

    final slidingHistory = history.length > ChatConstants.chatHistoryWindowSize
        ? history.sublist(history.length - ChatConstants.chatHistoryWindowSize)
        : history;

    return [
      {"role": "system", "content": systemPrompt},
      ...slidingHistory,
    ];
  }

  Future<void> _handleFastPath(
    List<Map<String, String>> history,
    List<Map<String, dynamic>> messages,
    List<String> candidateIds,
  ) async {
    final String lastUserMessage = history.isNotEmpty
        ? history.last['content'] ?? ''
        : '';
    
    final fastPathFilters = _classifier.classify(lastUserMessage);
    if (fastPathFilters != null) {
      final results = await _retrievalService.searchExercisesByFilters(
        muscleGroup: fastPathFilters['muscle_group'],
        equipment: fastPathFilters['equipment'],
      );
      
      candidateIds.addAll(results.map((e) => e['id'].toString()));

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
  }

  Future<http.Response> _callOllamaApi(
    List<Map<String, dynamic>> messages,
    int turn,
  ) async {
    final response = await _client
        .post(
          Uri.parse('${OllamaConfig.baseUrl}/api/chat'),
          headers: _config.buildHeaders(),
          body: jsonEncode({
            "model": OllamaConfig.model,
            "messages": messages,
            "tools": [searchExercisesTool, searchMealsTool, searchByTextTool],
            "format": "json",
            "stream": false,
          }),
        )
        .timeout(
          turn == 0
              ? ChatConstants.ollamaFirstTurnTimeout
              : ChatConstants.ollamaSubsequentTurnTimeout,
        );

    if (response.statusCode != 200) {
      throw Exception('Ollama Request Failed: ${response.body}');
    }
    return response;
  }

  Future<void> _processToolCalls(
    List<dynamic> toolCalls,
    List<Map<String, dynamic>> messages,
    List<String> candidateIds,
  ) async {
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
        final results = await _retrievalService.searchExercisesByFilters(
          limit: 6,
        );
        candidateIds.addAll(results.map((e) => e['id'].toString()));
        toolResult = _retrievalService.serializeExerciseCards(results);
      }

      messages.add({"role": "tool", "content": toolResult});
    }
  }

  Map<String, dynamic> _processFinalResponse(
    Map<String, dynamic> assistantMessage,
    List<String> candidateIds,
  ) {
    final String rawContent = assistantMessage['content'] ?? '';
    final String cleanedContent = _cleanJsonResponse(rawContent);

    try {
      final finalJson = jsonDecode(cleanedContent) as Map<String, dynamic>;
      
      // Filter references to ensure only "candidate" (actually found) items are returned
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
    } catch (e) {
      // Logic OUTSIDE catch: Providing a safe fallback if JSON is corrupted
      return {
        "reply": cleanedContent,
        "exercise_refs": [],
        "meal_refs": [],
        "action": {"type": "none"},
        "safety_flag": "none",
      };
    }
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
