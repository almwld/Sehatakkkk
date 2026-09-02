// ============================================================
// 💬 ChatEvent - أحداث المحادثات
// ============================================================

import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

// ✅ تحميل المحادثات
class LoadChats extends ChatEvent {}

// ✅ إنشاء محادثة
class CreateChat extends ChatEvent {
  final String doctorId;
  final String doctorName;
  final String patientName;
  final String? doctorImage;
  final String? patientImage;
  const CreateChat({
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    this.doctorImage,
    this.patientImage,
  });
  @override
  List<Object?> get props => [doctorId, doctorName, patientName, doctorImage, patientImage];
}

// ✅ تحميل محادثة محددة
class LoadChat extends ChatEvent {
  final String chatId;
  const LoadChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ✅ حذف محادثة
class DeleteChat extends ChatEvent {
  final String chatId;
  const DeleteChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ✅ البث الفوري للمحادثات
class StreamChats extends ChatEvent {}

// ✅ إيقاف البث الفوري
class StopStreamingChats extends ChatEvent {}

// ✅ تحديث حالة التثبيت
class TogglePinChat extends ChatEvent {
  final String chatId;
  final bool isPinned;
  const TogglePinChat({required this.chatId, required this.isPinned});
  @override
  List<Object?> get props => [chatId, isPinned];
}

// ✅ تحديث حالة الكتم
class ToggleMuteChat extends ChatEvent {
  final String chatId;
  final bool isMuted;
  const ToggleMuteChat({required this.chatId, required this.isMuted});
  @override
  List<Object?> get props => [chatId, isMuted];
}

// ✅ أرشفة محادثة
class ArchiveChat extends ChatEvent {
  final String chatId;
  const ArchiveChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

// ✅ إلغاء أرشفة محادثة
class UnarchiveChat extends ChatEvent {
  final String chatId;
  const UnarchiveChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}
