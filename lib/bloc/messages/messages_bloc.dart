// ============================================================
// ✉️ MessagesBloc - بلوك الرسائل الكامل
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import '../../core/services/chat_service.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatService _chatService = ChatService();
  Stream<List<MessageModel>>? _messageStream;
  StreamSubscription<List<MessageModel>>? _subscription;
  int _currentPage = 0;
  bool _hasMore = true;

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
    emit(MessagesLoading());
    _currentPage = 0;
    _hasMore = true;

    try {
      final messages = await _chatService.getMessages(event.chatId);
      _hasMore = messages.length >= event.limit;
      emit(MessagesLoaded(
        messages: messages,
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // 📥 تحميل المزيد من الرسائل
  // ============================================================

  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<MessagesState> emit) async {
    if (!_hasMore || state is MessagesLoading) return;

    _currentPage++;
    // TODO: تنفيذ تحميل المزيد
  }

  // ============================================================
  // 📤 إرسال رسالة
  // ============================================================

  Future<void> _onSendMessage(SendMessage event, Emitter<MessagesState> emit) async {
    emit(MessageSending());
    try {
      final message = await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        replyTo: event.replyTo,
      );
      emit(MessageSent(message: message));
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
      await _chatService.deleteMessage(event.chatId, event.messageId);
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
      await _chatService.addReaction(event.chatId, event.messageId, event.emoji);
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
      await _chatService.removeReaction(event.chatId, event.messageId);
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
      await _chatService.markAsRead(event.chatId);
    } catch (e) {
      print('⚠️ Error marking messages as read: $e');
    }
  }

  // ============================================================
  // 📡 البث الفوري للرسائل
  // ============================================================

  Future<void> _onStreamMessages(StreamMessages event, Emitter<MessagesState> emit) async {
    await _subscription?.cancel();

    _messageStream = _chatService.streamMessages(event.chatId);
    _subscription = _messageStream?.listen(
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
    await _subscription?.cancel();
    _subscription = null;
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
    _subscription?.cancel();
    return super.close();
  }
}
