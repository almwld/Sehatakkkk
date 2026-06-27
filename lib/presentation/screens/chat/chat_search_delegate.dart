import 'package:flutter/material.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';

class ChatSearchDelegate extends SearchDelegate {
  final String conversationId;
  final ChatService _chatService = ChatService();

  ChatSearchDelegate(this.conversationId);

  @override
  String get searchFieldLabel => 'ابحث في المحادثة...';

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
    if (query.isEmpty) {
      return const Center(
        child: Text('ابحث عن رسالة في المحادثة', style: TextStyle(color: AppColors.grey)),
      );
    }

    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessages(conversationId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];
        final results = messages.where((msg) =>
            msg.content.toLowerCase().contains(query.toLowerCase()) &&
            !msg.isDeleted).toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: AppColors.grey),
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
            final msg = results[index];
            return ListTile(
              leading: const Icon(Icons.message, color: AppColors.primary),
              title: Text(msg.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                msg.senderName,
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
              onTap: () {
                close(context, null);
                // التمرير إلى الرسالة
              },
            );
          },
        );
      },
    );
  }
}
