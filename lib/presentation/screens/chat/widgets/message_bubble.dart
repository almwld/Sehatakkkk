import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'full_screen_image.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final String type;
  final String? mediaUrl;
  final bool isMe;
  final String time;
  final bool isRead;
  final String? senderName;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.text,
    required this.type,
    this.mediaUrl,
    required this.isMe,
    required this.time,
    this.isRead = false,
    this.senderName,
    this.onLongPress,
    this.onReply,
    this.onDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = widget.isMe
        ? const Color(0xFF00796B)
        : (isDark ? const Color(0xFF2D3A54) : Colors.grey[200]!);

    final textColor = widget.isMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return GestureDetector(
      onLongPress: _showOptions,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isMe)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 6),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    // ✅ محتوى الرسالة حسب النوع
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
                          child: CachedNetworkImage(
                            imageUrl: widget.mediaUrl!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
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
                    if (widget.type == 'audio')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: widget.isMe ? Colors.white : AppColors.primary,
                              size: 32,
                            ),
                            onPressed: () => setState(() => _isPlaying = !_isPlaying),
                          ),
                          Text(
                            '🎵 رسالة صوتية',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.type == 'text' && widget.text.isNotEmpty)
                _optionTile(Icons.content_copy_rounded, 'نسخ', () {
                  Navigator.pop(context);
                }),
              if (widget.type == 'image')
                _optionTile(Icons.save_alt_rounded, 'حفظ الصورة', () {
                  Navigator.pop(context);
                }),
              if (widget.type == 'audio')
                _optionTile(Icons.download_rounded, 'تحميل الصوت', () {
                  Navigator.pop(context);
                }),
              _optionTile(Icons.reply_rounded, 'رد', () {
                Navigator.pop(context);
                if (widget.onReply != null) widget.onReply!();
              }),
              if (widget.isMe)
                _optionTile(Icons.delete_rounded, 'حذف', () {
                  Navigator.pop(context);
                  if (widget.onDelete != null) widget.onDelete!();
                }, isDanger: true),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? AppColors.error : AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? AppColors.error : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
