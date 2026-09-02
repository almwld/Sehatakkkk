// ============================================================
// ✉️ MessagesState - حالة الرسائل
// ============================================================

import 'package:equatable/equatable.dart';
import '../../core/models/message_model.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;
  final bool hasMore;
  final bool isStreaming;
  const MessagesLoaded({
    required this.messages,
    this.hasMore = false,
    this.isStreaming = false,
  });
  @override
  List<Object?> get props => [messages, hasMore, isStreaming];
}

class MessagesError extends MessagesState {
  final String message;
  const MessagesError({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageSending extends MessagesState {}

class MessageSent extends MessagesState {
  final MessageModel message;
  const MessageSent({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageDeleted extends MessagesState {
  final String messageId;
  const MessageDeleted({required this.messageId});
  @override
  List<Object?> get props => [messageId];
}

class ReactionAdded extends MessagesState {
  final String messageId;
  final String reaction;
  const ReactionAdded({required this.messageId, required this.reaction});
  @override
  List<Object?> get props => [messageId, reaction];
}

class ReactionRemoved extends MessagesState {
  final String messageId;
  const ReactionRemoved({required this.messageId});
  @override
  List<Object?> get props => [messageId];
}
