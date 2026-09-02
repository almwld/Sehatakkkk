// ============================================================
// 📱 ChatScreen - شاشة قائمة المحادثات
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import 'widgets/chat_shimmer.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChats());
    context.read<ChatBloc>().add(StreamChats());
  }

  @override
  void dispose() {
    context.read<ChatBloc>().add(StopStreamingChats());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const ChatShimmer();
          }

          if (state is ChatError) {
            return _buildErrorState(state.message);
          }

          if (state is ChatLoaded) {
            if (state.chats.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return _buildChatTile(chat);
              },
            );
          }

          return const Center(child: Text('بدء الدردشة'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    final currentUserId = _authService.currentUserId;
    final displayName = chat.getDisplayName(currentUserId ?? '');
    final displayPhoto = chat.getDisplayPhoto(currentUserId ?? '');
    final unreadCount = chat.getTotalUnreadCount();
    final lastMessage = chat.lastMessage ?? 'بدء المحادثة';
    final lastMessageTime = chat.lastMessageTime?.toDate();

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: displayPhoto.isNotEmpty
            ? CachedNetworkImageProvider(displayPhoto)
            : null,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: displayPhoto.isEmpty
            ? Text(
                displayName.isNotEmpty ? displayName[0] : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessageTime != null)
            Text(
              _formatTime(lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              lastMessage,
              style: TextStyle(
                fontSize: 14,
                color: unreadCount > 0 ? Colors.black : Colors.grey[600],
                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chatId: chat.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'لا توجد محادثات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيب',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.medical_services),
            label: const Text('بحث عن طبيب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ChatBloc>().add(LoadChats()),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 7) return '${time.day}/${time.month}/${time.year}';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}

// ✅ إضافة imports
import 'search_screen.dart';
import 'chat_settings_screen.dart';
import '../../screens/doctor/doctors_list_screen.dart';

// ✅ تعديل AppBar - ربط زر البحث
IconButton(
  icon: const Icon(Icons.search),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  },
),

// ✅ تعديل AppBar - ربط زر القائمة
IconButton(
  icon: const Icon(Icons.more_vert),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatSettingsScreen()),
    );
  },
),

// ✅ تعديل FAB - ربط زر المحادثة الجديدة
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorsListScreen()),
    );
  },
  backgroundColor: AppColors.primary,
  child: const Icon(Icons.chat, color: Colors.white),
),
