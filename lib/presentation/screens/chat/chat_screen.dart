import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/entities/chat_entity.dart';
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ChatBloc>().add(RefreshChats()),
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

          if (state is ChatLoaded) {
            final chats = state.chats;
            if (chats.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(RefreshChats());
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return _buildChatTile(chat, isDark);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // الانتقال إلى شاشة الأطباء
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // ============================================================
  // 📋 بناء عنصر المحادثة
  // ============================================================
  Widget _buildChatTile(ChatEntity chat, bool isDark) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = chat.getDisplayName(userId);
    final photo = chat.getDisplayPhoto(userId);
    final unread = chat.getUnreadCount(userId);
    final lastMessage = chat.lastMessage ?? 'ابدأ المحادثة';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chatId: chat.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // صورة المستخدم
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: photo.isNotEmpty
                      ? CachedNetworkImageProvider(photo)
                      : null,
                  child: photo.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'م',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // نقطة الحالة (Online)
                if (chat.participantDetails.values.any((p) => p.isOnline == true))
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // محتوى المحادثة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: unread > 0
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // عدد الرسائل غير المقروءة
            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📋 الحالة الفارغة
  // ============================================================
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد محادثات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // الانتقال إلى شاشة الأطباء
            },
            icon: const Icon(Icons.medical_services),
            label: const Text('بحث عن طبيب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
