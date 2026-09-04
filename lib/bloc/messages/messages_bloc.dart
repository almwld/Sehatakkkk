import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/message_model.dart';
import '../../core/services/chat_service.dart';

// ============================================================
// 📋 الأحداث
// ============================================================
abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// 📥 تحميل الرسائل
// ============================================================
class LoadMessages extends MessagesEvent {
  final String chatId;
  final int limit;

  const LoadMessages({
    required this.chatId,
    this.limit = 30,
  });

  @override
  List<Object?> get props => [chatId, limit];
}

// ============================================================
// 📥 تحميل المزيد
// ============================================================
class LoadMoreMessages extends MessagesEvent {
  final String chatId;
  final int limit;

  const LoadMoreMessages({
    required this.chatId,
    required this.limit,
  });

  @override
  List<Object?> get props => [chatId, limit];
}

// ============================================================
// ✉️ إرسال رسالة
// ============================================================
class SendMessage extends MessagesEvent {
  final String chatId;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? locationUrl;
  final String? idempotencyKey;

  const SendMessage({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.locationUrl,
    this.idempotencyKey,
  });

  @override
  List<Object?> get props => [
        chatId,
        text,
        imageUrl,
        audioUrl,
        fileUrl,
        locationUrl,
        idempotencyKey,
      ];
}

// ============================================================
// ✅ تعليم الرسائل كمقروءة
// ============================================================
class MarkMessagesRead extends MessagesEvent {
  final String chatId;

  const MarkMessagesRead({
    required this.chatId,
  });

  @override
  List<Object?> get props => [chatId];
}

// ============================================================
// 🔄 إعادة التعيين
// ============================================================
class ResetMessages extends MessagesEvent {
  const ResetMessages();
}

// ============================================================
// 📊 الحالات
// ============================================================
abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;
  final bool hasMore;
  final bool isLoadingMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  const MessagesLoaded({
    required this.messages,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.lastDocument,
  });

  @override
  List<Object?> get props => [
        messages,
        hasMore,
        isLoadingMore,
        lastDocument,
      ];
}

class MessagesError extends MessagesState {
  final String message;

  const MessagesError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class MessageSending extends MessagesState {
  const MessageSending();
}

// ============================================================
// 🧠 MessagesBloc
// ============================================================
class MessagesBloc
    extends Bloc<MessagesEvent, MessagesState> {
  final ChatService _chatService = ChatService();

  StreamSubscription<List<MessageModel>>? _subscription;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;

  bool _hasMore = true;

  int _currentLimit = 30;

  String? _currentChatId;

  MessagesBloc() : super(const MessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesRead>(_onMarkMessagesRead);
    on<ResetMessages>(_onResetMessages);
  }

  // ============================================================
  // 📥 تحميل الرسائل
  // ============================================================
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessagesState> emit,
  ) async {
    emit(const MessagesLoading());

    _currentChatId = event.chatId;
    _currentLimit = event.limit;
    _hasMore = true;
    _lastDocument = null;

    await _subscription?.cancel();

    try {
      _subscription = _chatService
          .streamMessages(
            event.chatId,
            limit: event.limit,
          )
          .listen(
        (messages) {
          if (isClosed) {
            return;
          }

          final hasMore = messages.length >= event.limit;

          emit(
            MessagesLoaded(
              messages: messages,
              hasMore: hasMore,
              isLoadingMore: false,
              lastDocument: _lastDocument,
            ),
          );
        },
        onError: (error) {
          if (isClosed) {
            return;
          }

          emit(
            MessagesError(
              message: error.toString(),
            ),
          );
        },
      );

      add(
        MarkMessagesRead(
          chatId: event.chatId,
        ),
      );
    } catch (e) {
      emit(
        MessagesError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // 📥 تحميل المزيد
  // ============================================================
  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<MessagesState> emit,
  ) async {
    if (state is! MessagesLoaded) {
      return;
    }

    final currentState = state as MessagesLoaded;

    if (currentState.isLoadingMore) {
      return;
    }

    if (!currentState.hasMore) {
      return;
    }

    final startAfter = currentState.lastDocument;

    if (startAfter == null) {
      return;
    }

    emit(
      MessagesLoaded(
        messages: currentState.messages,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
        lastDocument: currentState.lastDocument,
      ),
    );

    try {
      final page =
          await _chatService.getMoreMessagesWithCursor(
        chatId: event.chatId,
        limit: event.limit,
        startAfter: startAfter,
      );

      if (isClosed) {
        return;
      }

      final existingIds =
          currentState.messages.map((e) => e.id).toSet();

      final newMessages = page.messages
          .where((message) => !existingIds.contains(message.id))
          .toList();

      final allMessages = [
        ...currentState.messages,
        ...newMessages,
      ];

      _lastDocument = page.lastDocument;
      _hasMore = page.hasMore;

      emit(
        MessagesLoaded(
          messages: allMessages,
          hasMore: page.hasMore,
          isLoadingMore: false,
          lastDocument: page.lastDocument,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }

      emit(
        MessagesError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // ✉️ إرسال رسالة
  // ============================================================
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessagesState> emit,
  ) async {
    final previousState = state;

    emit(const MessageSending());

    try {
      final idempotencyKey =
          event.idempotencyKey ??
          '${event.chatId}_${DateTime.now().millisecondsSinceEpoch}_${event.text.hashCode}';

      await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        idempotencyKey: idempotencyKey,
      );

      if (!isClosed) {
        add(
          LoadMessages(
            chatId: event.chatId,
            limit: _currentLimit,
          ),
        );
      }
    } catch (e) {
      if (isClosed) {
        return;
      }

      if (previousState is MessagesLoaded) {
        emit(previousState);
      } else {
        emit(
          MessagesError(
            message: e.toString(),
          ),
        );
      }
    }
  }

  // ============================================================
  // ✅ تعليم كمقروء
  // ============================================================
  Future<void> _onMarkMessagesRead(
    MarkMessagesRead event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _chatService.markAsRead(event.chatId);
    } catch (e) {
      // لا نكسر واجهة الدردشة بسبب فشل تحديث حالة القراءة.
      // ignore: avoid_print
      print(
        '⚠️ Error marking messages as read: $e',
      );
    }
  }

  // ============================================================
  // 🔄 Reset
  // ============================================================
  Future<void> _onResetMessages(
    ResetMessages event,
    Emitter<MessagesState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;

    _lastDocument = null;
    _hasMore = true;
    _currentChatId = null;

    emit(const MessagesInitial());
  }

  // ============================================================
  // 🧹 إغلاق
  // ============================================================
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;

    return super.close();
  }
}
