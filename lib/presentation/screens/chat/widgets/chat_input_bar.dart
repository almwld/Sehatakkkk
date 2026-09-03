import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = widget.textController.text.isNotEmpty;
    if (_isTyping != isTyping) {
      setState(() => _isTyping = isTyping);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر إضافة مرفقات
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: isDark ? Colors.white : Colors.grey[600],
            ),
            onPressed: _showAttachmentOptions,
          ),
          // حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.textController,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: null,
                textDirection: TextDirection.rtl,
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    widget.onSend(text.trim());
                  }
                },
              ),
            ),
          ),
          // زر الإرسال
          if (_isTyping)
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: widget.isSending
                  ? null
                  : () {
                      final text = widget.textController.text.trim();
                      if (text.isNotEmpty) {
                        widget.onSend(text);
                      }
                    },
            )
          else
            IconButton(
              icon: const Icon(Icons.mic, color: AppColors.primary),
              onPressed: widget.onVoiceRecord,
            ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image,
                    label: 'صورة',
                    onTap: widget.onImagePick,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.mic,
                    label: 'تسجيل',
                    onTap: widget.onVoiceRecord,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.attach_file,
                    label: 'ملف',
                    onTap: widget.onFilePick,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_on,
                    label: 'موقع',
                    onTap: widget.onLocationShare,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
