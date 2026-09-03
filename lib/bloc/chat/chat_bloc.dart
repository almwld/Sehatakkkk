import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/entities/chat_entity.dart';
import '../../domain/usecases/get_chats_usecase.dart';

// ============================================================
// 📋 الأحداث (Events)
// ============================================================
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}
class RefreshChats extends ChatEvent {}
class ClearChats extends ChatEvent {}

// ============================================================
// 📊 الحالات (States)
// ============================================================
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatEntity> chats;
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

// ============================================================
// 🧠 BLoC
// ============================================================
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUseCase _getChatsUseCase = GetChatsUseCase();
  StreamSubscription<List<ChatEntity>>? _chatsSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<RefreshChats>(_onRefreshChats);
    on<ClearChats>(_onClearChats);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      _chatsSubscription?.cancel();
      _chatsSubscription = _getChatsUseCase.execute().listen(
        (chats) => emit(ChatLoaded(chats: chats)),
        onError: (error) => emit(ChatError(message: error.toString())),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onRefreshChats(
    RefreshChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      _chatsSubscription?.cancel();
      _chatsSubscription = _getChatsUseCase.execute().listen(
        (chats) => emit(ChatLoaded(chats: chats)),
        onError: (error) => emit(ChatError(message: error.toString())),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void _onClearChats(ClearChats event, Emitter<ChatState> emit) {
    _chatsSubscription?.cancel();
    emit(ChatInitial());
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
