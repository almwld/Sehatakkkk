import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChatMessages extends ChatEvent {
  final String chatId;
  const LoadChatMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendChatMessage extends ChatEvent {
  final String chatId;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  const SendChatMessage({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });
  @override
  List<Object?> get props => [chatId, text, imageUrl, audioUrl];
}
