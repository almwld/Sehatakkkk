// ============================================================
// 📱 ChatDetailScreen - شاشة تفاصيل المحادثة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../bloc/messages/messages_bloc.dart';
import '../../../bloc/messages/messages_event.dart';
import '../../../bloc/messages/messages_state.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../core/models/message_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
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
  final AuthService _authService = AuthService();
  String? _replyToId;

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
    context.read<MessagesBloc>().add(StreamMessages(chatId: widget.chatId));
    context.read<ChatBloc>().add(LoadChat(chatId: widget.chatId));
  }

  @override
  void dispose() {
    context.read<MessagesBloc>().add(StopStreamingMessages());
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessagesBloc, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesError) {
                  return _buildErrorState(state.message);
                }
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == _authService.currentUserId;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        onReply: () {
                          _replyToId = message.id;
                          _textController.requestFocus();
                        },
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
            onImagePick: _pickImage,
            onVoiceRecord: _startVoiceRecording,
            replyToId: _replyToId,
            onCancelReply: () => setState(() => _replyToId = null),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatDetailLoaded) {
            final chat = state.chat;
            final currentUserId = _authService.currentUserId;
            final name = chat.getDisplayName(currentUserId ?? '');
            final photo = chat.getDisplayPhoto(currentUserId ?? '');
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: photo.isNotEmpty
                      ? CachedNetworkImageProvider(photo)
                      : null,
                  child: photo.isEmpty ? Text(name[0]) : null,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(name)),
              ],
            );
          }
          return const Text('المحادثة');
        },
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {},
        ),
      ],
    );
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;
    context.read<MessagesBloc>().add(
      SendMessage(
        chatId: widget.chatId,
        text: text,
        replyToId: _replyToId,
      ),
    );
    _textController.clear();
    setState(() => _replyToId = null);
  }

  void _pickImage() {}

  void _startVoiceRecording() {}

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد رسائل', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('ابدأ المحادثة الآن', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
