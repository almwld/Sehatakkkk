// ============================================================
// 📱 شريط الإدخال - مع زر إرسال وميكروفون
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';

class ChatInputBar extends StatefulWidget {
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
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTyping = widget.textController.text.trim().isNotEmpty;
    
    // ✅ تشغيل الأنيميشن عند تغيير حالة الكتابة
    if (isTyping && !_animationController.isAnimating) {
      _animationController.forward();
    } else if (!isTyping && _animationController.isCompleted) {
      _animationController.reverse();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
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
            icon: Icon(Icons.attach_file, color: widget.isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: _showAttachmentOptions,
          ),
          // ✅ حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.darkInput : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.textController,
                focusNode: widget.focusNode,
                onChanged: (text) {
                  setState(() {}); // ✅ تحديث الواجهة لتغيير الزر
                },
                onSubmitted: (_) => widget.onSend(),
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle: TextStyle(color: widget.isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  prefixIcon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          // ✅ زر التسجيل الصوتي أو الإرسال مع أنيميشن
          GestureDetector(
            onTap: isTyping ? widget.onSend : widget.onVoiceRecord,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isTyping ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTyping ? AppColors.primary : (widget.isDark ? Colors.grey[600]! : Colors.grey[300]!),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: widget.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        key: ValueKey('loading'),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : isTyping
                        ? AnimatedScale(
                            scale: _scaleAnimation.value,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: const Icon(
                                Icons.send,
                                key: ValueKey('send'),
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.mic,
                            key: const ValueKey('mic'),
                            color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
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
            // ✅ صورة من المعرض
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('صورة من المعرض'),
              onTap: () {
                Navigator.pop(context);
                widget.onImagePick();
              },
            ),
            // ✅ التقاط صورة
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                widget.onImagePick();
              },
            ),
            // ✅ تسجيل فيديو
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.primary),
              title: const Text('تسجيل فيديو'),
              onTap: () {
                Navigator.pop(context);
                widget.onImagePick();
              },
            ),
            // ✅ إرسال ملف
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppColors.primary),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                widget.onFilePick();
              },
            ),
            // ✅ مشاركة الموقع
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('مشاركة الموقع'),
              onTap: () {
                Navigator.pop(context);
                widget.onLocationShare();
              },
            ),
            // ✅ تسجيل صوتي
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
