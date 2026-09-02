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

// ✅ إرسال رسالة
class SendMessage extends MessagesEvent {
  final String chatId;
  final String text;
  final String type;
  final String? replyToId;
  final Map<String, dynamic>? attachments;
  final Map<String, dynamic>? location;
  const SendMessage({
    required this.chatId,
    required this.text,
    this.type = 'text',
    this.replyToId,
    this.attachments,
    this.location,
  });
  @override
  List<Object?> get props => [chatId, text, type, replyToId, attachments, location];
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
  final String reaction;
  const AddReaction({
    required this.chatId,
    required this.messageId,
    required this.reaction,
  });
  @override
  List<Object?> get props => [chatId, messageId, reaction];
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
