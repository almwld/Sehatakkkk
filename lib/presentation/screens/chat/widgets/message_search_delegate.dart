import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/text_styles.dart';

class MessageSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> messages;
  final Function(String) onMessageSelected;

  MessageSearchDelegate({
    required this.messages,
    required this.onMessageSelected,
  });

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
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults(context);
  }

  Widget _buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'ابحث في الرسائل',
              style: TextStyles.body2.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final results = messages.where((msg) {
      final text = (msg['text'] as String? ?? '').toLowerCase();
      return text.contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج لـ "$query"',
              style: TextStyles.headline6.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final msg = results[index];
        final text = msg['text'] as String? ?? '';
        final sender = msg['senderName'] as String? ?? 'مستخدم';
        final time = msg['timestamp'] as Timestamp?;
        final dateTime = time?.toDate() ?? DateTime.now();

        // ✅ تمييز الكلمة المبحوث عنها
        final highlightedText = _highlightText(text, query);

        return GestureDetector(
          onTap: () {
            close(context, null);
            onMessageSelected(msg['id'] as String);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        sender.isNotEmpty ? sender[0] : 'م',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sender,
                      style: TextStyles.subtitle2,
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(dateTime),
                      style: TextStyles.body4.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: highlightedText,
                    style: TextStyles.body2.copyWith(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TextSpan> _highlightText(String text, String query) {
    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + query.length;
    }

    return spans;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${time.day}/${time.month}';
  }
}
