// ============================================================
// 📁 lib/presentation/screens/chat/widgets/chat_input_bar.dart
// 💬 شريط إدخال الرسائل - رفع إلى NextCloud
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NextcloudService _nextcloud = NextcloudService();
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();
  
  bool _isRecording = false;
  bool _isSending = false;
  String? _recordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // 📤 رفع الملفات إلى NextCloud
  // ============================================================
  Future<String?> _uploadToNextCloud(File file, String folder) async {
    try {
      final result = await _nextcloud.uploadFile(
        file: file,
        path: 'chats/${widget.chatId}/$folder',
        onProgress: (sent, total) {
          // يمكن إضافة مؤشر تقدم
        },
      );
      
      if (result.success && result.url != null) {
        return result.url;
      }
      return null;
    } catch (e) {
      ToastService.showError('❌ فشل رفع الملف: $e');
      return null;
    }
  }

  // ============================================================
  // 📷 رفع الصور إلى NextCloud
  // ============================================================
  Future<void> _sendImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _isSending = true);

      final file = File(image.path);
      
      // ✅ رفع إلى NextCloud
      final imageUrl = await _uploadToNextCloud(file, 'images');
      
      if (imageUrl == null) {
        ToastService.showError('❌ فشل رفع الصورة');
        return;
      }

      // ✅ حفظ الرابط في Firestore
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'chatId': widget.chatId,
            'senderId': user.uid,
            'senderName': user.displayName ?? 'مستخدم',
            'senderPhotoUrl': user.photoURL,
            'text': '📷 صورة',
            'imageUrl': imageUrl, // ✅ رابط NextCloud
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'image',
            'isRead': false,
            'isDelivered': false,
            'reactions': {},
          });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📷 صورة',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ToastService.showSuccess('✅ تم إرسال الصورة');
      
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الصورة: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ============================================================
  // 🎙️ التسجيل الصوتي ورفع إلى NextCloud
  // ============================================================
  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${tempDir.path}/audio_$timestamp.m4a';
        
        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });
        
        _startTimer();
        ToastService.showInfo('🎙️ جاري التسجيل...');
      }
    } catch (e) {
      ToastService.showError('❌ فشل بدء التسجيل: $e');
    }
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = _recordingDuration + const Duration(seconds: 1);
      });
    });
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      setState(() => _isRecording = false);
      
      if (_recordingPath == null) return;
      
      final file = File(_recordingPath!);
      if (!await file.exists()) return;
      
      final size = await file.length();
      if (size < 1000) {
        ToastService.showError('❌ التسجيل قصير جداً');
        await file.delete();
        return;
      }
      
      setState(() => _isSending = true);
      
      // ✅ رفع الصوت إلى NextCloud
      final audioUrl = await _uploadToNextCloud(file, 'audio');
      
      if (audioUrl == null) {
        ToastService.showError('❌ فشل رفع التسجيل');
        return;
      }

      // ✅ حفظ الرابط في Firestore
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'chatId': widget.chatId,
            'senderId': user.uid,
            'senderName': user.displayName ?? 'مستخدم',
            'senderPhotoUrl': user.photoURL,
            'text': '🎵 رسالة صوتية',
            'audioUrl': audioUrl, // ✅ رابط NextCloud
            'duration': _recordingDuration.inSeconds,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'audio',
            'isRead': false,
            'isDelivered': false,
            'reactions': {},
          });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '🎵 رسالة صوتية',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ToastService.showSuccess('✅ تم إرسال التسجيل الصوتي');
      
      // حذف الملف المؤقت
      try { await file.delete(); } catch (_) {}
      
    } catch (e) {
      ToastService.showError('❌ فشل إرسال التسجيل: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ============================================================
  // 🏗️ بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          // 📎 زر المرفقات
          IconButton(
            icon: Image.asset(
              'assets/images/chat/attachment.png',
              width: 24,
              height: 24,
              color: isDark ? Colors.white : Colors.black87,
              errorBuilder: (_, __, ___) => Icon(
                Icons.attach_file,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: _showAttachmentOptions,
          ),
          
          const SizedBox(width: 4),
          
          // 📝 حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3A54) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  // 🎙️ زر التسجيل الصوتي
                  GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressUp: _stopRecording,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: _isRecording
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Image.asset(
                              'assets/images/chat/microphone.png',
                              width: 24,
                              height: 24,
                              color: isDark ? Colors.white : Colors.black87,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.mic,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 4),
          
          // 📤 زر الإرسال
          IconButton(
            icon: Image.asset(
              'assets/images/chat/send.png',
              width: 24,
              height: 24,
              color: AppColors.primary,
              errorBuilder: (_, __, ___) => Icon(
                Icons.send,
                color: AppColors.primary,
              ),
            ),
            onPressed: _sendMessage,
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
                _sendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                // TODO: فتح الكاميرا
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('مشاركة الموقع'),
              onTap: () {
                Navigator.pop(context);
                widget.onShareLocation();
              },
            ),
          ],
        ),
      ),
    );
  }
}
