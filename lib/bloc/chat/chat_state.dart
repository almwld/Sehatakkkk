// ============================================================
// 📊 حالة شاشة الدردشة
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

// ============================================================
// 🟢 حالة التحميل
// ============================================================

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatRefreshingState extends ChatState {}

// ============================================================
// ✅ حالة النجاح
// ============================================================

class ChatsLoadedState extends ChatState {
  final List<ChatModel> chats;
  final int unreadCount;

  const ChatsLoadedState({
    required this.chats,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [chats, unreadCount];
}

class ChatLoadedState extends ChatState {
  final ChatModel chat;

  const ChatLoadedState({required this.chat});

  @override
  List<Object?> get props => [chat];
}

class MessagesLoadedState extends ChatState {
  final List<MessageModel> messages;
  final String chatId;

  const MessagesLoadedState({
    required this.messages,
    required this.chatId,
  });

  @override
  List<Object?> get props => [messages, chatId];
}

// ============================================================
// 📤 حالة العمليات
// ============================================================

class ChatCreatedState extends ChatState {
  final String chatId;

  const ChatCreatedState({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

class MessageSentState extends ChatState {
  final MessageModel message;

  const MessageSentState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessageDeletedState extends ChatState {
  final String messageId;

  const MessageDeletedState({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class MessageEditedState extends ChatState {
  final MessageModel message;

  const MessageEditedState({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================
// 🔍 حالة البحث
// ============================================================

class MessagesSearchedState extends ChatState {
  final List<MessageModel> messages;
  final String query;

  const MessagesSearchedState({
    required this.messages,
    required this.query,
  });

  @override
  List<Object?> get props => [messages, query];
}

class ChatsSearchedState extends ChatState {
  final List<ChatModel> chats;
  final String query;

  const ChatsSearchedState({
    required this.chats,
    required this.query,
  });

  @override
  List<Object?> get props => [chats, query];
}

// ============================================================
// ❤️ حالة التفاعلات
// ============================================================

class ReactionAddedState extends ChatState {
  final String messageId;
  final String emoji;

  const ReactionAddedState({
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, emoji];
}

class ReactionRemovedState extends ChatState {
  final String messageId;
  final String emoji;

  const ReactionRemovedState({
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, emoji];
}

// ============================================================
// 🔄 حالة التحديثات
// ============================================================

class ChatUpdatedState extends ChatState {
  final ChatModel chat;

  const ChatUpdatedState({required this.chat});

  @override
  List<Object?> get props => [chat];
}

class TypingState extends ChatState {
  final List<String> typingUsers;

  const TypingState({required this.typingUsers});

  @override
  List<Object?> get props => [typingUsers];
}

// ============================================================
// ❌ حالة الخطأ
// ============================================================

class ChatErrorState extends ChatState {
  final String message;

  const ChatErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
