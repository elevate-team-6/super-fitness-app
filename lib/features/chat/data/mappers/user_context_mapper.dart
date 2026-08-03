import '../../../auth/domain/entities/user_entity.dart';

extension UserContextMapper on UserEntity {
  Map<String, dynamic> toUserContextJson() {
    return {
      "name": "${firstName ?? ''} ${lastName ?? ''}".trim(),
      "age": age ?? 0,
      "weight": weight ?? 0,
      "height": height ?? 0,
      "gender": gender ?? 'male',
      "activity_level": _mapActivityLevel(activityLevel),
      "goal": _mapGoal(goal),
      "level": _mapLevel(activityLevel), // Using activity level as a proxy for experience level
    };
  }

  String _mapLevel(String? level) {
    if (level == null) return 'Beginner';
    if (level == 'level4' || level == 'level5') return 'Advanced';
    if (level == 'level3') return 'Intermediate';
    return 'Beginner';
  }

  String _mapActivityLevel(String? level) {
    switch (level) {
      case 'level1':
        return 'sedentary';
      case 'level2':
        return 'lightly active';
      case 'level3':
        return 'moderately active';
      case 'level4':
        return 'very active';
      case 'level5':
        return 'extra active';
      default:
        return level ?? 'sedentary';
    }
  }

  String _mapGoal(String? goal) {
    if (goal == null || goal.isEmpty) return 'Fitness';

    // Convert camelCase to Title Case (e.g. getFitter -> Get Fitter)
    final words = goal.split(RegExp(r'(?=[A-Z])'));
    return words
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }
}
