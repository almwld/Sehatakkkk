import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/services/chat_service.dart';

import 'chat_state.dart';

class ChatBloc extends Cubit<ChatState> {
  final ChatService _chatService = ChatService();

  StreamSubscription<List<ChatModel>>? _chatsSubscription;

  ChatBloc() : super(const ChatInitial()) {
    loadChats();
  }

  /// الاستماع المستمر لقائمة المحادثات.
  void loadChats() {
    if (isClosed) return;

    emit(const ChatLoading());

    _chatsSubscription?.cancel();

    try {
      _chatsSubscription = _chatService.getChats().listen(
        (chats) {
          if (isClosed) return;

          emit(
            ChatLoaded(
              chats: List<ChatModel>.unmodifiable(chats),
            ),
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          if (isClosed) return;

          emit(
            ChatError(
              message: 'حدث خطأ في تحميل المحادثات: $error',
            ),
          );
        },
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        const ChatError(
          message: 'حدث خطأ في تحميل المحادثات',
        ),
      );
    }
  }

  /// إعادة تحميل/إعادة إنشاء الاستماع للمحادثات.
  void refreshChats() {
    if (isClosed) return;
    loadChats();
  }

  /// حذف محادثة.
  Future<void> deleteChat(String chatId) async {
    if (isClosed) return;

    final id = chatId.trim();

    if (id.isEmpty) {
      emit(
        const ChatError(
          message: 'معرف المحادثة غير صالح',
        ),
      );
      return;
    }

    try {
      await _chatService.deleteChat(id);

      if (!isClosed) {
        loadChats();
      }
    } catch (e) {
      if (isClosed) return;

      emit(
        const ChatError(
          message: 'فشل حذف المحادثة',
        ),
      );
    }
  }

  /// تحديث حالة قراءة المحادثة.
  Future<void> markAsRead(String chatId) async {
    final id = chatId.trim();

    if (id.isEmpty) return;

    try {
      await _chatService.markAsRead(id);
    } catch (e) {
      // لا نغيّر حالة قائمة المحادثات بسبب فشل تحديث القراءة فقط.
      print('⚠️ Error marking chat as read: $e');
    }
  }

  /// إنشاء محادثة مع طبيب.
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
  }) async {
    try {
      return await _chatService.createChat(
        doctorId: doctorId,
        doctorName: doctorName,
        patientId: patientId,
        patientName: patientName,
      );
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _chatsSubscription?.cancel();
    _chatsSubscription = null;

    _chatService.dispose();

    return super.close();
  }
}
