import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/message_model.dart';
import '../../core/services/chat_service.dart';

// Events
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
  const SendMessage({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });
  @override
  List<Object?> get props => [chatId, text, imageUrl, audioUrl];
}

// States
abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {}
class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;
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

// BLoC
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatService _chatService = ChatService();
  StreamSubscription<List<MessageModel>>? _subscription;

  MessagesBloc() : super(MessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessagesState> emit) async {
    emit(MessagesLoading());
    try {
      _subscription?.cancel();
      _subscription = _chatService.streamMessages(event.chatId).listen(
        (messages) => emit(MessagesLoaded(messages: messages)),
        onError: (error) => emit(MessagesError(message: error.toString())),
      );
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessagesState> emit) async {
    try {
      await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      );
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
