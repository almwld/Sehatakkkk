// ============================================================
// 📁 lib/presentation/screens/chat/widgets/message_bubble.dart
// 💬 فقاعة الرسائل - تدعم النص، الصور، الصوت، الفيديو
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
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
  bool _isPlaying = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.message['type'] == 'audio' && widget.message['audioUrl'] != null) {
      _audioPlayer = AudioPlayer();
    }
    if (widget.message['type'] == 'video' && widget.message['videoUrl'] != null) {
      // _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.message['videoUrl']));
      // _videoController?.initialize();
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
    final type = widget.message['type'] ?? 'text';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // ✅ عرض المحتوى حسب النوع
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: _buildContent(type, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String type, bool isDark) {
    switch (type) {
      case 'image':
        return _buildImageMessage(widget.message['imageUrl'] ?? '', isDark);
      case 'audio':
        return _buildAudioMessage(widget.message, widget.isMe, isDark);
      case 'video':
        return _buildVideoMessage(widget.message['videoUrl'] ?? '', isDark);
      case 'location':
        return _buildLocationMessage(widget.message, isDark);
      default:
        return _buildTextMessage(widget.message, widget.isMe, isDark);
    }
  }

  // ============================================================
  // 📝 الرسائل النصية
  // ============================================================
  Widget _buildTextMessage(Map<String, dynamic> message, bool isMe, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message['text'] ?? '',
        style: TextStyle(
          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // 🖼️ عرض الصور (من NextCloud)
  // ============================================================
  Widget _buildImageMessage(String imageUrl, bool isDark) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 200,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 200,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎵 عرض التسجيل الصوتي (من NextCloud)
  // ============================================================
  Widget _buildAudioMessage(Map<String, dynamic> message, bool isMe, bool isDark) {
    final duration = message['duration'] ?? 0;
    final audioUrl = message['audioUrl'] ?? '';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔘 زر التشغيل
          GestureDetector(
            onTap: () => _toggleAudio(audioUrl),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: isMe ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 📊 شريط التقدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isMe ? Colors.white.withOpacity(0.3) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white : AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 🎵 أيقونة الصوت
          Icon(
            Icons.audiotrack,
            color: isMe ? Colors.white.withOpacity(0.6) : Colors.grey[600],
            size: 16,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAudio(String audioUrl) async {
    if (_isPlaying) {
      await _audioPlayer?.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _audioPlayer?.play(UrlSource(audioUrl));
        setState(() => _isPlaying = true);
        _audioPlayer?.onPlayerComplete.listen((_) {
          setState(() => _isPlaying = false);
        });
      } catch (e) {
        ToastService.showError('❌ فشل تشغيل الصوت');
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // 🎥 عرض الفيديو (من NextCloud)
  // ============================================================
  Widget _buildVideoMessage(String videoUrl, bool isDark) {
    return GestureDetector(
      onTap: () => _playVideo(videoUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ✅ صورة مصغرة للفيديو
              CachedNetworkImage(
                imageUrl: videoUrl,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 200,
                  height: 150,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 150,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.videocam_off, color: Colors.grey, size: 40),
                ),
              ),
              
              // ✅ زر تشغيل الفيديو
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              
              // ✅ مدة الفيديو
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '00:00',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo(String videoUrl) {
    ToastService.showInfo('🎬 جاري تشغيل الفيديو...');
    // TODO: فتح شاشة تشغيل الفيديو
  }

  // ============================================================
  // 📍 عرض الموقع
  // ============================================================
  Widget _buildLocationMessage(Map<String, dynamic> message, bool isDark) {
    return GestureDetector(
      onTap: () => ToastService.showInfo('📍 عرض الموقع على الخريطة'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Text(
              message['text'] ?? '📍 موقع',
              style: TextStyle(
                color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
