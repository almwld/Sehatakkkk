import '../../core/models/chat_model.dart';
import '../../core/models/message_model.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  sending,
  refreshing,
  failure,
}

class ChatState {
  final ChatStatus status;

  final List<ChatModel> chats;
  final List<MessageModel> messages;

  final ChatModel? activeChat;
  final String? activeChatId;

  final String? errorMessage;
  final String? actionError;

  final bool isSending;
  final bool isLoadingMessages;
  final bool isCreatingChat;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const [],
    this.messages = const [],
    this.activeChat,
    this.activeChatId,
    this.errorMessage,
    this.actionError,
    this.isSending = false,
    this.isLoadingMessages = false,
    this.isCreatingChat = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatModel>? chats,
    List<MessageModel>? messages,
    ChatModel? activeChat,
    String? activeChatId,
    String? errorMessage,
    String? actionError,
    bool clearError = false,
    bool clearActionError = false,
    bool? isSending,
    bool? isLoadingMessages,
    bool? isCreatingChat,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      activeChat: activeChat ?? this.activeChat,
      activeChatId: activeChatId ?? this.activeChatId,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
      actionError: clearActionError
          ? null
          : actionError ?? this.actionError,
      isSending: isSending ?? this.isSending,
      isLoadingMessages:
          isLoadingMessages ?? this.isLoadingMessages,
      isCreatingChat:
          isCreatingChat ?? this.isCreatingChat,
    );
  }
}
