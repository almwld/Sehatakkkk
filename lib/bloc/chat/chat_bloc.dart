import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/chat_model.dart';
import '../../core/models/message_model.dart';
import '../../core/services/chat_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    ChatService? chatService,
  })  : _chatService =
            chatService ?? ChatService.instance,
        super(const ChatState()) {
    on<LoadChats>(_onLoadChats);
    on<RefreshChats>(_onRefreshChats);
    on<CreateChat>(_onCreateChat);
    on<OpenChat>(_onOpenChat);
    on<LoadMessages>(_onLoadMessages);
    on<SendChatMessage>(_onSendMessage);
    on<MarkChatAsRead>(_onMarkAsRead);
    on<DeleteChat>(_onDeleteChat);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<ChatsUpdated>(_onChatsUpdated);
  }

  final ChatService _chatService;

  StreamSubscription<List<MessageModel>>?
      _messagesSubscription;

  StreamSubscription<List<ChatModel>>?
      _chatsSubscription;

  Future<void> _onLoadChats(
    LoadChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        status: state.chats.isEmpty
            ? ChatStatus.loading
            : ChatStatus.refreshing,
        clearError: true,
      ),
    );

    try {
      final chats = await _chatService.getChats();

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          chats: chats,
          clearError: true,
        ),
      );

      await _startChatsStream();
    } on ChatException catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: 'تعذر تحميل المحادثات',
        ),
      );
    }
  }

  Future<void> _onRefreshChats(
    RefreshChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final chats = await _chatService.getChats();

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          chats: chats,
          clearError: true,
        ),
      );
    } on ChatException catch (error) {
      emit(
        state.copyWith(
          actionError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionError: 'تعذر تحديث المحادثات',
        ),
      );
    }
  }

  Future<void> _onOpenChat(
    OpenChat event,
    Emitter<ChatState> emit,
  ) async {
    final chatId = event.chatId.trim();

    if (chatId.isEmpty) {
      emit(
        state.copyWith(
          actionError: 'معرّف المحادثة غير صالح',
        ),
      );
      return;
    }

    ChatModel? chat;

    for (final item in state.chats) {
      if (item.id == chatId) {
        chat = item;
        break;
      }
    }

    emit(
      state.copyWith(
        activeChat: chat,
        activeChatId: chatId,
        messages: const [],
        isLoadingMessages: true,
        clearActionError: true,
      ),
    );

    add(LoadMessages(chatId));
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();

    emit(
      state.copyWith(
        isLoadingMessages: true,
        clearActionError: true,
      ),
    );

    try {
      final messages =
          await _chatService.getMessages(event.chatId);

      emit(
        state.copyWith(
          messages: messages,
          isLoadingMessages: false,
          clearActionError: true,
        ),
      );

      await _chatService.markAsRead(event.chatId);

      _messagesSubscription = _chatService
          .watchMessages(event.chatId)
          .listen(
            (messages) {
              add(MessagesUpdated(messages));
            },
            onError: (_) {},
          );
    } on ChatException catch (error) {
      emit(
        state.copyWith(
          isLoadingMessages: false,
          actionError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMessages: false,
          actionError: 'تعذر تحميل الرسائل',
        ),
      );
    }
  }

  Future<void> _onSendMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();

    if (event.chatId.trim().isEmpty || text.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        isSending: true,
        clearActionError: true,
      ),
    );

    try {
      final message = await _chatService.sendMessage(
        chatId: event.chatId,
        text: text,
        type: event.type,
      );

      final messages = [
        ...state.messages,
        message,
      ];

      emit(
        state.copyWith(
          messages: messages,
          isSending: false,
          clearActionError: true,
        ),
      );
    } on ChatException catch (error) {
      emit(
        state.copyWith(
          isSending: false,
          actionError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSending: false,
          actionError: 'تعذر إرسال الرسالة',
        ),
      );
    }
  }

  Future<void> _onMarkAsRead(
    MarkChatAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.markAsRead(event.chatId);
    } catch (_) {}
  }

  Future<void> _onDeleteChat(
    DeleteChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatService.deleteChat(event.chatId);

      final chats = state.chats
          .where((chat) => chat.id != event.chatId)
          .toList();

      emit(
        state.copyWith(
          chats: chats,
          activeChatId:
              state.activeChatId == event.chatId
                  ? null
                  : state.activeChatId,
          messages:
              state.activeChatId == event.chatId
                  ? const []
                  : state.messages,
          clearActionError: true,
        ),
      );
    } on ChatException catch (error) {
      emit(
        state.copyWith(
          actionError: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionError: 'تعذر حذف المحادثة',
        ),
      );
    }
  }

  void _onMessagesUpdated(
    MessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        messages: event.messages,
        isLoadingMessages: false,
      ),
    );
  }

  void _onChatsUpdated(
    ChatsUpdated event,
    Emitter<ChatState> emit,
  ) {
    final chats = event.chats
        .whereType<ChatModel>()
        .toList();

    emit(
      state.copyWith(
        chats: chats,
        status: ChatStatus.loaded,
      ),
    );
  }

  Future<void> _startChatsStream() async {
    await _chatsSubscription?.cancel();

    _chatsSubscription = _chatService
        .watchChats()
        .listen(
          (chats) {
            add(ChatsUpdated(chats));
          },
          onError: (_) {},
        );
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    await _chatsSubscription?.cancel();
    return super.close();
  }
}
