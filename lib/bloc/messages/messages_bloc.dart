import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/message_model.dart';
import '../../core/services/chat_service.dart';

// ============================================================
// 📋 الأحداث (Events)
// ============================================================
abstract class MessagesEvent extends Equatable {
  const MessagesEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessagesEvent {
  final String chatId;
  final int limit;
  const LoadMessages({required this.chatId, this.limit = 30});
  @override
  List<Object?> get props => [chatId, limit];
}

class LoadMoreMessages extends MessagesEvent {
  final String chatId;
  final int limit;
  const LoadMoreMessages({required this.chatId, required this.limit});
  @override
  List<Object?> get props => [chatId, limit];
}

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
  List<Object?> get props => [chatId, text, imageUrl, audioUrl, fileUrl, locationUrl, idempotencyKey];
}

class MarkMessagesRead extends MessagesEvent {
  final String chatId;
  const MarkMessagesRead({required this.chatId});
  @override
  List<Object?> get props => [chatId];
}

class ResetMessages extends MessagesEvent {}

// ============================================================
// 📊 الحالات (States)
// ============================================================
abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;
  final bool hasMore;
  final bool isLoadingMore;
  final DocumentSnapshot? lastDocument;
  const MessagesLoaded({
    required this.messages,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.lastDocument,
  });
  @override
  List<Object?> get props => [messages, hasMore, isLoadingMore, lastDocument];
}

class MessagesError extends MessagesState {
  final String message;
  const MessagesError({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageSending extends MessagesState {}

// ============================================================
// 🧠 BLoC
// ============================================================
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatService _chatService = ChatService();
  StreamSubscription<List<MessageModel>>? _subscription;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  int _currentLimit = 30;
  String? _currentChatId;

  MessagesBloc() : super(MessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesRead>(_onMarkMessagesRead);
    on<ResetMessages>(_onResetMessages);
  }

  // ============================================================
  // 📥 تحميل الرسائل
  // ============================================================
  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessagesState> emit) async {
    emit(MessagesLoading());
    _currentChatId = event.chatId;
    _hasMore = true;
    _lastDocument = null;
    _currentLimit = event.limit;

    try {
      _subscription?.cancel();
      _subscription = _chatService.streamMessages(event.chatId, limit: event.limit).listen(
        (messages) {
          final hasMore = messages.length >= event.limit;
          emit(MessagesLoaded(
            messages: messages,
            hasMore: hasMore,
            isLoadingMore: false,
            lastDocument: _lastDocument,
          ));
        },
        onError: (error) => emit(MessagesError(message: error.toString())),
      );

      add(MarkMessagesRead(chatId: event.chatId));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // 📥 تحميل المزيد من الرسائل (Pagination)
  // ============================================================
  Future<void> _onLoadMoreMessages(LoadMoreMessages event, Emitter<MessagesState> emit) async {
    if (state is! MessagesLoaded) return;
    final currentState = state as MessagesLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    final startAfter = currentState.lastDocument;
    if (startAfter == null) return;

    emit(MessagesLoaded(
      messages: currentState.messages,
      hasMore: currentState.hasMore,
      isLoadingMore: true,
      lastDocument: currentState.lastDocument,
    ));

    try {
      final page = await _chatService.getMoreMessagesWithCursor(
        chatId: event.chatId,
        limit: event.limit,
        startAfter: startAfter,
      );

      final allMessages = [...currentState.messages, ...page.messages];
      final hasMore = page.hasMore;

      emit(MessagesLoaded(
        messages: allMessages,
        hasMore: hasMore,
        isLoadingMore: false,
        lastDocument: page.lastDocument,
      ));
    } catch (e) {
      emit(MessagesError(message: e.toString()));
    }
  }

  // ============================================================
  // ✉️ إرسال رسالة
  // ============================================================
  Future<void> _onSendMessage(SendMessage event, Emitter<MessagesState> emit) async {
    emit(MessageSending());
    try {
      final idempotencyKey = event.idempotencyKey ?? 
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
      
      add(LoadMessages(chatId: event.chatId, limit: _currentLimit));
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
  // 🔄 إعادة تعيين
  // ============================================================
  void _onResetMessages(ResetMessages event, Emitter<MessagesState> emit) {
    _subscription?.cancel();
    _lastDocument = null;
    _hasMore = true;
    emit(MessagesInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
