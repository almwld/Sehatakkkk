import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/message_model.dart';

// ✅ حدث التحديث
class RefreshChatsEvent {}

class ChatBloc extends Cubit<ChatState> {
  final ChatService _chatService = ChatService();
  StreamSubscription? _chatsSubscription;
  List<ChatModel> _chats = [];

  ChatBloc() : super(ChatInitial()) {
    loadChats();
  }

  // ✅ تحميل المحادثات
  void loadChats() {
    try {
      emit(ChatLoading());
      _chatsSubscription?.cancel();
      _chatsSubscription = _chatService.getChats().listen(
        (chats) {
          _chats = chats;
          emit(ChatLoaded(chats: chats));
        },
        onError: (error) {
          emit(ChatError(message: 'حدث خطأ في تحميل المحادثات: $error'));
        },
      );
    } catch (e) {
      emit(ChatError(message: 'حدث خطأ في تحميل المحادثات'));
    }
  }

  // ✅ تحديث المحادثات (بدلاً من add)
  void refreshChats() {
    loadChats();
  }

  // ✅ حذف محادثة
  Future<void> deleteChat(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      loadChats();
    } catch (e) {
      emit(ChatError(message: 'فشل حذف المحادثة'));
    }
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    try {
      await _chatService.markAsRead(chatId);
    } catch (e) {
      print('⚠️ Error marking as read: $e');
    }
  }

  // ✅ إنشاء محادثة
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
  }) async {
    try {
      final chatId = await _chatService.createChat(
        doctorId: doctorId,
        doctorName: doctorName,
        patientId: patientId,
        patientName: patientName,
      );
      return chatId;
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}

// ✅ حالات Chat
abstract class ChatState {}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<ChatModel> chats;
  ChatLoaded({required this.chats});
}
class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}
