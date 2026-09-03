import 'dart:async';
// ============================================================
// ✉️ MessagesBloc - إدارة الرسائل مع Repository
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../data/repositories/chat_repository.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatRepository _repository = ChatRepository();
  final SendMessageUseCase _sendMessageUseCase = SendMessageUseCase();
  
  StreamSubscription? _messagesSubscription;
  String? _currentChatId;

  MessagesBloc() : super(MessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<AddReaction>(_onAddReaction);
    on<RemoveReaction>(_onRemoveReaction);
    on<MarkMessagesRead>(_onMarkMessagesRead);
    on<StreamMessages>(_onStreamMessages);
    on<StopStreamingMessages>(_onStopStreamingMessages);
  }

  // ============================================================
  // 📥 تحميل الرسائل
  // ============================================================

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessagesState> emit) async {
    _currentChatId = event.chatId;
    emit(MessagesLoading());
    
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = _repository.getMessages(event.chatId).listen(
        (messages) {
          emit(MessagesLoaded(
            messages: messages,
            hasMore: messages.length >= 50,
          ));
        },
        onError: (error) {
          emit(MessagesError(message: error.toString()));
        },
      );
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // 📥 تحميل المزيد من الرسائل
  // ============================================================

  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final currentState = state as MessagesLoaded;
    if (!currentState.hasMore) return;

    // TODO: تنفيذ pagination
  }

  // ============================================================
  // 📤 إرسال رسالة
  // ============================================================

  Future<void> _onSendMessage(SendMessage event, Emitter<MessagesState> emit) async {
    emit(MessageSending());
    try {
      final message = await _sendMessageUseCase.execute(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        replyTo: event.replyTo,
      );
      emit(MessageSent(message: message));
      // إعادة تحميل الرسائل لتحديث القائمة
      add(LoadMessages(chatId: event.chatId));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // 🗑️ حذف رسالة
  // ============================================================

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<MessagesState> emit) async {
    try {
      // TODO: تنفيذ حذف الرسالة
      emit(MessageDeleted(messageId: event.messageId));
      add(LoadMessages(chatId: event.chatId));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // ❤️ إضافة تفاعل
  // ============================================================

  Future<void> _onAddReaction(AddReaction event, Emitter<MessagesState> emit) async {
    try {
      // TODO: تنفيذ إضافة تفاعل
      emit(ReactionAdded(messageId: event.messageId, emoji: event.emoji));
      add(LoadMessages(chatId: event.chatId));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // ❤️ إزالة تفاعل
  // ============================================================

  Future<void> _onRemoveReaction(RemoveReaction event, Emitter<MessagesState> emit) async {
    try {
      // TODO: تنفيذ إزالة تفاعل
      emit(ReactionRemoved(messageId: event.messageId));
      add(LoadMessages(chatId: event.chatId));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // ✅ تحديث حالة القراءة
  // ============================================================

  Future<void> _onMarkMessagesRead(MarkMessagesRead event, Emitter<MessagesState> emit) async {
    try {
      await _repository.markAsRead(event.chatId);
    } catch (e) {
      print('⚠️ Error marking messages as read: $e');
    }
  }

  // ============================================================
  // 📡 البث الفوري للرسائل
  // ============================================================

  Future<void> _onStreamMessages(StreamMessages event, Emitter<MessagesState> emit) async {
    _currentChatId = event.chatId;
    await _messagesSubscription?.cancel();
    
    _messagesSubscription = _repository.getMessages(event.chatId).listen(
      (messages) {
        if (state is MessagesLoaded) {
          final currentState = state as MessagesLoaded;
          emit(MessagesLoaded(
            messages: messages,
            hasMore: currentState.hasMore,
            isStreaming: true,
          ));
        } else {
          emit(MessagesLoaded(
            messages: messages,
            isStreaming: true,
          ));
        }
        // تحديث حالة القراءة تلقائياً
        add(MarkMessagesRead(chatId: event.chatId));
      },
      onError: (error) {
        emit(MessagesError(message: error.toString()));
      },
    );
  }

  // ============================================================
  // ⏹️ إيقاف البث الفوري
  // ============================================================

  Future<void> _onStopStreamingMessages(
    StopStreamingMessages event,
    Emitter<MessagesState> emit,
  ) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      emit(MessagesLoaded(
        messages: currentState.messages,
        hasMore: currentState.hasMore,
        isStreaming: false,
      ));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
