import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/constants/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'widgets/voice_recorder.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String userId;
  final bool isDoctor;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.userName,
    required this.userId,
    required this.isDoctor,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isTyping = false;
  bool _showVoiceRecorder = false;
  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: _auth.currentUser?.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in messages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }

  void _onTextChanged(String text) {
    final isTyping = text.isNotEmpty;
    setState(() => _isTyping = isTyping);

    _typingDebounce?.cancel();

    if (isTyping) {
      _typingDebounce = Timer(const Duration(milliseconds: 500), () {
        // إرسال حالة الكتابة
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    _typingDebounce?.cancel();

    try {
      final messageData = {
        'text': text,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'isRead': false,
        'replyTo': _replyToMessageId,
        'replyToText': _replyToMessage?['text'],
        'replyToSender': _replyToMessage?['senderName'],
      };

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      setState(() {
        _replyToMessage = null;
        _replyToMessageId = null;
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('❌ Error sending message: $e');
      ToastService.showError('❌ فشل إرسال الرسالة');
    }
  }

  void _sendVoiceMessage(String path) {
    ToastService.showSuccess('✅ تم إرسال الصوت بنجاح');
    setState(() => _showVoiceRecorder = false);
  }

  void _cancelVoiceRecording() {
    setState(() => _showVoiceRecorder = false);
    ToastService.showInfo('❌ تم إلغاء التسجيل');
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _showDoctorInfo(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(ImageKit.doctor1),
                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.userName),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => ToastService.showInfo('📞 جاري الاتصال...'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => ToastService.showInfo('📹 جاري مكالمة فيديو...'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/chat_background.svg'),
                  fit: BoxFit.cover,
                  opacity: isDark ? 0.1 : 0.3,
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('❌ ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;
                  if (messages.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final data = message.data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == _auth.currentUser?.uid;
                      return _buildMessageBubble(data, isMe, isDark);
                    },
                  );
                },
              ),
            ),
          ),
          _showVoiceRecorder
              ? VoiceRecorder(
                  onRecordingComplete: _sendVoiceMessage,
                  onCancel: _cancelVoiceRecording,
                )
              : _buildInputField(isDark),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDark) {
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
            onPressed: () => ToastService.showInfo('📎 جاري فتح المرفقات...'),
          ),
          IconButton(
            icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () => ToastService.showInfo('📷 جاري فتح المعرض...'),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2a3942) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                onChanged: _onTextChanged,
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
            onTap: () {
              setState(() => _showVoiceRecorder = true);
            },
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

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, bool isDark) {
    final text = message['text'] ?? '';
    final type = message['type'] ?? 'text';
    final time = _formatTime(message['timestamp'] as Timestamp?);
    final isRead = message['isRead'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : (isDark ? const Color(0xFF2D3A54) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 9,
                          color: isMe ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[500]),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: isRead ? Colors.blue : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(ImageKit.doctor1),
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'طبيب عام',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text('4.9'),
                const SizedBox(width: 8),
                const Icon(Icons.work, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                const Text('10+ سنة خبرة'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('عرض الملف الشخصي'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ المحادثة الآن',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ إضافة خلفية الدردشة
Widget _buildChatBackground(Widget child) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(
          isDark 
              ? 'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png'
              : 'assets/images/sehatak_chat_wallpaper_light_1080x2160.png',
        ),
        fit: BoxFit.cover,
        opacity: 0.8,
      ),
    ),
    child: child,
  );
}

// ✅ استخدام الخلفية في الـ Scaffold
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _buildChatBackground(
      // ... المحتوى
    ),
  );
}
