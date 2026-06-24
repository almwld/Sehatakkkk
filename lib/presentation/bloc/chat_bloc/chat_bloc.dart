import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();

  ChatBloc() : super(ChatInitialState()) {
    on<LoadChatMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendMessage);
    on<MarkMessageAsRead>(_onMarkAsRead);
    on<DeleteChatMessage>(_onDeleteMessage);
  }

  Future<void> _onLoadMessages(LoadChatMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
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
        emit(ChatLoadedState(messages));
        break;
      }
    } catch (e) {
      emit(ChatErrorState('فشل تحميل الرسائل: $e'));
    }
  }

  Future<void> _onSendMessage(SendChatMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      );
      add(LoadChatMessages(event.chatId));
    } catch (e) {
      emit(ChatErrorState('فشل إرسال الرسالة: $e'));
    }
  }

  Future<void> _onMarkAsRead(MarkMessageAsRead event, Emitter<ChatState> emit) async {
    try {
      await _chatService.markAsRead(event.chatId, event.messageId);
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  Future<void> _onDeleteMessage(DeleteChatMessage event, Emitter<ChatState> emit) async {
    try {
      await _chatService.deleteMessage(event.chatId, event.messageId);
      add(LoadChatMessages(event.chatId));
    } catch (e) {
      emit(ChatErrorState('فشل حذف الرسالة: $e'));
    }
  }
}
