import 'package:json_annotation/json_annotation.dart';

part 'chat_event_model.g.dart';

@JsonSerializable(createToJson: false)
class ChatEventModel {
  @JsonKey(defaultValue: 'token')
  final String type;
  @JsonKey(name: 't')
  final String? content;
  final ChatActionModel? action;
  @JsonKey(name: 'exercise_refs')
  final List<String>? exerciseRefs;
  @JsonKey(name: 'meal_refs')
  final List<String>? mealRefs;
  @JsonKey(name: 'reply_chars')
  final int? replyChars;
  final bool? degraded;
  @JsonKey(name: 'safety_flag')
  final String? safetyFlag;
  final String? code;
  final String? message;
  final bool? retryable;

  ChatEventModel({
    required this.type,
    this.content,
    this.action,
    this.exerciseRefs,
    this.mealRefs,
    this.replyChars,
    this.degraded,
    this.safetyFlag,
    this.code,
    this.message,
    this.retryable,
  });

  factory ChatEventModel.fromJson(Map<String, dynamic> json) {
    // Force type to 'refs' if exercise_refs or meal_refs are present but type is missing/wrong
    String eventType = json['type'] as String? ?? 'token';
    if (json.containsKey('exercise_refs') || json.containsKey('meal_refs')) {
      eventType = 'refs';
    } else if (json.containsKey('reply_chars')) {
      eventType = 'done';
    }

    return _$ChatEventModelFromJson({...json, 'type': eventType});
  }
}

@JsonSerializable(createToJson: false)
class ChatActionModel {
  final String type;
  final String? label;
  final Map<String, dynamic>? payload;

  ChatActionModel({required this.type, this.label, this.payload});

  factory ChatActionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatActionModelFromJson(json);
}
