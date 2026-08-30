import 'package:sehatak/models/reaction_model.dart';
// ============================================================
// 💬 فقاعة الرسالة - مع دعم الوسائط
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/message_model.dart';
import 'package:sehatak/presentation/screens/chat/widgets/full_screen_image.dart';
import 'package:video_player/video_player.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final String chatId;
  final bool isMe;
  final bool isDark;
  final Function(MessageModel) onReply;
  final Function(MessageModel) onReaction;
  final Function(MessageModel) onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.chatId,
    required this.isMe,
    required this.isDark,
    required this.onReply,
    required this.onReaction,
    required this.onDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.isVideo && widget.message.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.network(widget.message.videoUrl!);
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('❌ Video init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isDeleted) {
      return _buildDeletedMessage();
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // ✅ رسالة الرد
                  if (widget.message.replyTo != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.reply, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.message.replyToText ?? 'رسالة سابقة',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ✅ محتوى الرسالة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isMe ? AppColors.primary : (widget.isDark ? AppColors.darkCard : Colors.grey[200]),
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
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // ✅ صورة
                        if (widget.message.isImage && widget.message.imageUrl != null)
                          GestureDetector(
                            onTap: () => _showFullScreenImage(context, widget.message.imageUrl!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: widget.message.imageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                            ),
                          ),
                        // ✅ فيديو
                        if (widget.message.isVideo && _isVideoInitialized && _videoController != null)
                          GestureDetector(
                            onTap: () {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                              setState(() {});
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        if (widget.message.isText || (widget.message.isImage && widget.message.text != '📷 صورة'))
                          Text(
                            widget.message.text,
                            style: TextStyle(
                              color: widget.isMe ? Colors.white : (widget.isDark ? Colors.white : Colors.black87),
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
                                color: widget.isMe ? Colors.white70 : (widget.isDark ? Colors.grey[400] : Colors.grey[500]),
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
                            if (widget.message.reactions.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              ...widget.message.reactions.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Text(
                                    '${entry.key}${entry.value > 1 ? entry.value : ''}',
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🗑️ تم حذف هذه الرسالة',
                style: TextStyle(
                  color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
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
            '0:30',
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
              widget.message.text,
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
                  widget.message.getFileName,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isMe ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.message.getFileSizeFormatted,
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

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['👍', '❤️', '😂', '😮', '😢', '🙏'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onReaction(widget.message);
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
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.primary),
              title: const Text('رد على الرسالة'),
              onTap: () {
                Navigator.pop(context);
                widget.onReply(widget.message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primary),
              title: const Text('نسخ النص'),
              onTap: () {
                Navigator.pop(context);
                ToastService.showInfo('📋 تم نسخ الرسالة');
              },
            ),
            if (widget.isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف للجميع', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete(widget.message);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}
