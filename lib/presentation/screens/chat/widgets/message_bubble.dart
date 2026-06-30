import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final bool isTemp;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isTemp = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = message['text'] ?? '';
    final imageUrl = message['imageUrl'];
    final audioUrl = message['audioUrl'];
    final timestamp = message['timestamp'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                  ),
                  border: isTemp ? Border.all(color: AppColors.warning, width: 1) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      GestureDetector(
                        onTap: onTap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 150,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 150,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  File(imageUrl),
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 150,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    if (audioUrl != null && audioUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: isMe ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.white24
                                      : AppColors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '0:30',
                              style: TextStyle(
                                color: isMe ? Colors.white70 : AppColors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : null,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(timestamp),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : AppColors.grey,
                            fontSize: 9,
                          ),
                        ),
                        if (isTemp) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.timer,
                            size: 10,
                            color: AppColors.warning,
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

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is DateTime) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }
}
