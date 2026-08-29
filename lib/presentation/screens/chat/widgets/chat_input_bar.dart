// ============================================================
// 📱 شريط الإدخال - نسخة مصححة
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onImagePick;
  final VoidCallback onVoiceRecord;
  final VoidCallback onLocationShare;
  final VoidCallback onFilePick;
  final bool isSending;
  final bool isDark;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onSend,
    required this.onImagePick,
    required this.onVoiceRecord,
    required this.onLocationShare,
    required this.onFilePick,
    required this.isSending,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isTyping = textController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                onSubmitted: (_) => onSend(),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  prefixIcon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: onVoiceRecord,
          ),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isTyping ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTyping ? AppColors.primary : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                  width: 1.5,
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isTyping ? Icons.send : Icons.mic,
                      color: isTyping ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    // TODO: عرض خيارات المرفقات
  }
}
