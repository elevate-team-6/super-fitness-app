import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends ChatEvent {
  const LoadHistoryEvent();
}

class StartNewSessionEvent extends ChatEvent {
  const StartNewSessionEvent();
}

class LoadSessionEvent extends ChatEvent {
  final String sessionId;
  const LoadSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class DeleteSessionEvent extends ChatEvent {
  final String sessionId;
  const DeleteSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class SendMessageEvent extends ChatEvent {
  final String text;
  const SendMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class ClearErrorEvent extends ChatEvent {
  const ClearErrorEvent();
}
