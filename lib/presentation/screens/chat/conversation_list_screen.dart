import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chatService.enableOffline();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ConversationSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(
            child: StreamBuilder<List<ChatConversation>>(
              stream: _chatService.getConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text('حدث خطأ: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final conversations = snapshot.data ?? [];
                if (conversations.isEmpty) {
                  return _buildEmptyState();
                }

                final filtered = _searchQuery.isEmpty
                    ? conversations
                    : conversations.where((conv) =>
                        conv.otherParticipantName
                            ?.toLowerCase()
                            .contains(_searchQuery.toLowerCase()) == true ||
                        conv.lastMessage
                            ?.toLowerCase()
                            .contains(_searchQuery.toLowerCase()) == true)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text('لا توجد نتائج لـ "$_searchQuery"', style: const TextStyle(color: AppColors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conversation = filtered[index];
                    return _buildConversationTile(conversation, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // فتح شاشة بدء محادثة جديدة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔍 ابحث عن طبيب لبدء محادثة'),
              backgroundColor: AppColors.info,
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن محادثة...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation, bool isDark) {
    final isUnread = (conversation.unreadCount[FirebaseAuth.instance.currentUser?.uid ?? ''] ?? 0) > 0;
    final lastMessage = conversation.lastMessage ?? 'ابدأ المحادثة';
    final lastTime = conversation.lastMessageTime;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.id,
              receiverId: conversation.otherParticipantId,
              receiverName: conversation.otherParticipantName,
              receiverPhoto: conversation.otherParticipantPhoto,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ صورة المستخدم
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: conversation.otherParticipantPhoto != null
                        ? DecorationImage(
                            image: NetworkImage(conversation.otherParticipantPhoto!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: conversation.otherParticipantPhoto == null
                      ? Center(
                          child: Text(
                            conversation.otherParticipantName?.isNotEmpty == true
                                ? conversation.otherParticipantName![0]
                                : 'م',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : null,
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ معلومات المحادثة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherParticipantName ?? 'مستخدم',
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastTime != null)
                        Text(
                          _formatTime(lastTime),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.lastSenderId == FirebaseAuth.instance.currentUser?.uid)
                        const Icon(Icons.done_all_rounded, size: 14, color: AppColors.grey),
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread ? AppColors.primary : AppColors.grey,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount[FirebaseAuth.instance.currentUser?.uid ?? '']}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد محادثات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔍 ابحث عن طبيب لبدء محادثة'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('بحث عن طبيب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes} د';
    if (diff.inDays < 1) return '${diff.inHours} س';
    if (diff.inDays < 7) return '${diff.inDays} ي';
    return DateFormat('dd/MM').format(time);
  }
}

// ✅ بحث متقدم
class ConversationSearchDelegate extends SearchDelegate {
  final ChatService _chatService = ChatService();

  @override
  String get searchFieldLabel => 'ابحث عن محادثة...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<ChatConversation>>(
      stream: _chatService.getConversations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = snapshot.data ?? [];
        final results = conversations.where((conv) =>
            conv.otherParticipantName
                ?.toLowerCase()
                .contains(query.toLowerCase()) == true ||
            conv.lastMessage
                ?.toLowerCase()
                .contains(query.toLowerCase()) == true)
            .toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: AppColors.grey),
                const SizedBox(height: 16),
                Text('لا توجد نتائج لـ "$query"', style: const TextStyle(color: AppColors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final conversation = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  conversation.otherParticipantName?.isNotEmpty == true
                      ? conversation.otherParticipantName![0]
                      : 'م',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              title: Text(conversation.otherParticipantName ?? 'مستخدم'),
              subtitle: Text(conversation.lastMessage ?? 'ابدأ المحادثة'),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: conversation.id,
                      receiverId: conversation.otherParticipantId,
                      receiverName: conversation.otherParticipantName,
                      receiverPhoto: conversation.otherParticipantPhoto,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
