import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/models/message_model.dart';

// ============================================================
// 📊 حالة الرسائل
// ============================================================

abstract class MessageState {}

class MessageInitial extends MessageState {}
class MessageLoading extends MessageState {}
class MessagesLoaded extends MessageState {
  final List<MessageModel> messages;
  final bool hasMore;
  MessagesLoaded({required this.messages, this.hasMore = false});
}
class MessageError extends MessageState {
  final String message;
  MessageError({required this.message});
}
class MessagesSearched extends MessageState {
  final List<MessageModel> results;
  final String query;
  MessagesSearched({required this.results, required this.query});
}

// ============================================================
// 🎯 بلوك الرسائل
// ============================================================

class MessageBloc extends Cubit<MessageState> {
  final ChatService _chatService = ChatService();
  List<MessageModel> _messages = [];
  String? _currentChatId;
  bool _hasMore = true;

  MessageBloc() : super(MessageInitial());

  void loadMessages(String chatId, {int limit = 50}) {
    emit(MessageLoading());
    _currentChatId = chatId;
    
    _chatService.getMessages(chatId, limit: limit).listen(
      (messages) {
        _messages = messages;
        _hasMore = messages.length >= limit;
        emit(MessagesLoaded(messages: messages, hasMore: _hasMore));
      },
      onError: (error) {
        emit(MessageError(message: error.toString()));
      },
    );
  }

  void refreshMessages(String chatId) {
    loadMessages(chatId);
  }

  @override
  Future<void> close() {
    _chatService.dispose();
    return super.close();
  }
}
