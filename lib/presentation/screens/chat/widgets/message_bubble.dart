// ============================================================
// 📱 MessageBubble - فقاعة الرسالة
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/message_model.dart';
import '../../../core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showOptions(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12).copyWith(
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                    bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _buildContent(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead ? AppColors.primary : Colors.grey,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (message.isDeletedMessage) {
      return const Text(
        'تم حذف هذه الرسالة',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    if (message.isImage && message.attachments?['imageUrl'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.attachments!['imageUrl'],
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    if (message.isAudio) {
      return _buildAudioWidget();
    }

    return Text(
      message.text ?? '',
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black,
        fontSize: 15,
      ),
    );
  }

  Widget _buildAudioWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.black),
          onPressed: () {},
        ),
        Container(
          width: 100,
          height: 4,
          color: isMe ? Colors.white.withOpacity(0.3) : Colors.grey[300],
          child: Container(
            width: 50,
            height: 4,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '0:30',
          style: TextStyle(color: isMe ? Colors.white70 : Colors.grey[600]),
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('رد على الرسالة'),
                onTap: () {
                  Navigator.pop(context);
                  onReply?.call();
                },
              ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('حذف الرسالة', style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}
