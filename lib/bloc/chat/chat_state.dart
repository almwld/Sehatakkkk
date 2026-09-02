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
  final bool isPinned;
  const ChatPinned({required this.chatId, required this.isPinned});
  @override
  List<Object?> get props => [chatId, isPinned];
}

class ChatMuted extends ChatState {
  final String chatId;
  final bool isMuted;
  const ChatMuted({required this.chatId, required this.isMuted});
  @override
  List<Object?> get props => [chatId, isMuted];
}

class ChatArchived extends ChatState {
  final String chatId;
  const ChatArchived({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}
