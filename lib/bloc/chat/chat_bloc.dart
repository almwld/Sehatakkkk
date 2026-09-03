import 'dart:async';
// ============================================================
// 🎯 ChatBloc - إدارة المحادثات مع Repository
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../domain/usecases/get_chats_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUseCase _getChatsUseCase = GetChatsUseCase();
  final SendMessageUseCase _sendMessageUseCase = SendMessageUseCase();

  StreamSubscription? _chatsSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<RefreshChats>(_onRefreshChats);
    on<SendChatMessage>(_onSendChatMessage);
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

  Future<void> _onRefreshChats(RefreshChats event, Emitter<ChatState> emit) async {
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

  Future<void> _onSendChatMessage(SendChatMessage event, Emitter<ChatState> emit) async {
    try {
      await _sendMessageUseCase.execute(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        replyTo: event.replyTo,
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
