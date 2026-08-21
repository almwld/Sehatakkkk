import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/reaction_service.dart';
import 'full_screen_image.dart';

class MessageBubble extends StatefulWidget {
  final String chatId;
  final String messageId;
  final String text;
  final String type;
  final String? mediaUrl;
  final bool isMe;
  final String time;
  final bool isRead;
  final String? senderName;
  final List<String> reactions;
  final Map<String, int> reactionCounts;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.chatId,
    required this.messageId,
    required this.text,
    required this.type,
    this.mediaUrl,
    required this.isMe,
    required this.time,
    this.isRead = false,
    this.senderName,
    this.reactions = const [],
    this.reactionCounts = const {},
    this.onReply,
    this.onDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final ReactionService _reactionService = ReactionService();
  bool _showReactions = false;
  String? _userReaction;

  // ✅ قائمة الإيموجي المتاحة للتفاعل
  final List<String> _availableReactions = ReactionService.availableReactions;

  @override
  void initState() {
    super.initState();
    _loadUserReaction();
  }

  Future<void> _loadUserReaction() async {
    final reaction = await _reactionService.getUserReaction(
      chatId: widget.chatId,
      messageId: widget.messageId,
    );
    if (mounted) {
      setState(() => _userReaction = reaction);
    }
  }

  // ✅ إضافة/إزالة رد فعل
  Future<void> _toggleReaction(String emoji) async {
    try {
      await _reactionService.toggleReaction(
        chatId: widget.chatId,
        messageId: widget.messageId,
        emoji: emoji,
      );
      await _loadUserReaction();
    } catch (e) {
      print('❌ Error toggling reaction: $e');
    }
  }

  // ✅ عرض قائمة ردود الفعل
  void _showReactionPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر رد فعل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableReactions.map((emoji) {
                final isSelected = _userReaction == emoji;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _toggleReaction(emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 32 : 28,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ✅ عرض ردود الفعل الموجودة
  Widget _buildReactionsDisplay() {
    if (widget.reactions.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _showReactionPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ عرض الإيموجيات مع الأعداد
            ...widget.reactionCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (entry.value > 1)
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            // ✅ زر إضافة رد فعل
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = widget.isMe
        ? AppColors.primary
        : (isDark ? const Color(0xFF2D3A54) : Colors.grey[200]!);

    final textColor = widget.isMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Column(
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // ✅ فقاعة الرسالة
        Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isMe)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.senderName?.isNotEmpty == true
                        ? widget.senderName![0]
                        : 'ط',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // ✅ فقاعة الرسالة
                  GestureDetector(
                    onLongPress: _showReactionPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: widget.isMe
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                          bottomRight: widget.isMe
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ اسم المرسل
                          if (!widget.isMe && widget.senderName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                widget.senderName!,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          // ✅ محتوى الرسالة
                          if (widget.type == 'text')
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          if (widget.type == 'image' && widget.mediaUrl != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImage(
                                      imageUrl: widget.mediaUrl!,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.mediaUrl!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // ✅ الوقت وحالة القراءة
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.time,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: widget.isMe ? Colors.white70 : AppColors.grey,
                                ),
                              ),
                              if (widget.isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  widget.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                                  size: 12,
                                  color: widget.isRead ? AppColors.success : Colors.white70,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ✅ ردود الفعل (تظهر أسفل الفقاعة)
                  if (widget.reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: _buildReactionsDisplay(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
