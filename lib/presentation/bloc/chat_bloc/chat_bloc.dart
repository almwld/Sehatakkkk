import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();

  ChatBloc() : super(ChatInitialState()) {
    on<LoadChatMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendMessage);
    on<AddLocalMessage>(_onAddLocalMessage);
  }

  Future<void> _onLoadMessages(LoadChatMessages event, Emitter<ChatState> emit) async {
    if (state is ChatLoadedState) return;
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

  // ✅ Optimistic UI: إضافة الرسالة محلياً فوراً
  Future<void> _onSendMessage(SendChatMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoadedState) {
      // ✅ إضافة رسالة مؤقتة مع حالة "جاري الإرسال"
      final tempMessage = {
        'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'senderId': 'me',
        'senderName': 'أنت',
        'text': event.text,
        'imageUrl': event.imageUrl,
        'audioUrl': event.audioUrl,
        'timestamp': DateTime.now(),
        'read': false,
        'delivered': false,
        'isSending': true, // ✅ مؤشر الإرسال
      };

      final updatedMessages = List<Map<String, dynamic>>.from(currentState.messages)
        ..add(tempMessage);
      emit(ChatLoadedState(updatedMessages));

      try {
        await _chatService.sendMessage(
          chatId: event.chatId,
          text: event.text,
          imageUrl: event.imageUrl,
          audioUrl: event.audioUrl,
        );
        // ✅ إعادة تحميل الرسائل بعد الإرسال الناجح
        add(LoadChatMessages(event.chatId));
      } catch (e) {
        // ✅ تحديث حالة الرسالة إلى فاشلة
        final failedMessages = List<Map<String, dynamic>>.from(currentState.messages);
        final lastIndex = failedMessages.length - 1;
        if (lastIndex >= 0 && failedMessages[lastIndex]['isSending'] == true) {
          failedMessages[lastIndex]['isSending'] = false;
          failedMessages[lastIndex]['error'] = e.toString();
        }
        emit(ChatLoadedState(failedMessages));
      }
    }
  }

  // ✅ إضافة رسالة محلياً (للمعاينة)
  Future<void> _onAddLocalMessage(AddLocalMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoadedState) {
      final updatedMessages = List<Map<String, dynamic>>.from(currentState.messages)
        ..add(event.message);
      emit(ChatLoadedState(updatedMessages));
    }
  }
}
