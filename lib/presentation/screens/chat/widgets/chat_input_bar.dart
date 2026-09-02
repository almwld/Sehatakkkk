// ============================================================
// 📱 ChatInputBar - شريط الإدخال
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSend;
  final VoidCallback onImagePick;
  final VoidCallback onVoiceRecord;
  final String? replyToId;
  final VoidCallback? onCancelReply;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onSend,
    required this.onImagePick,
    required this.onVoiceRecord,
    this.replyToId,
    this.onCancelReply,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (widget.replyToId != null) _buildReplyBanner(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: widget.onImagePick,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: widget.textController,
                    onChanged: (text) => setState(() => _isTyping = text.isNotEmpty),
                    onSubmitted: (text) => widget.onSend(text),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => widget.onSend(widget.textController.text),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isTyping ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: _isTyping ? AppColors.primary : Colors.grey),
                  ),
                  child: Icon(
                    _isTyping ? Icons.send : Icons.mic,
                    color: _isTyping ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.reply, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          const Expanded(child: Text('الرد على رسالة')),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: widget.onCancelReply,
          ),
        ],
      ),
    );
  }
}
