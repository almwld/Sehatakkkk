import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/message_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/chat_service.dart';
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
  final ChatService _chatService = ChatService();
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId, limit: 30));
    
    // ✅ استماع للتمرير لتحميل المزيد
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;
    if (context.read<MessagesBloc>().state is! MessagesLoaded) return;

    final state = context.read<MessagesBloc>().state as MessagesLoaded;
    if (!state.hasMore) return;
    if (state.messages.isEmpty) return;

    _isLoadingMore = true;
    final lastMessage = state.messages.last;
    
    // ✅ الحصول على DocumentSnapshot للرسالة الأخيرة
    final doc = await _chatService._firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(lastMessage.id)
        .get();
    
    if (doc.exists) {
      context.read<MessagesBloc>().add(
        LoadMoreMessages(
          chatId: widget.chatId,
          limit: 30,
          startAfter: doc,
        ),
      );
    }
    _isLoadingMore = false;
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
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
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
