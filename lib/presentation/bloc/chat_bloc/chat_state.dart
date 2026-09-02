import 'package:equatable/equatable.dart';
import 'package:sehatak/core/models/chat_model.dart';

/// الحالة الأساسية لنظام المحادثات.
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية.
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// جاري تحميل المحادثات.
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// تم تحميل المحادثات بنجاح.
class ChatLoaded extends ChatState {
  final List<ChatModel> chats;

  const ChatLoaded({
    required this.chats,
  });

  @override
  List<Object?> get props => [chats];
}

/// حدث خطأ أثناء التعامل مع المحادثات.
class ChatError extends ChatState {
  final String message;

  const ChatError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
