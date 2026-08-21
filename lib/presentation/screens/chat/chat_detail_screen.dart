import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/typing_service.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:sehatak/presentation/screens/chat/widgets/voice_recorder_widget.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  final TypingService _typingService = TypingService();

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
    _typingService.stopTyping(chatId: widget.chatId);
    super.dispose();
  }

  // ✅ تحديث حالة القراءة
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

  // ✅ معالجة تغيير النص - إرسال حالة الكتابة
  void _onTextChanged(String text) {
    final isTyping = text.isNotEmpty;
    setState(() => _isTyping = isTyping);

    _typingDebounce?.cancel();

    if (isTyping) {
      _typingDebounce = Timer(const Duration(milliseconds: 500), () {
        _typingService.startTyping(chatId: widget.chatId);
      });
    } else {
      _typingService.stopTyping(chatId: widget.chatId);
    }
  }

  // ✅ إرسال رسالة
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    _typingService.stopTyping(chatId: widget.chatId);
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
    }
  }

  // ✅ إرسال صورة
  Future<void> _sendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      final user = _auth.currentUser;
      if (user == null) return;

      _typingService.stopTyping(chatId: widget.chatId);

      final ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(image.path));
      final imageUrl = await ref.getDownloadURL();

      final messageData = {
        'text': '📷 صورة',
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'image',
        'imageUrl': imageUrl,
        'isRead': false,
      };

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📷 صورة',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _scrollToBottom();
    } catch (e) {
      print('❌ Error sending image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل إرسال الصورة: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ✅ إرسال رسالة صوتية
  void _sendVoiceMessage(String url) {
    setState(() {
      _showVoiceRecorder = false;
    });
    _scrollToBottom();
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

  // ✅ بدء مكالمة
  void _startCall(bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: widget.chatId,
          doctorName: widget.userName,
          doctorId: widget.userId,
          isVideo: isVideo,
        ),
      ),
    );
  }

  // ✅ عرض خيارات المرفقات
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📷 جاري فتح الكاميرا...'), backgroundColor: AppColors.primary),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📎 جاري إرسال الملف...'), backgroundColor: AppColors.primary),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: AppColors.primary),
              title: const Text('تسجيل صوتي'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showVoiceRecorder = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ بناء مؤشر الكتابة
  Widget _buildTypingIndicator(List<Map<String, dynamic>> typingUsers) {
    if (typingUsers.isEmpty) return const SizedBox.shrink();

    final names = typingUsers.map((user) => user['userName'] as String).toList();
    final displayName = names.length == 1 
        ? names.first 
        : '${names.first} و ${names.length - 1} آخرين';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TypingIndicator(),
                const SizedBox(width: 8),
                Text(
                  '$displayName يكتب...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      backgroundColor: isDark ? const Color(0xFF0b141a) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
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
        backgroundColor: isDark ? const Color(0xFF0b141a) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
            tooltip: 'مكالمة صوتية',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
            tooltip: 'مكالمة فيديو',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط الرد على رسالة
          if (_replyToMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                border: Border(
                  right: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرد على ${_replyToMessage?['senderName']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _replyToMessage?['text'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    onPressed: () => setState(() {
                      _replyToMessage = null;
                      _replyToMessageId = null;
                    }),
                  ),
                ],
              ),
            ),

          // ✅ قائمة الرسائل + مؤشر الكتابة
          Expanded(
            child: Column(
              children: [
                Expanded(
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

                          return MessageBubble(
                            chatId: widget.chatId,
                            messageId: message.id,
                            text: data['text'] ?? '',
                            type: data['type'] ?? 'text',
                            mediaUrl: data['imageUrl'] ?? data['audioUrl'],
                            isMe: isMe,
                            time: _formatTime(data['timestamp'] as Timestamp?),
                            isRead: data['isRead'] as bool? ?? false,
                            senderName: data['senderName'] as String?,
                            reactions: List<String>.from(data['reactions'] ?? []),
                            reactionCounts: Map<String, int>.from(data['reactionCounts'] ?? {}),
                            onReply: () {
                              setState(() {
                                _replyToMessage = data;
                                _replyToMessageId = message.id;
                              });
                              _messageController.requestFocus();
                            },
                            onDelete: () {
                              _firestore
                                  .collection('chats')
                                  .doc(widget.chatId)
                                  .collection('messages')
                                  .doc(message.id)
                                  .delete();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // ✅ مؤشر الكتابة
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _typingService.getTypingStatus(widget.chatId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final typingUsers = snapshot.data!
                        .where((user) => user['userId'] != _auth.currentUser?.uid)
                        .toList();
                    
                    return _buildTypingIndicator(typingUsers);
                  },
                ),
              ],
            ),
          ),

          // ✅ حقل الإدخال
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0b141a) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _showVoiceRecorder
                ? VoiceRecorderWidget(
                    chatId: widget.chatId,
                    onVoiceSent: _sendVoiceMessage,
                  )
                : Row(
                    children: [
                      // ✅ زر المرفقات
                      IconButton(
                        icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        onPressed: _showAttachmentOptions,
                      ),
                      // ✅ زر الصور
                      IconButton(
                        icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        onPressed: _sendImage,
                      ),
                      // ✅ حقل النص
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
                      // ✅ زر التسجيل الصوتي
                      IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() => _showVoiceRecorder = true);
                        },
                      ),
                      // ✅ زر الإرسال
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
