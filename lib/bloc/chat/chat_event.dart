import '../../core/models/message_model.dart';

abstract class ChatEvent {
  const ChatEvent();
}

class LoadChats extends ChatEvent {
  const LoadChats();
}

class RefreshChats extends ChatEvent {
  const RefreshChats();
}

class CreateChat extends ChatEvent {
  final String doctorId;

  const CreateChat({
    required this.doctorId,
  });
}

class OpenChat extends ChatEvent {
  final String chatId;

  const OpenChat(this.chatId);
}

class LoadMessages extends ChatEvent {
  final String chatId;

  const LoadMessages(this.chatId);
}

class SendChatMessage extends ChatEvent {
  final String chatId;
  final String text;
  final String type;

  const SendChatMessage({
    required this.chatId,
    required this.text,
    this.type = 'text',
  });
}

class MarkChatAsRead extends ChatEvent {
  final String chatId;

  const MarkChatAsRead(this.chatId);
}

class DeleteChat extends ChatEvent {
  final String chatId;

  const DeleteChat(this.chatId);
}

class MessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;

  const MessagesUpdated(this.messages);
}

class ChatsUpdated extends ChatEvent {
  final List<dynamic> chats;

  const ChatsUpdated(this.chats);
}
