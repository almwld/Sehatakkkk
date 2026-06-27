import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();

  ChatBloc() : super(ChatInitialState()) {
    on<LoadChatMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(LoadChatMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
    try {
      final messages = <Map<String, dynamic>>[];
      // ✅ استخدام getMessages من ChatService
      await for (final snapshot in _chatService.getMessages(event.conversationId)) {
        for (final message in snapshot) {
          messages.add({
            'id': message.id,
            'senderId': message.senderId,
            'senderName': message.senderName,
            'text': message.content,
            'timestamp': message.timestamp,
            'status': message.status.name,
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
        conversationId: event.conversationId,
        content: event.text,
      );
      add(LoadChatMessages(event.conversationId));
    } catch (e) {
      emit(ChatErrorState('فشل إرسال الرسالة: $e'));
    }
  }
}
