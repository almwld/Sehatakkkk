// ============================================================
// 📁 message_bubble.dart - النسخة النهائية
// ============================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = message['type'] ?? 'text';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
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
        return _buildImageMessage(message['imageUrl'] ?? '', isDark);
      case 'audio':
        return _buildAudioMessage(message, isDark);
      case 'location':
        return _buildLocationMessage(message, isDark);
      default:
        return _buildTextMessage(message, isDark);
    }
  }

  // ============================================================
  // 📝 رسالة نصية
  // ============================================================
  Widget _buildTextMessage(Map<String, dynamic> message, bool isDark) {
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
  // 🖼️ صورة
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
    // TODO: عرض الصورة بملء الشاشة
  }

  // ============================================================
  // 🎵 رسالة صوتية
  // ============================================================
  Widget _buildAudioMessage(Map<String, dynamic> message, bool isDark) {
    final duration = message['duration'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: isMe ? Colors.white : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
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
          Icon(
            Icons.audiotrack,
            color: isMe ? Colors.white.withOpacity(0.6) : Colors.grey[600],
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // 📍 موقع
  // ============================================================
  Widget _buildLocationMessage(Map<String, dynamic> message, bool isDark) {
    return Container(
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
    );
  }
}
