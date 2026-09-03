import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/entities/message_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../data/repositories/chat_repository.dart';

// ============================================================
// 📋 الأحداث (Events)
// ============================================================
abstract class MessagesEvent extends Equatable {
  const MessagesEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessagesEvent {
  final String chatId;
  const LoadMessages({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends MessagesEvent {
  final String chatId;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final String? replyToId;
  final Map<String, dynamic>? attachments;

  const SendMessage({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    this.replyToId,
    this.attachments,
  });
  @override
  List<Object?> get props => [
    chatId, text, imageUrl, audioUrl, fileUrl, locationUrl,
    replyToId, attachments,
  ];
}

class DeleteMessage extends MessagesEvent {
  final String chatId;
  final String messageId;
  const DeleteMessage({required this.chatId, required this.messageId});
  @override
  List<Object?> get props => [chatId, messageId];
}

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

class RemoveReaction extends MessagesEvent {
  final String chatId;
  final String messageId;
  const RemoveReaction({required this.chatId, required this.messageId});
  @override
  List<Object?> get props => [chatId, messageId];
}

class MarkMessagesRead extends MessagesEvent {
  final String chatId;
  const MarkMessagesRead({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ClearMessages extends MessagesEvent {}

// ============================================================
// 📊 الحالات (States)
// ============================================================
abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {}
class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageEntity> messages;
  const MessagesLoaded({required this.messages});
  @override
  List<Object?> get props => [messages];
}

class MessagesError extends MessagesState {
  final String message;
  const MessagesError({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageSending extends MessagesState {}
class MessageSent extends MessagesState {
  final MessageEntity message;
  const MessageSent({required this.message});
  @override
  List<Object?> get props => [message];
}

// ============================================================
// 🧠 BLoC
// ============================================================
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatRepository _repository = ChatRepository();
  final SendMessageUseCase _sendMessageUseCase = SendMessageUseCase();
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  MessagesBloc() : super(MessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<AddReaction>(_onAddReaction);
    on<RemoveReaction>(_onRemoveReaction);
    on<MarkMessagesRead>(_onMarkMessagesRead);
    on<ClearMessages>(_onClearMessages);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessagesState> emit,
  ) async {
    emit(MessagesLoading());
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = _repository.getMessages(event.chatId).listen(
        (messages) => emit(MessagesLoaded(messages: messages)),
        onError: (error) => emit(MessagesError(message: error.toString())),
      );
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessagesState> emit,
  ) async {
    emit(MessageSending());
    try {
      final message = await _sendMessageUseCase.execute(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        replyToId: event.replyToId,
        attachments: event.attachments,
      );
      emit(MessageSent(message: message));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _repository.deleteMessage(event.chatId, event.messageId);
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _repository.addReaction(
        event.chatId,
        event.messageId,
        event.reaction,
      );
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  Future<void> _onRemoveReaction(
    RemoveReaction event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _repository.removeReaction(event.chatId, event.messageId);
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  Future<void> _onMarkMessagesRead(
    MarkMessagesRead event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.chatId);
    } catch (e) {
      print('⚠️ Error marking messages as read: $e');
    }
  }

  void _onClearMessages(ClearMessages event, Emitter<MessagesState> emit) {
    _messagesSubscription?.cancel();
    emit(MessagesInitial());
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
