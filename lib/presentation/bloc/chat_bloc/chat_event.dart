import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChatMessages extends ChatEvent {
  final String conversationId;
  const LoadChatMessages(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class SendChatMessage extends ChatEvent {
  final String conversationId;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  const SendChatMessage({
    required this.conversationId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });
  @override
  List<Object?> get props => [conversationId, text, imageUrl, audioUrl];
}
