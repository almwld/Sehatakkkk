// ============================================================
// 🎯 ChatBloc - معالجة الأخطاء
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/chat/chat_event.dart';
import 'package:sehatak/bloc/chat/chat_state.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';
import 'dart:async';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();

  List<ChatModel> _allChats = [];
  StreamSubscription? _chatSubscription;

  ChatBloc() : super(ChatInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<RefreshChatsEvent>(_onRefreshChats);
    on<DeleteChatEvent>(_onDeleteChat);
    on<MarkAsReadEvent>(_onMarkAsRead);
  }

  // ✅ تحميل المحادثات مع معالجة الأخطاء
  Future<void> _onLoadChats(
    LoadChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔄 Loading chats...');
      emit(ChatLoadingState());

      _chatSubscription?.cancel();

      _chatSubscription = _chatService.getChats().listen(
        (chats) {
          print('📋 Received ${chats.length} chats');
          _allChats = chats;
          final unreadCount = _getTotalUnread(chats);
          emit(ChatsLoadedState(chats: chats, unreadCount: unreadCount));
        },
        onError: (error) {
          print('❌ Error in chat stream: $error');
          emit(ChatErrorState(message: 'حدث خطأ في تحميل المحادثات: $error'));
        },
      );
    } catch (e) {
      print('❌ Error loading chats: $e');
      emit(ChatErrorState(message: 'حدث خطأ في تحميل المحادثات'));
    }
  }

  Future<void> _onRefreshChats(
    RefreshChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔄 Refreshing chats...');
      emit(ChatRefreshingState());
      await _onLoadChats(LoadChatsEvent(), emit);
    } catch (e) {
      emit(ChatErrorState(message: 'فشل تحديث المحادثات'));
    }
  }

  Future<void> _onDeleteChat(
    DeleteChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.deleteChat(event.chatId);
      add(RefreshChatsEvent());
    } catch (e) {
      emit(ChatErrorState(message: 'فشل حذف المحادثة'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.markAsRead(event.chatId);
    } catch (e) {
      print('⚠️ Error marking as read: $e');
    }
  }

  int _getTotalUnread(List<ChatModel> chats) {
    int total = 0;
    for (final chat in chats) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        total += chat.getUnreadCount(user.uid);
      }
    }
    return total;
  }

  // ✅ إنشاء محادثة جديدة
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
  }) async {
    // استخدام chat_service مباشرة
    final chatId = await _chatService.createTestChat();
    return chatId;
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}
