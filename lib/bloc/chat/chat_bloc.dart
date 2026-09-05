import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/chat_model.dart';
import '../../core/models/call_model.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/call_service.dart';

// ============================================================
// 📋 الأحداث (Events)
// ============================================================
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}
class LoadCalls extends ChatEvent {}
class RefreshChats extends ChatEvent {}
class RefreshCalls extends ChatEvent {}
class DeleteChat extends ChatEvent {
  final String chatId;
  const DeleteChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}
class ArchiveChat extends ChatEvent {
  final String chatId;
  const ArchiveChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}
class PinChat extends ChatEvent {
  final String chatId;
  const PinChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}
class MuteChat extends ChatEvent {
  final String chatId;
  const MuteChat({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

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
  final List<ChatModel> chats;
  final List<CallModel> calls;
  const ChatLoaded({
    this.chats = const [],
    this.calls = const [],
  });
  @override
  List<Object?> get props => [chats, calls];
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
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  StreamSubscription<List<ChatModel>>? _chatsSubscription;
  StreamSubscription<List<CallModel>>? _callsSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadCalls>(_onLoadCalls);
    on<RefreshChats>(_onRefreshChats);
    on<RefreshCalls>(_onRefreshCalls);
    on<DeleteChat>(_onDeleteChat);
    on<ArchiveChat>(_onArchiveChat);
    on<PinChat>(_onPinChat);
    on<MuteChat>(_onMuteChat);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) {
      emit(ChatLoading());
    }
    try {
      _chatsSubscription?.cancel();
      _chatsSubscription = _chatService.streamChats().listen(
        (chats) {
          final currentCalls = state is ChatLoaded ? state.calls : [];
          emit(ChatLoaded(chats: chats, calls: currentCalls));
        },
        onError: (error) => emit(ChatError(message: error.toString())),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadCalls(LoadCalls event, Emitter<ChatState> emit) async {
    try {
      _callsSubscription?.cancel();
      _callsSubscription = _callService.streamCallHistory().listen(
        (calls) {
          final currentChats = state is ChatLoaded ? state.chats : [];
          emit(ChatLoaded(chats: currentChats, calls: calls));
        },
        onError: (error) => emit(ChatError(message: error.toString())),
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onRefreshChats(RefreshChats event, Emitter<ChatState> emit) async {
    add(LoadChats());
  }

  Future<void> _onRefreshCalls(RefreshCalls event, Emitter<ChatState> emit) async {
    add(LoadCalls());
  }

  Future<void> _onDeleteChat(DeleteChat event, Emitter<ChatState> emit) async {
    try {
      await _chatService.deleteChat(event.chatId);
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onArchiveChat(ArchiveChat event, Emitter<ChatState> emit) async {
    try {
      await _chatService.archiveChat(event.chatId, true);
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onPinChat(PinChat event, Emitter<ChatState> emit) async {
    try {
      await _chatService.pinChat(event.chatId, true);
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onMuteChat(MuteChat event, Emitter<ChatState> emit) async {
    try {
      await _chatService.muteChat(event.chatId, true);
      add(LoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _callsSubscription?.cancel();
    return super.close();
  }
}
