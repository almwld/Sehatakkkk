import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/chat/chat_event.dart';
import 'package:sehatak/bloc/chat/chat_state.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';
import 'dart:async';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService = ChatService();

  List<ChatModel> _allChats = [];
  List<MessageModel> _messages = [];
  String? _currentChatId;
  StreamSubscription? _chatSubscription;
  StreamSubscription? _messageSubscription;

  ChatBloc() : super(ChatInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<RefreshChatsEvent>(_onRefreshChats);
    on<GetChatEvent>(_onGetChat);
    on<CreateChatEvent>(_onCreateChat);
    on<DeleteChatEvent>(_onDeleteChat);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<AddReactionEvent>(_onAddReaction);
    on<RemoveReactionEvent>(_onRemoveReaction);
    on<SearchMessagesEvent>(_onSearchMessages);
    on<SearchChatsEvent>(_onSearchChats);
    on<MarkAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onLoadChats(
    LoadChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());

    _chatSubscription?.cancel();
    _chatSubscription = _chatService.getChats().listen(
      (chats) {
        _allChats = chats;
        final unreadCount = _getTotalUnread(chats);
        emit(ChatsLoadedState(chats: chats, unreadCount: unreadCount));
      },
      onError: (error) {
        emit(ChatErrorState(message: error.toString()));
      },
    );
  }

  Future<void> _onRefreshChats(
    RefreshChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatRefreshingState());
    await _onLoadChats(LoadChatsEvent(), emit);
    ToastService.showSuccess('✅ تم تحديث المحادثات');
  }

  Future<void> _onGetChat(
    GetChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());

    try {
      final chat = await _chatService.getChatOnce(event.chatId);
      if (chat != null) {
        _currentChatId = event.chatId;
        emit(ChatLoadedState(chat: chat));
        _loadMessages(event.chatId, emit);
      } else {
        emit(ChatErrorState(message: 'المحادثة غير موجودة'));
      }
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  void _loadMessages(String chatId, Emitter<ChatState> emit) {
    _messageSubscription?.cancel();
    _messageSubscription = _chatService.getMessages(chatId).listen(
      (messages) {
        _messages = messages;
        emit(MessagesLoadedState(messages: messages, chatId: chatId));
      },
      onError: (error) {
        emit(ChatErrorState(message: error.toString()));
      },
    );
  }

  Future<void> _onCreateChat(
    CreateChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final chatId = await _chatService.createChat(
        doctorId: event.doctorId,
        doctorName: event.doctorName,
        patientId: event.patientId,
        patientName: event.patientName,
        doctorImage: event.doctorImage,
        patientImage: event.patientImage,
        isGroup: event.isGroup,
        groupName: event.groupName,
        groupImage: event.groupImage,
      );

      emit(ChatCreatedState(chatId: chatId));
      ToastService.showSuccess('✅ تم إنشاء المحادثة');
      add(LoadChatsEvent());
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
      ToastService.showError('❌ فشل إنشاء المحادثة: $e');
    }
  }

  Future<void> _onDeleteChat(
    DeleteChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.deleteChat(event.chatId);
      ToastService.showSuccess('✅ تم حذف المحادثة');
      add(LoadChatsEvent());
    } catch (e) {
      ToastService.showError('❌ فشل حذف المحادثة: $e');
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = await _chatService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
        fileUrl: event.fileUrl,
        locationUrl: event.locationUrl,
        replyTo: event.replyTo,
        replyToText: event.replyToText,
      );

      emit(MessageSentState(message: message));
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.deleteMessage(
        chatId: event.chatId,
        messageId: event.messageId,
      );

      emit(MessageDeletedState(messageId: event.messageId));
      ToastService.showSuccess('✅ تم حذف الرسالة');
    } catch (e) {
      ToastService.showError('❌ فشل حذف الرسالة: $e');
    }
  }

  Future<void> _onAddReaction(
    AddReactionEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.addReaction(
        chatId: event.chatId,
        messageId: event.messageId,
        emoji: event.emoji,
      );
      emit(ReactionAddedState(
        messageId: event.messageId,
        emoji: event.emoji,
      ));
    } catch (e) {
      ToastService.showError('❌ فشل إضافة التفاعل: $e');
    }
  }

  Future<void> _onRemoveReaction(
    RemoveReactionEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.removeReaction(
        chatId: event.chatId,
        messageId: event.messageId,
        emoji: event.emoji,
      );
      emit(ReactionRemovedState(
        messageId: event.messageId,
        emoji: event.emoji,
      ));
    } catch (e) {
      ToastService.showError('❌ فشل إزالة التفاعل: $e');
    }
  }

  Future<void> _onSearchMessages(
    SearchMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final results = await _chatService.searchMessages(
        chatId: event.chatId,
        query: event.query,
      );
      emit(MessagesSearchedState(
        messages: results,
        query: event.query,
      ));
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onSearchChats(
    SearchChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final results = await _chatService.searchChats(event.query);
      emit(ChatsSearchedState(
        chats: results,
        query: event.query,
      ));
    } catch (e) {
      emit(ChatErrorState(message: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.markAsRead(event.chatId);
    } catch (e) {
      print('❌ Mark as read error: $e');
    }
  }

  int _getTotalUnread(List<ChatModel> chats) {
    int total = 0;
    // TODO: حساب عدد الرسائل غير المقروءة
    return total;
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    _chatService.dispose();
    return super.close();
  }
}
