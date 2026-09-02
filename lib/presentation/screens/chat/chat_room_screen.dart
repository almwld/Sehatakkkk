import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import 'chat_detail_screen.dart';

class ChatRoomScreen extends StatelessWidget {
  final String chatId;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc()
        ..add(OpenChat(chatId)),
      child: ChatDetailScreen(
        chatId: chatId,
      ),
    );
  }
}
