// ============================================================
// 📱 ChatDetailScreen - شاشة تفاصيل المحادثة الكاملة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/message_model.dart';
import '../../../bloc/messages/messages_bloc.dart';
import '../../../bloc/messages/messages_event.dart';
import '../../../bloc/messages/messages_state.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدردشة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId ==
                          FirebaseAuth.instance.currentUser?.uid;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          ChatInputBar(
            textController: _textController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;
    context.read<MessagesBloc>().add(
      SendMessage(
        chatId: widget.chatId,
        text: text,
      ),
    );
    _textController.clear();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد رسائل'),
          SizedBox(height: 8),
          Text('ابدأ المحادثة', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
