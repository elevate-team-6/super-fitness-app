import 'package:equatable/equatable.dart';
import 'chat_ref_entity.dart';

enum MessageSender { user, assistant }

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final List<ChatRefEntity> refs;
  final bool isDegraded;
  final DateTime timestamp;
  final String? action; // e.g., "Start Workout"

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    this.refs = const [],
    this.isDegraded = false,
    required this.timestamp,
    this.action,
  });

  ChatMessageEntity copyWith({
    String? text,
    List<ChatRefEntity>? refs,
    bool? isDegraded,
    String? action,
  }) {
    return ChatMessageEntity(
      id: id,
      text: text ?? this.text,
      sender: sender,
      refs: refs ?? this.refs,
      isDegraded: isDegraded ?? this.isDegraded,
      timestamp: timestamp,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    sender,
    refs,
    isDegraded,
    timestamp,
    action,
  ];
}
