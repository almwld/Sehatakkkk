// ============================================================
// 🎯 أحداث شاشة الدردشة
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// 📥 تحميل المحادثات
// ============================================================

class LoadChatsEvent extends ChatEvent {}

class RefreshChatsEvent extends ChatEvent {}

class GetChatEvent extends ChatEvent {
  final String chatId;
  const GetChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ============================================================
// 💬 إدارة المحادثات
// ============================================================

class CreateChatEvent extends ChatEvent {
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String? doctorImage;
  final String? patientImage;
  final bool isGroup;
  final String? groupName;
  final String? groupImage;
  final List<String>? admins;

  const CreateChatEvent({
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    this.doctorImage,
    this.patientImage,
    this.isGroup = false,
    this.groupName,
    this.groupImage,
    this.admins,
  });

  @override
  List<Object?> get props => [
        doctorId,
        doctorName,
        patientId,
        patientName,
        doctorImage,
        patientImage,
        isGroup,
        groupName,
        groupImage,
        admins,
      ];
}

class DeleteChatEvent extends ChatEvent {
  final String chatId;
  const DeleteChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ArchiveChatEvent extends ChatEvent {
  final String chatId;
  const ArchiveChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class UnarchiveChatEvent extends ChatEvent {
  final String chatId;
  const UnarchiveChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class PinChatEvent extends ChatEvent {
  final String chatId;
  const PinChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class UnpinChatEvent extends ChatEvent {
  final String chatId;
  const UnpinChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class MuteChatEvent extends ChatEvent {
  final String chatId;
  final Duration? duration;
  const MuteChatEvent({required this.chatId, this.duration});
  @override
  List<Object?> get props => [chatId, duration];
}

class UnmuteChatEvent extends ChatEvent {
  final String chatId;
  const UnmuteChatEvent({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ============================================================
// 💬 إدارة الرسائل
// ============================================================

class SendMessageEvent extends ChatEvent {
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

class DeleteMessageEvent extends ChatEvent {
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

class EditMessageEvent extends ChatEvent {
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

// ============================================================
// ❤️ التفاعلات
// ============================================================

class AddReactionEvent extends ChatEvent {
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

class RemoveReactionEvent extends ChatEvent {
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
// 🔍 البحث
// ============================================================

class SearchMessagesEvent extends ChatEvent {
  final String chatId;
  final String query;

  const SearchMessagesEvent({
    required this.chatId,
    required this.query,
  });

  @override
  List<Object?> get props => [chatId, query];
}

class SearchChatsEvent extends ChatEvent {
  final String query;

  const SearchChatsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

// ============================================================
// 📊 حالة الكتابة
// ============================================================

class SetTypingEvent extends ChatEvent {
  final String chatId;
  final bool isTyping;

  const SetTypingEvent({
    required this.chatId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [chatId, isTyping];
}

// ============================================================
// ✅ تحديث حالة القراءة
// ============================================================

class MarkAsReadEvent extends ChatEvent {
  final String chatId;

  const MarkAsReadEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}
