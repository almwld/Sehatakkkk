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

class ListenToMessages extends ChatEvent {
  final String chatId;
  const ListenToMessages(this.chatId);
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

class LoadChatList extends ChatEvent {
  final String userId;
  final String role;
  const LoadChatList({required this.userId, required this.role});
  @override
  List<Object?> get props => [userId, role];
}

class StopListening extends ChatEvent {
  const StopListening();
}
