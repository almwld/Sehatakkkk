import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/entities/message_entity.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
    context.read<MessagesBloc>().add(MarkMessagesRead(chatId: widget.chatId));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('الدردشة'),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MessagesBloc>().add(
                              LoadMessages(chatId: widget.chatId),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MessagesLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return _buildEmptyState(isDark);
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
            onSend: (text) {
              if (text.trim().isNotEmpty) {
                context.read<MessagesBloc>().add(
                  SendMessage(
                    chatId: widget.chatId,
                    text: text.trim(),
                  ),
                );
                _textController.clear();
              }
            },
            onImagePick: () {
              // فتح منتقي الصور
            },
            onVoiceRecord: () {
              // بدء التسجيل الصوتي
            },
            onFilePick: () {
              // فتح منتقي الملفات
            },
            onLocationShare: () {
              // مشاركة الموقع
            },
            isSending: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ المحادثة الآن',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
