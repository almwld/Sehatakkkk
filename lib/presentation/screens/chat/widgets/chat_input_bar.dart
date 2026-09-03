// ============================================================
// 📝 ChatInputBar - شريط الإدخال المتكامل
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSend;
  final VoidCallback onImagePick;
  final VoidCallback onVoiceRecord;
  final VoidCallback onFilePick;
  final VoidCallback onLocationShare;
  final bool isSending;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onSend,
    required this.onImagePick,
    required this.onVoiceRecord,
    required this.onFilePick,
    required this.onLocationShare,
    this.isSending = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // ✅ زر المرفقات
          IconButton(
            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: _showAttachmentOptions,
          ),
          // ✅ زر الصور
          IconButton(
            icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: widget.onImagePick,
          ),
          // ✅ حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.textController,
                onChanged: (text) => setState(() => _isTyping = text.isNotEmpty),
                onSubmitted: widget.onSend,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          // ✅ زر الإرسال / الميكروفون
          GestureDetector(
            onTap: _isTyping ? () => widget.onSend(widget.textController.text) : widget.onVoiceRecord,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isTyping ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isTyping ? AppColors.primary : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                  width: 1.5,
                ),
              ),
              child: widget.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      _isTyping ? Icons.send : Icons.mic,
                      color: _isTyping ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('صورة من المعرض'),
              onTap: () {
                Navigator.pop(context);
                widget.onImagePick();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                widget.onImagePick();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppColors.primary),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                widget.onFilePick();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('مشاركة الموقع'),
              onTap: () {
                Navigator.pop(context);
                widget.onLocationShare();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: AppColors.primary),
              title: const Text('تسجيل صوتي'),
              onTap: () {
                Navigator.pop(context);
                widget.onVoiceRecord();
              },
            ),
          ],
        ),
      ),
    );
  }
}
