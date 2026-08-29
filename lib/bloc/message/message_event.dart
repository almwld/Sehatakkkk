// ============================================================
// 🎯 أحداث الرسائل
// ============================================================

import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// 📥 تحميل الرسائل
// ============================================================

class LoadMessagesEvent extends MessageEvent {
  final String chatId;
  final int limit;

  const LoadMessagesEvent({
    required this.chatId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [chatId, limit];
}

class LoadMoreMessagesEvent extends MessageEvent {
  final String chatId;
  final int limit;

  const LoadMoreMessagesEvent({
    required this.chatId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [chatId, limit];
}

class RefreshMessagesEvent extends MessageEvent {
  final String chatId;

  const RefreshMessagesEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

// ============================================================
// 💬 إدارة الرسائل
// ============================================================

class SendMessageEvent extends MessageEvent {
  final String chatId;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final String? replyTo;
  final String? replyToText;
  final bool isEncrypted;
  final bool isSelfDestruct;
  final int selfDestructDuration;

  const SendMessageEvent({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    this.replyTo,
    this.replyToText,
    this.isEncrypted = false,
    this.isSelfDestruct = false,
    this.selfDestructDuration = 0,
  });

  @override
  List<Object?> get props => [
        chatId,
        text,
        imageUrl,
        audioUrl,
        fileUrl,
        locationUrl,
        replyTo,
        replyToText,
        isEncrypted,
        isSelfDestruct,
        selfDestructDuration,
      ];
}

class EditMessageEvent extends MessageEvent {
  final String chatId;
  final String messageId;
  final String newText;

  const EditMessageEvent({
    required this.chatId,
    required this.messageId,
    required this.newText,
  });

  @override
  List<Object?> get props => [chatId, messageId, newText];
}

class DeleteMessageEvent extends MessageEvent {
  final String chatId;
  final String messageId;
  final bool forEveryone;

  const DeleteMessageEvent({
    required this.chatId,
    required this.messageId,
    this.forEveryone = true,
  });

  @override
  List<Object?> get props => [chatId, messageId, forEveryone];
}

class ReplyToMessageEvent extends MessageEvent {
  final String chatId;
  final String messageId;
  final String replyText;

  const ReplyToMessageEvent({
    required this.chatId,
    required this.messageId,
    required this.replyText,
  });

  @override
  List<Object?> get props => [chatId, messageId, replyText];
}

// ============================================================
// ❤️ التفاعلات
// ============================================================

class AddReactionEvent extends MessageEvent {
  final String chatId;
  final String messageId;
  final String emoji;

  const AddReactionEvent({
    required this.chatId,
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [chatId, messageId, emoji];
}

class RemoveReactionEvent extends MessageEvent {
  final String chatId;
  final String messageId;
  final String emoji;

  const RemoveReactionEvent({
    required this.chatId,
    required this.messageId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [chatId, messageId, emoji];
}

// ============================================================
// ✅ تحديثات الحالة
// ============================================================

class MarkMessageAsReadEvent extends MessageEvent {
  final String chatId;
  final String messageId;

  const MarkMessageAsReadEvent({
    required this.chatId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [chatId, messageId];
}

class MarkAllMessagesAsReadEvent extends MessageEvent {
  final String chatId;

  const MarkAllMessagesAsReadEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

// ============================================================
// 🔍 البحث
// ============================================================

class SearchMessagesEvent extends MessageEvent {
  final String chatId;
  final String query;

  const SearchMessagesEvent({
    required this.chatId,
    required this.query,
  });

  @override
  List<Object?> get props => [chatId, query];
}

class ClearSearchEvent extends MessageEvent {}
