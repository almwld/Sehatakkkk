// ============================================================
// 📁 lib/presentation/screens/chat/widgets/chat_input_bar.dart
// 💬 شريط الإدخال - رفع إلى NextCloud
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

  const ChatInputBar({
    super.key,
    required this.chatId,
    required this.onSendMessage,
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
  // 📤 رفع إلى NextCloud
  // ============================================================
  Future<String?> _uploadToNextCloud(File file, String folder) async {
    try {
      final result = await _nextcloud.uploadFile(
        file: file,
        path: 'chats/${widget.chatId}/$folder',
      );
      return result.success ? result.url : null;
    } catch (e) {
      ToastService.showError('❌ فشل رفع الملف: $e');
      return null;
    }
  }

  // ============================================================
  // 📷 رفع الصورة
  // ============================================================
  Future<void> _sendImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    setState(() => _isSending = true);
    final file = File(image.path);
    final imageUrl = await _uploadToNextCloud(file, 'images');
    
    if (imageUrl != null) {
      await _saveMessage('📷 صورة', imageUrl, 'image');
    }
    setState(() => _isSending = false);
  }

  // ============================================================
  // 🎙️ التسجيل الصوتي
  // ============================================================
  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    
    setState(() { _isRecording = true; _recordingPath = path; });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });
    ToastService.showInfo('🎙️ جاري التسجيل...');
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    setState(() => _isRecording = false);
    
    if (_recordingPath == null) return;
    final file = File(_recordingPath!);
    if (await file.length() < 1000) {
      ToastService.showError('❌ التسجيل قصير جداً');
      await file.delete();
      return;
    }

    setState(() => _isSending = true);
    final audioUrl = await _uploadToNextCloud(file, 'audio');
    
    if (audioUrl != null) {
      await _saveMessage('🎵 رسالة صوتية', audioUrl, 'audio', duration: _recordingDuration.inSeconds);
    }
    setState(() => _isSending = false);
    await file.delete();
  }

  // ============================================================
  // 💾 حفظ في Firestore
  // ============================================================
  Future<void> _saveMessage(String text, String mediaUrl, String type, {int duration = 0}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = {
      'chatId': widget.chatId,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'isRead': false,
      'isDelivered': false,
      'reactions': {},
    };

    if (type == 'image') data['imageUrl'] = mediaUrl;
    if (type == 'audio') {
      data['audioUrl'] = mediaUrl;
      data['duration'] = duration;
    }
    if (type == 'video') data['videoUrl'] = mediaUrl;

    await _firestore.collection('chats').doc(widget.chatId).collection('messages').add(data);
    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': user.uid,
    });

    ToastService.showSuccess('✅ تم الإرسال');
  }

  // ============================================================
  // 🏗️ الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: isDark ? Colors.white : Colors.black87),
            onPressed: _showAttachmentOptions,
          ),
          const SizedBox(width: 4),
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
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(Icons.mic, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.primary),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('صورة من المعرض'),
              onTap: () { Navigator.pop(context); _sendImage(); },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('مشاركة الموقع'),
              onTap: () { Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}
