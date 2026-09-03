import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/message_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../bloc/messages/messages_bloc.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('الدردشة'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessagesBloc, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesError) {
                  return Center(child: Text(state.message));
                }
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(child: Text('لا توجد رسائل'));
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
                      return MessageBubble(message: message, isMe: isMe);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          ChatInputBar(
            textController: _textController,
            onSend: (text) {
              context.read<MessagesBloc>().add(
                SendMessage(chatId: widget.chatId, text: text),
              );
              _textController.clear();
            },
            onImagePick: () {},
            onVoiceRecord: () {},
            onFilePick: () {},
            onLocationShare: () {},
            isSending: false,
          ),
        ],
      ),
    );
  }
}
