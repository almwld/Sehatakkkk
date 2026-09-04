import '../../../core/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../bloc/chat/chat_bloc.dart';
import 'widgets/chat_shimmer.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChats());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => context.read<ChatBloc>().add(RefreshChats()),
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const ChatShimmer();
          }
          if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          if (state is ChatLoaded) {
            if (state.chats.isEmpty) {
              return _buildEmptyState(isDark);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return _buildChatTile(chat, isDark);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat, bool isDark) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = chat.getDisplayName(userId);
    final photo = chat.getDisplayPhoto(userId);
    final unread = chat.getTotalUnreadCount();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
        child: photo.isEmpty ? Text(name.isNotEmpty ? name[0] : 'م') : null,
      ),
      title: Text(name),
      subtitle: Text(chat.lastMessage ?? 'ابدأ المحادثة'),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unread',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chatId: chat.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد محادثات', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}
