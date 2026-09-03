// ============================================================
// 📝 ChatInputBar - شريط الإدخال الكامل
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSend;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onSend,
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
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
                onSubmitted: widget.onSend,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                border: Border.all(
                  color: _isTyping ? AppColors.primary : Colors.grey,
                ),
              ),
              child: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: _isTyping ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
