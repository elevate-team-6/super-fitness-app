import 'package:injectable/injectable.dart';

@lazySingleton
class OllamaFastPathClassifier {
  /// Simple keyword maps based on section 4.7
  static const Map<String, List<String>> muscleWords = {
    'Glutes': ['glute', 'butt', 'bum', 'الأرداف', 'المؤخرة'],
    'Biceps': ['bicep', 'arm', 'الباي', 'البايسبس', 'ذراع'],
    'Chest': ['chest', 'pec', 'صدر', 'الصدر'],
    'Abs': ['abs', 'core', 'belly', 'بطن', 'عضلات البطن'],
    'Legs': ['leg', 'quad', 'hamstring', 'رجل', 'رجلين', 'فخذ'],
  };

  static const Map<String, List<String>> equipWords = {
    'Bodyweight': [
      'no equipment',
      'bodyweight',
      'at home',
      'بدون معدات',
      'وزن الجسم',
      'في البيت',
    ],
    'Dumbbell': ['dumbbell', 'db', 'دمبل', 'دامبلز'],
  };

  /// Attempts to classify the message locally to bypass Turn A.
  /// Returns a Map of filters if successful, otherwise null.
  Map<String, dynamic>? classify(String message) {
    final lowerMessage = message.toLowerCase();

    // Safety check: skip fast path for long or complex questions
    if (message.length > 120 || _isQuestion(lowerMessage)) {
      return null;
    }

    String? foundMuscle;
    String? foundEquip;

    for (var entry in muscleWords.entries) {
      if (entry.value.any((w) => lowerMessage.contains(w))) {
        foundMuscle = entry.key;
        break;
      }
    }

    for (var entry in equipWords.entries) {
      if (entry.value.any((w) => lowerMessage.contains(w))) {
        foundEquip = entry.key;
        break;
      }
    }

    // Only trigger fast path if we found at least a muscle group
    if (foundMuscle != null) {
      return {'muscle_group': foundMuscle, 'equipment': foundEquip};
    }

    return null;
  }

  bool _isQuestion(String msg) {
    const questionMarkers = [
      'how',
      'why',
      'what',
      'can i',
      'should i',
      'إزاي',
      'ليه',
      'ممكن',
      'هل',
    ];
    return questionMarkers.any((m) => msg.contains(m));
  }
}
