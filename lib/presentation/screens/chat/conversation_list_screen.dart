import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/widgets/app_search_delegate.dart';
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
      appBar: CustomAppBar(
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
          ToastService.showError(context, '🔍 ابحث عن طبيب لبدء محادثة');
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
