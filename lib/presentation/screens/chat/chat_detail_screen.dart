import 'dart:async';
import 'dart:io';
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
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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
  final AudioRecorder _recorder = AudioRecorder();

  bool _isTyping = false;
  bool _showVoiceRecorder = false;
  bool _isRecording = false;
  String? _recordingPath;
  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  Timer? _typingDebounce;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String? _selectedReactionMessageId;

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
    _recordingTimer?.cancel();
    _recorder.dispose();
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

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inMinutes < 1) return 'الآن';
        if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
        if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
        if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
        return '${date.day}/${date.month}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.userName),
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
          _buildInputField(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, bool isDark) {
    final text = message['text'] ?? '';
    final time = _formatTime(message['timestamp']);
    final isRead = message['isRead'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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

  Widget _buildInputField(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.white,
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
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202c33) : Colors.grey[100],
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
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالة...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: _sendMessage,
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
              child: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: _isTyping ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 20,
              ),
            ),
          ),
        ],
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
