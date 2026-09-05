// ============================================================
// 📁 lib/presentation/screens/chat/widgets/chat_input_bar.dart
// 💬 شريط إدخال الرسائل مع التسجيل الصوتي
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
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
  final AudioRecorder _recorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _isSending = false;
  String? _recordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<RecordingState>? _recordingSubscription;

  @override
  void dispose() {
    _controller.dispose();
    _recordingSubscription?.cancel();
    _recorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // 🎙️ بدء التسجيل
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

  // ============================================================
  // ⏱️ مؤقت التسجيل
  // ============================================================
  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = _recordingDuration + const Duration(seconds: 1);
      });
    });
  }

  // ============================================================
  // ⏹️ إيقاف التسجيل
  // ============================================================
  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      setState(() => _isRecording = false);
      
      if (_recordingPath == null) return;
      
      final path = _recordingPath!;
      final file = File(path);
      
      if (!await file.exists()) {
        ToastService.showError('❌ فشل حفظ التسجيل');
        return;
      }
      
      final size = await file.length();
      if (size < 1000) {
        ToastService.showError('❌ التسجيل قصير جداً');
        await file.delete();
        return;
      }
      
      // رفع التسجيل إلى Firebase Storage
      await _uploadAudio(file);
      
    } catch (e) {
      ToastService.showError('❌ فشل إيقاف التسجيل: $e');
    }
  }

  // ============================================================
  // 📤 رفع التسجيل الصوتي
  // ============================================================
  Future<void> _uploadAudio(File file) async {
    setState(() => _isSending = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // رفع إلى Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/audio/${DateTime.now().millisecondsSinceEpoch}.m4a');
      
      await ref.putFile(file);
      final audioUrl = await ref.getDownloadURL();
      
      // حفظ في Firestore
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
            'audioUrl': audioUrl,
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
      
    } catch (e) {
      ToastService.showError('❌ فشل رفع التسجيل: $e');
    } finally {
      setState(() => _isSending = false);
      // حذف الملف المؤقت
      try { await file.delete(); } catch (_) {}
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
                widget.onSendImage('');
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
