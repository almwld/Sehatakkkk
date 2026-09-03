// ============================================================
// 💬 MessageBubble - فقاعة الرسالة المتكاملة
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/entities/message_entity.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final Function(String)? onReaction;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
    this.onReaction,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showFullImage = false;

  @override
  Widget build(BuildContext context) {
    if (widget.message.isDeleted) {
      return _buildDeletedMessage();
    }

    return GestureDetector(
      onLongPress: _showMessageOptions,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isMe)
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  widget.message.senderName.isNotEmpty ? widget.message.senderName[0] : 'م',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // ✅ رسالة الرد
                  if (widget.message.replyToId != null)
                    _buildReplyBanner(),
                  // ✅ محتوى الرسالة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isMe ? AppColors.primary : (widget.isMe ? null : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(12),
                        bottomLeft: widget.isMe ? const Radius.circular(12) : const Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // ✅ اسم المرسل
                        if (!widget.isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              widget.message.senderName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // ✅ صورة
                        if (widget.message.isImage && widget.message.attachments?['imageUrl'] != null)
                          _buildImageWidget(),
                        // ✅ فيديو
                        if (widget.message.isVideo)
                          _buildVideoWidget(),
                        // ✅ صوت
                        if (widget.message.isAudio)
                          _buildAudioWidget(),
                        // ✅ موقع
                        if (widget.message.isLocation)
                          _buildLocationWidget(),
                        // ✅ ملف
                        if (widget.message.isFile)
                          _buildFileWidget(),
                        // ✅ نص
                        if (widget.message.isText || (widget.message.isImage && widget.message.text != null))
                          Text(
                            widget.message.text ?? '',
                            style: TextStyle(
                              color: widget.isMe ? Colors.white : (widget.isMe ? null : Colors.black87),
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // ✅ الوقت والحالة
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(widget.message.timestamp),
                              style: TextStyle(
                                fontSize: 9,
                                color: widget.isMe ? Colors.white70 : Colors.grey[500],
                              ),
                            ),
                            if (widget.isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                widget.message.isRead ? Icons.done_all : Icons.done,
                                size: 12,
                                color: widget.message.isRead ? Colors.blue : Colors.white70,
                              ),
                            ],
                            if (widget.message.hasReactions) ...[
                              const SizedBox(width: 4),
                              ...widget.message.reactions!.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Text(
                                    '${entry.key}${entry.value}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 Widgets فرعية
  // ============================================================

  Widget _buildDeletedMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🗑️ تم حذف هذه الرسالة',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.reply, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.message.replyTo?.text ?? 'رسالة سابقة',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    final imageUrl = widget.message.attachments!['imageUrl'] as String;
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoWidget() {
    return Container(
      width: 200,
      height: 150,
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.play_circle_filled, color: Colors.white, size: 50),
      ),
    );
  }

  Widget _buildAudioWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.audiotrack, color: widget.isMe ? Colors.white : Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(widget.message.audioDuration ?? 0) ~/ 60}:${((widget.message.audioDuration ?? 0) % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 10,
              color: widget.isMe ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.message.locationAddress ?? 'موقع',
              style: TextStyle(
                fontSize: 12,
                color: widget.isMe ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'ملف',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isMe ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.message.fileSize ?? '0 KB',
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ ردود فعل سريعة
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['👍', '❤️', '😂', '😮', '😢', '🙏'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onReaction?.call(emoji);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            // ✅ رد على الرسالة
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.primary),
              title: const Text('رد على الرسالة'),
              onTap: () {
                Navigator.pop(context);
                widget.onReply?.call();
              },
            ),
            // ✅ نسخ النص
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primary),
              title: const Text('نسخ النص'),
              onTap: () {
                Navigator.pop(context);
                // TODO: نسخ النص
              },
            ),
            // ✅ حذف الرسالة
            if (widget.isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الرسالة', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}
