import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/chat_model.dart';
import '../../core/services/chat_service.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}
class RefreshChats extends ChatEvent {}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  const ChatLoaded({required this.chats});
  @override
  List<Object?> get props => [chats];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();
  StreamSubscription<List<ChatModel>>? _subscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<RefreshChats>(_onRefreshChats);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      _subscription?.cancel();
      _subscription = _chatService.streamChats().listen(
        (chats) => emit(ChatLoaded(chats: chats)),
        onError: (error) => emit(ChatError(message: error.toString())),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onRefreshChats(RefreshChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      _subscription?.cancel();
      _subscription = _chatService.streamChats().listen(
        (chats) => emit(ChatLoaded(chats: chats)),
        onError: (error) => emit(ChatError(message: error.toString())),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
