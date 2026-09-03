// ============================================================
// ✉️ MessagesEvent - أحداث الرسائل
// ============================================================

import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();
  @override
  List<Object?> get props => [];
}

// ✅ تحميل الرسائل
class LoadMessages extends MessagesEvent {
  final String chatId;
  final int limit;
  const LoadMessages({required this.chatId, this.limit = 50});
  @override
  List<Object?> get props => [chatId, limit];
}

// ✅ تحميل المزيد من الرسائل
class LoadMoreMessages extends MessagesEvent {
  final String chatId;
  const LoadMoreMessages({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ✅ إرسال رسالة
class SendMessage extends MessagesEvent {
  final String chatId;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final String? replyTo;
  const SendMessage({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    this.replyTo,
  });
  @override
  List<Object?> get props => [
    chatId, text, imageUrl, audioUrl, fileUrl, locationUrl, replyTo
  ];
}

// ✅ حذف رسالة
class DeleteMessage extends MessagesEvent {
  final String chatId;
  final String messageId;
  const DeleteMessage({required this.chatId, required this.messageId});
  @override
  List<Object?> get props => [chatId, messageId];
}

// ✅ إضافة تفاعل
class AddReaction extends MessagesEvent {
  final String chatId;
  final String messageId;
  final String emoji;
  const AddReaction({
    required this.chatId,
    required this.messageId,
    required this.emoji,
  });
  @override
  List<Object?> get props => [chatId, messageId, emoji];
}

// ✅ إزالة تفاعل
class RemoveReaction extends MessagesEvent {
  final String chatId;
  final String messageId;
  const RemoveReaction({required this.chatId, required this.messageId});
  @override
  List<Object?> get props => [chatId, messageId];
}

// ✅ تحديث حالة القراءة
class MarkMessagesRead extends MessagesEvent {
  final String chatId;
  const MarkMessagesRead({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ✅ البث الفوري للرسائل
class StreamMessages extends MessagesEvent {
  final String chatId;
  const StreamMessages({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ✅ إيقاف البث الفوري
class StopStreamingMessages extends MessagesEvent {
  const StopStreamingMessages();
}
