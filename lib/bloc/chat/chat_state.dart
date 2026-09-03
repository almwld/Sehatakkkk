// ============================================================
// 💬 ChatState - حالة المحادثات
// ============================================================

import 'package:equatable/equatable.dart';
import '../../core/models/chat_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  final bool isStreaming;
  const ChatLoaded({
    required this.chats,
    this.isStreaming = false,
  });
  @override
  List<Object?> get props => [chats, isStreaming];
}

class ChatDetailLoaded extends ChatState {
  final ChatModel chat;
  const ChatDetailLoaded({required this.chat});
  @override
  List<Object?> get props => [chat];
}

class ChatCreated extends ChatState {
  final ChatModel chat;
  const ChatCreated({required this.chat});
  @override
  List<Object?> get props => [chat];
}

class ChatDeleted extends ChatState {
  final String chatId;
  const ChatDeleted({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatPinned extends ChatState {
  final String chatId;
  const ChatPinned({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatUnpinned extends ChatState {
  final String chatId;
  const ChatUnpinned({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatMuted extends ChatState {
  final String chatId;
  const ChatMuted({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatUnmuted extends ChatState {
  final String chatId;
  const ChatUnmuted({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatArchived extends ChatState {
  final String chatId;
  const ChatArchived({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatUnarchived extends ChatState {
  final String chatId;
  const ChatUnarchived({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}
