import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'voice_recorder.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  final String chatId;
  final Function(String) onSendMessage;
  final Function(String) onSendImage;
  final VoidCallback onShareLocation;

  const ChatInputBar({
    super.key,
    required this.chatId,
    required this.onSendMessage,
    required this.onSendImage,
    required this.onShareLocation,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  bool _showVoiceRecorder = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_showVoiceRecorder) {
      return VoiceRecorder(
        chatId: widget.chatId,
        onRecordingComplete: (path) {
          setState(() => _showVoiceRecorder = false);
          ToastService.showSuccess('✅ تم تسجيل الصوت بنجاح');
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202c33) : Colors.white,
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
          IconButton(
            icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: Icon(Icons.location_on, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: widget.onShareLocation,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2a3942) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'رسالة...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  prefixIcon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  suffixIcon: Icon(
                    Icons.face,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopRecording,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  void _startRecording() {
    setState(() => _showVoiceRecorder = true);
  }

  void _stopRecording() {
    // التسجيل مستمر حتى يتم الإرسال أو الإلغاء
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        widget.onSendImage(image.path);
      }
    } catch (e) {
      ToastService.showError('❌ فشل اختيار الصورة: $e');
    }
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
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                ToastService.showInfo('📷 جاري فتح الكاميرا...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                ToastService.showInfo('📎 جاري إرسال الملف...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: AppColors.primary),
              title: const Text('تسجيل صوتي'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _showVoiceRecorder = true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
