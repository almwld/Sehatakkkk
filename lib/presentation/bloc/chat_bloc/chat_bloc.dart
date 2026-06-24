import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();

  ChatBloc() : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<DeleteMessage>(_onDeleteMessage);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = <Map<String, dynamic>>[];
      await for (final snapshot in _chatService.getMessages(event.chatId)) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          messages.add({
            'id': doc.id,
            ...data,
          });
        }
        emit(ChatLoaded(messages));
        break; // أول مرة فقط
      }
    } catch (e) {
      emit(ChatError('فشل تحميل الرسائل: $e'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      );
      // تحديث القائمة
      add(LoadMessages(event.chatId));
    } catch (e) {
      emit(ChatError('فشل إرسال الرسالة: $e'));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    try {
      await _chatService.markAsRead(event.chatId, event.messageId);
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatService.deleteMessage(event.chatId, event.messageId);
      add(LoadMessages(event.chatId));
    } catch (e) {
      emit(ChatError('فشل حذف الرسالة: $e'));
    }
  }
}
