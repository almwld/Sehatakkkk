import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<QuerySnapshot>? _chatsSubscription;

  ChatBloc() : super(ChatInitialState()) {
    on<LoadChatMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendMessage);
    on<LoadChatList>(_onLoadChatList);
    on<ListenToMessages>(_onListenToMessages);
    on<StopListening>(_onStopListening);
  }

  // ✅ تحميل الرسائل
  Future<void> _onLoadMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());
    try {
      final messages = <Map<String, dynamic>>[];
      final snapshot = await _chatService.getMessagesOnce(event.chatId);
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        messages.add({
          'id': doc.id,
          ...data,
        });
      }
      // ترتيب حسب الوقت
      messages.sort((a, b) {
        final timeA = a['timestamp'] as Timestamp?;
        final timeB = b['timestamp'] as Timestamp?;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeA.toDate().compareTo(timeB.toDate());
      });
      emit(ChatLoadedState(messages));
    } catch (e) {
      emit(ChatErrorState('فشل تحميل الرسائل: $e'));
    }
  }

  // ✅ الاستماع المستمر للرسائل (Real-time)
  Future<void> _onListenToMessages(
    ListenToMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessages(event.chatId).listen(
      (snapshot) {
        final messages = <Map<String, dynamic>>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          messages.add({
            'id': doc.id,
            ...data,
          });
        }
        messages.sort((a, b) {
          final timeA = a['timestamp'] as Timestamp?;
          final timeB = b['timestamp'] as Timestamp?;
          if (timeA == null && timeB == null) return 0;
          if (timeA == null) return 1;
          if (timeB == null) return -1;
          return timeA.toDate().compareTo(timeB.toDate());
        });
        emit(ChatLoadedState(messages));
      },
      onError: (error) {
        emit(ChatErrorState('فشل الاستماع للرسائل: $error'));
      },
    );
  }

  // ✅ تحميل قائمة المحادثات
  Future<void> _onLoadChatList(
    LoadChatList event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());
    _chatsSubscription?.cancel();
    _chatsSubscription = _chatService.getChats(event.userId, event.role).listen(
      (snapshot) {
        final chats = <Map<String, dynamic>>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          chats.add({
            'id': doc.id,
            ...data,
          });
        }
        emit(ChatListLoadedState(chats));
      },
      onError: (error) {
        emit(ChatErrorState('فشل تحميل المحادثات: $error'));
      },
    );
  }

  // ✅ إرسال رسالة
  Future<void> _onSendMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      );
    } catch (e) {
      emit(ChatErrorState('فشل إرسال الرسالة: $e'));
    }
  }

  // ✅ إيقاف الاستماع
  Future<void> _onStopListening(
    StopListening event,
    Emitter<ChatState> emit,
  ) async {
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
    return super.close();
  }
}
