import '../../../domain/entities/chat_message_entity.dart';
import '../../../domain/entities/chat_ref_entity.dart';

class ChatRefHiveModel {
  final String id;
  final String name;
  final String? image;
  final String? videoUrl;
  final String? muscleGroup;
  final String? difficulty;
  final String type;
  final bool isSnapshot;

  ChatRefHiveModel({
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

  factory ChatRefHiveModel.fromJson(Map<dynamic, dynamic> json) =>
      ChatRefHiveModel(
        id: json['id'],
        name: json['name'],
        image: json['image'],
        videoUrl: json['videoUrl'],
        muscleGroup: json['muscleGroup'],
        difficulty: json['difficulty'],
        type: json['type'],
        isSnapshot: json['isSnapshot'] ?? false,
      );

  factory ChatRefHiveModel.fromEntity(ChatRefEntity entity) => ChatRefHiveModel(
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

class ChatMessageHiveModel {
  final String id;
  final String text;
  final String sender;
  final List<ChatRefHiveModel> refs;
  final bool isDegraded;
  final DateTime timestamp;
  final String? action;

  ChatMessageHiveModel({
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

  factory ChatMessageHiveModel.fromJson(Map<dynamic, dynamic> json) =>
      ChatMessageHiveModel(
        id: json['id'],
        text: json['text'],
        sender: json['sender'],
        refs: (json['refs'] as List)
            .map((e) => ChatRefHiveModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        isDegraded: json['isDegraded'] ?? false,
        timestamp: DateTime.parse(json['timestamp']),
        action: json['action'],
      );

  factory ChatMessageHiveModel.fromEntity(ChatMessageEntity entity) =>
      ChatMessageHiveModel(
        id: entity.id,
        text: entity.text,
        sender: entity.sender.name,
        refs: entity.refs.map((e) => ChatRefHiveModel.fromEntity(e)).toList(),
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

class ChatSessionHiveModel {
  final String id;
  final String title;
  final List<ChatMessageHiveModel> messages;
  final DateTime lastUpdatedAt;

  ChatSessionHiveModel({
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

  factory ChatSessionHiveModel.fromJson(Map<dynamic, dynamic> json) =>
      ChatSessionHiveModel(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List)
            .map(
              (e) =>
                  ChatMessageHiveModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      );
}
