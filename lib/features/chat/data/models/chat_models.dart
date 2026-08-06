import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_ref_entity.dart';

class ChatRefModel {
  final String id;
  final String name;
  final String? image;
  final String? videoUrl;
  final String? muscleGroup;
  final String? difficulty;
  final String type;
  final bool isSnapshot;

  ChatRefModel({
    required this.id,
    required this.name,
    this.image,
    this.videoUrl,
    this.muscleGroup,
    this.difficulty,
    required this.type,
    this.isSnapshot = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'videoUrl': videoUrl,
    'muscleGroup': muscleGroup,
    'difficulty': difficulty,
    'type': type,
    'isSnapshot': isSnapshot,
  };

  factory ChatRefModel.fromJson(Map<dynamic, dynamic> json) => ChatRefModel(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    videoUrl: json['videoUrl'],
    muscleGroup: json['muscleGroup'],
    difficulty: json['difficulty'],
    type: json['type'],
    isSnapshot: json['isSnapshot'] ?? false,
  );

  factory ChatRefModel.fromEntity(ChatRefEntity entity) => ChatRefModel(
    id: entity.id,
    name: entity.name,
    image: entity.image,
    videoUrl: entity.videoUrl,
    muscleGroup: entity.muscleGroup,
    difficulty: entity.difficulty,
    type: entity.type.name,
    isSnapshot: entity.isSnapshot,
  );

  ChatRefEntity toEntity() => ChatRefEntity(
    id: id,
    name: name,
    image: image,
    videoUrl: videoUrl,
    muscleGroup: muscleGroup,
    difficulty: difficulty,
    type: ChatRefType.values.byName(type),
    isSnapshot: isSnapshot,
  );
}

class ChatMessageModel {
  final String id;
  final String text;
  final String sender;
  final List<ChatRefModel> refs;
  final bool isDegraded;
  final DateTime timestamp;
  final String? action;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.refs,
    required this.isDegraded,
    required this.timestamp,
    this.action,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'sender': sender,
    'refs': refs.map((e) => e.toJson()).toList(),
    'isDegraded': isDegraded,
    'timestamp': timestamp.toIso8601String(),
    'action': action,
  };

  factory ChatMessageModel.fromJson(Map<dynamic, dynamic> json) =>
      ChatMessageModel(
        id: json['id'],
        text: json['text'],
        sender: json['sender'],
        refs: (json['refs'] as List)
            .map((e) => ChatRefModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        isDegraded: json['isDegraded'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
        action: json['action'],
      );

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) =>
      ChatMessageModel(
        id: entity.id,
        text: entity.text,
        sender: entity.sender.name,
        refs: entity.refs.map((e) => ChatRefModel.fromEntity(e)).toList(),
        isDegraded: entity.isDegraded,
        timestamp: entity.timestamp,
        action: entity.action,
      );

  ChatMessageEntity toEntity() => ChatMessageEntity(
    id: id,
    text: text,
    sender: MessageSender.values.byName(sender),
    refs: refs.map((e) => e.toEntity()).toList(),
    isDegraded: isDegraded,
    timestamp: timestamp,
    action: action,
  );
}

class ChatSessionModel {
  final String id;
  final String title;
  final List<ChatMessageModel> messages;
  final DateTime lastUpdatedAt;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((e) => e.toJson()).toList(),
    'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
  };

  factory ChatSessionModel.fromJson(Map<dynamic, dynamic> json) =>
      ChatSessionModel(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List)
            .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      );
}
