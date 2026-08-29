// ============================================================
// 📊 حالة الرسائل
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:sehatak/models/message_model.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

// ============================================================
// 🟢 حالة التحميل
// ============================================================

class MessageInitialState extends MessageState {}

class MessageLoadingState extends MessageState {}

class MessageRefreshingState extends MessageState {}

class LoadingMoreMessagesState extends MessageState {}

// ============================================================
// ✅ حالة النجاح
// ============================================================

class MessagesLoadedState extends MessageState {
  final List<MessageModel> messages;
  final bool hasMore;

  const MessagesLoadedState({
    required this.messages,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [messages, hasMore];
}

// ============================================================
// 📤 حالة العمليات
// ============================================================

class MessageSentState extends MessageState {
  final MessageModel message;

  const MessageSentState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessageEditedState extends MessageState {
  final MessageModel message;

  const MessageEditedState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessageDeletedState extends MessageState {
  final String messageId;

  const MessageDeletedState({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

// ============================================================
// ❤️ حالة التفاعلات
// ============================================================

class ReactionAddedState extends MessageState {
  final String messageId;
  final String emoji;

  const ReactionAddedState({
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, emoji];
}

class ReactionRemovedState extends MessageState {
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
// 🔍 حالة البحث
// ============================================================

class MessagesSearchedState extends MessageState {
  final List<MessageModel> results;
  final String query;

  const MessagesSearchedState({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

// ============================================================
// ❌ حالة الخطأ
// ============================================================

class MessageErrorState extends MessageState {
  final String message;

  const MessageErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
