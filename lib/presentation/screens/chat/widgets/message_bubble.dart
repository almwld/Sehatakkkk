import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

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
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.isAudio && widget.message.audioUrl != null) {
      _audioPlayer = AudioPlayer();
    }
    if (widget.message.isVideo && widget.message.fileUrl != null) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.message.fileUrl!),
      )..initialize().then((_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.message.isDeletedMessage) {
      return _buildDeletedMessage(isDark);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isMe ? AppColors.primary : (isDark ? const Color(0xFF2D3A54) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(12),
                  bottomLeft: widget.isMe ? const Radius.circular(12) : const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // ✅ اسم المرسل
                  if (!widget.isMe && widget.message.senderName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        widget.message.senderName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  
                  // ✅ صورة
                  if (widget.message.isImage && widget.message.imageUrl != null)
                    _buildImageContent(widget.message.imageUrl!),
                  
                  // ✅ صوت
                  if (widget.message.isAudio && widget.message.audioUrl != null)
                    _buildAudioContent(widget.message.audioUrl!, isDark),
                  
                  // ✅ فيديو
                  if (widget.message.isVideo && widget.message.fileUrl != null)
                    _buildVideoContent(widget.message.fileUrl!),
                  
                  // ✅ ملف
                  if (widget.message.isFile && widget.message.fileUrl != null)
                    _buildFileContent(widget.message.fileName ?? 'ملف', isDark),
                  
                  // ✅ موقع
                  if (widget.message.isLocation)
                    _buildLocationContent(widget.message.locationAddress ?? 'موقع', isDark),
                  
                  // ✅ نص
                  if (widget.message.text != null && widget.message.text!.isNotEmpty)
                    Text(
                      widget.message.text!,
                      style: TextStyle(
                        color: widget.isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontSize: 14,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // ✅ الوقت والحالة
                  Row(
                    mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isMe ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                      if (widget.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          widget.message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: widget.message.isRead
                              ? (isDark ? Colors.green[300] : Colors.green)
                              : (isDark ? Colors.grey[500] : Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  
                  // ✅ تفاعلات
                  if (widget.message.hasReactions)
                    _buildReactions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼️ محتوى الصورة
  // ============================================================
  Widget _buildImageContent(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // عرض الصورة في شاشة كاملة
      },
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
            color: Colors.grey[300],
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

  // ============================================================
  // 🎤 محتوى الصوت
  // ============================================================
  Widget _buildAudioContent(String audioUrl, bool isDark) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (_isPlaying) {
                await _audioPlayer?.pause();
              } else {
                await _audioPlayer?.play(UrlSource(audioUrl));
              }
              setState(() => _isPlaying = !_isPlaying);
            },
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: widget.isMe ? Colors.white : AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.white : AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.message.audioDuration ?? '00:00',
            style: TextStyle(
              fontSize: 12,
              color: widget.isMe ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎥 محتوى الفيديو
  // ============================================================
  Widget _buildVideoContent(String videoUrl) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        width: 200,
        height: 150,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        _videoController!.value.isPlaying
            ? _videoController!.pause()
            : _videoController!.play();
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (!_videoController!.value.isPlaying)
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 📎 محتوى الملف
  // ============================================================
  Widget _buildFileContent(String fileName, bool isDark) {
    return GestureDetector(
      onTap: () {
        // تحميل الملف
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file,
              color: widget.isMe ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                  color: widget.isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.download, size: 16),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📍 محتوى الموقع
  // ============================================================
  Widget _buildLocationContent(String address, bool isDark) {
    return GestureDetector(
      onTap: () {
        // فتح الموقع على الخريطة
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '📍 موقع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ❤️ التفاعلات
  // ============================================================
  Widget _buildReactions() {
    final reactions = widget.message.reactions?.values.toList() ?? [];
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 2,
        children: reactions.map((emoji) {
          return Text(emoji, style: const TextStyle(fontSize: 14));
        }).toList(),
      ),
    );
  }

  // ============================================================
  // 🗑️ رسالة محذوفة
  // ============================================================
  Widget _buildDeletedMessage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
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

  // ============================================================
  // ⏰ تنسيق الوقت
  // ============================================================
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}
