import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/message/message_event.dart';
import 'package:sehatak/bloc/message/message_state.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/message_model.dart';
import 'dart:async';

class MessageBloc extends Cubit<MessageState> {
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  String? _currentChatId;
  bool _hasMore = true;
  int _page = 0;
  StreamSubscription? _messageSubscription;

  MessageBloc() : super(MessageInitial()) {
    // تهيئة فارغة
  }

  // ✅ تحميل الرسائل
  void loadMessages(String chatId, {int limit = 50}) {
    emit(MessageLoading());
    _currentChatId = chatId;
    _page = 0;
    _hasMore = true;

    _messageSubscription?.cancel();
    _messageSubscription = _chatService.getMessages(chatId, limit: limit).listen(
      (messages) {
        _messages = messages;
        _hasMore = messages.length >= limit;
        emit(MessagesLoaded(messages: messages, hasMore: _hasMore));
      },
      onError: (error) {
        emit(MessageError(message: error.toString()));
      },
    );
  }

  // ✅ تحديث الرسائل
  void refreshMessages(String chatId) {
    loadMessages(chatId);
  }

  // ✅ إرسال رسالة
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyTo,
    String? replyToText,
  }) async {
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        text: text,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        fileUrl: fileUrl,
        locationUrl: locationUrl,
        replyTo: replyTo,
        replyToText: replyToText,
      );
      loadMessages(chatId);
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
    }
  }

  // ✅ حذف رسالة
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    bool forEveryone = true,
  }) async {
    try {
      await _chatService.deleteMessage(
        chatId: chatId,
        messageId: messageId,
        forEveryone: forEveryone,
      );
      loadMessages(chatId);
      ToastService.showSuccess('✅ تم حذف الرسالة');
    } catch (e) {
      ToastService.showError('❌ فشل حذف الرسالة: $e');
    }
  }

  // ✅ إضافة تفاعل
  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    try {
      await _chatService.addReaction(
        chatId: chatId,
        messageId: messageId,
        emoji: emoji,
      );
      loadMessages(chatId);
    } catch (e) {
      ToastService.showError('❌ فشل إضافة التفاعل: $e');
    }
  }

  // ✅ إزالة تفاعل
  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    try {
      await _chatService.removeReaction(
        chatId: chatId,
        messageId: messageId,
        emoji: emoji,
      );
      loadMessages(chatId);
    } catch (e) {
      ToastService.showError('❌ فشل إزالة التفاعل: $e');
    }
  }

  // ✅ البحث في الرسائل
  Future<void> searchMessages({
    required String chatId,
    required String query,
  }) async {
    try {
      final results = await _chatService.searchMessages(
        chatId: chatId,
        query: query,
      );
      emit(MessagesSearched(results: results, query: query));
    } catch (e) {
      emit(MessageError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}
