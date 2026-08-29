import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/message/message_event.dart';
import 'package:sehatak/bloc/message/message_state.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/message_model.dart';
import 'dart:async';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  String? _currentChatId;
  bool _hasMore = true;
  int _page = 0;
  StreamSubscription? _messageSubscription;

  MessageBloc() : super(MessageInitialState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<RefreshMessagesEvent>(_onRefreshMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<ReplyToMessageEvent>(_onReplyToMessage);
    on<AddReactionEvent>(_onAddReaction);
    on<RemoveReactionEvent>(_onRemoveReaction);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
    on<MarkAllMessagesAsReadEvent>(_onMarkAllMessagesAsRead);
    on<SearchMessagesEvent>(_onSearchMessages);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoadingState());
    _currentChatId = event.chatId;
    _page = 0;
    _hasMore = true;

    _messageSubscription?.cancel();
    _messageSubscription = _chatService.getMessages(
      event.chatId,
      limit: event.limit,
    ).listen(
      (messages) {
        _messages = messages;
        _hasMore = messages.length >= event.limit;
        emit(MessagesLoadedState(
          messages: messages,
          hasMore: _hasMore,
        ));
      },
      onError: (error) {
        emit(MessageErrorState(message: error.toString()));
      },
    );
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    if (!_hasMore || state is MessageLoadingState) return;
    emit(LoadingMoreMessagesState());
    // TODO: تنفيذ تحميل المزيد
  }

  Future<void> _onRefreshMessages(
    RefreshMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageRefreshingState());
    _page = 0;
    _hasMore = true;
    await _onLoadMessages(
      LoadMessagesEvent(chatId: event.chatId, limit: 50),
      emit,
    );
    ToastService.showSuccess('✅ تم تحديث الرسائل');
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      final message = await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        replyTo: event.replyTo,
        replyToText: event.replyToText,
      );

      emit(MessageSentState(message: message));
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
      emit(MessageErrorState(message: e.toString()));
    }
  }

  Future<void> _onEditMessage(
    EditMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      ToastService.showSuccess('✅ تم تعديل الرسالة');
    } catch (e) {
      ToastService.showError('❌ فشل تعديل الرسالة: $e');
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _chatService.deleteMessage(
        chatId: event.chatId,
        messageId: event.messageId,
        forEveryone: event.forEveryone,
      );

      emit(MessageDeletedState(messageId: event.messageId));
      ToastService.showSuccess('✅ تم حذف الرسالة');
    } catch (e) {
      ToastService.showError('❌ فشل حذف الرسالة: $e');
    }
  }

  Future<void> _onReplyToMessage(
    ReplyToMessageEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.replyText,
        replyTo: event.messageId,
      );
      ToastService.showSuccess('✅ تم إرسال الرد');
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرد: $e');
    }
  }

  Future<void> _onAddReaction(
    AddReactionEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _chatService.addReaction(
        chatId: event.chatId,
        messageId: event.messageId,
        emoji: event.emoji,
      );
      emit(ReactionAddedState(
        messageId: event.messageId,
        emoji: event.emoji,
      ));
    } catch (e) {
      ToastService.showError('❌ فشل إضافة التفاعل: $e');
    }
  }

  Future<void> _onRemoveReaction(
    RemoveReactionEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _chatService.removeReaction(
        chatId: event.chatId,
        messageId: event.messageId,
        emoji: event.emoji,
      );
      emit(ReactionRemovedState(
        messageId: event.messageId,
        emoji: event.emoji,
      ));
    } catch (e) {
      ToastService.showError('❌ فشل إزالة التفاعل: $e');
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      // TODO: تنفيذ تحديث حالة القراءة لرسالة محددة
    } catch (e) {
      print('❌ Mark as read error: $e');
    }
  }

  Future<void> _onMarkAllMessagesAsRead(
    MarkAllMessagesAsReadEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _chatService.markAsRead(event.chatId);
      ToastService.showSuccess('✅ تم تحديث حالة القراءة');
    } catch (e) {
      ToastService.showError('❌ فشل تحديث حالة القراءة: $e');
    }
  }

  Future<void> _onSearchMessages(
    SearchMessagesEvent event,
    Emitter<MessageState> emit,
  ) async {
    try {
      final results = await _chatService.searchMessages(
        chatId: event.chatId,
        query: event.query,
      );
      emit(MessagesSearchedState(
        results: results,
        query: event.query,
      ));
    } catch (e) {
      emit(MessageErrorState(message: e.toString()));
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<MessageState> emit,
  ) async {
    if (_currentChatId != null) {
      add(LoadMessagesEvent(chatId: _currentChatId!));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}
