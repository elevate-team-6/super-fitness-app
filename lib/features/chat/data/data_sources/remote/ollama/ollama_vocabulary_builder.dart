import 'package:injectable/injectable.dart';
import 'package:super_fitness/core/data/local/sqlite/catalog_local_data_source.dart';

@lazySingleton
class OllamaVocabularyBuilder {
  final CatalogLocalDataSource _catalogDataSource;

  String? _cachedVocabulary;
  String? _lastDbVersion;

  OllamaVocabularyBuilder(this._catalogDataSource);

  /// Builds the vocabulary block for the AI system prompt.
  /// Caches the result unless the database version changes.
  Future<String> buildVocabularyBlock() async {
    final currentDbVersion = await _catalogDataSource.getDatabaseVersion();

    if (_cachedVocabulary != null && _lastDbVersion == currentDbVersion) {
      return _cachedVocabulary!;
    }

    final muscleGroups = await _catalogDataSource.getDistinctMuscleGroups();
    final equipment = await _catalogDataSource.getDistinctEquipment();
    final movementPatterns = await _catalogDataSource
        .getDistinctMovementPatterns();
    final difficultyLevels = await _catalogDataSource.getDifficultyLevelsMap();

    final buffer = StringBuffer();
    buffer.writeln(
      'CATALOG VOCABULARY — use these exact values in tool arguments:',
    );

    buffer.writeln('muscle_group: ${muscleGroups.join(' | ')}');
    buffer.writeln('equipment: ${equipment.join(' | ')}');
    buffer.writeln('movement_pattern: ${movementPatterns.join(' | ')}');

    final difficultyStr = difficultyLevels.entries
        .map((e) => '${e.key}=${e.value}')
        .join(' | ');
    buffer.writeln('max_difficulty (integer): $difficultyStr');

    buffer.writeln(
      'body_region: Upper Body | Lower Body | Midsection | Full Body',
    );
    buffer.writeln('mechanics: Compound | Isolation');

    _cachedVocabulary = buffer.toString();
    _lastDbVersion = currentDbVersion;

    return _cachedVocabulary!;
  }
}
