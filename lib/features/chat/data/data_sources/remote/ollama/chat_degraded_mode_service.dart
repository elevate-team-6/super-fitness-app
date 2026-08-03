import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import '../../../models/chat_event_model.dart';
import 'ollama_fast_path_classifier.dart';
import '../../../retrieval/catalog_retrieval_service.dart';

@lazySingleton
class ChatDegradedModeService {
  final OllamaFastPathClassifier _classifier;
  final CatalogRetrievalService _retrievalService;

  ChatDegradedModeService(this._classifier, this._retrievalService);

  /// Returns a helpful response when the LLM is unavailable.
  Future<ChatEventModel> getDegradedResponse(
    String message,
    String locale,
  ) async {
    List<Map<String, dynamic>> results = [];

    try {
      final filters = _classifier.classify(message);

      if (filters != null) {
        results = await _retrievalService.searchExercisesByFilters(
          muscleGroup: filters['muscle_group'],
          equipment: filters['equipment'],
        );
      }

      // Fallback if no specific filters matched or no results
      if (results.isEmpty) {
        results = await _retrievalService.searchExercisesByFilters(limit: 4);
      }
    } catch (_) {
      // Keep results empty if DB fails
    }

    return ChatEventModel(
      type: 'done',
      content: AppStrings.chatDegradedMessage.tr(),
      exerciseRefs: results.map((e) => e['id'].toString()).toList(),
      degraded: true,
      safetyFlag: 'none',
    );
  }
}
