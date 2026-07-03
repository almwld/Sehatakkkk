import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
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
    this.isDoctor = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isRecording = false;
  bool _isSending = false;

  // ✅ اختيار الصورة من المعرض أو الكاميرا
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isSending = true);
        final file = File(image.path);
        
        // ✅ حفظ الصورة محلياً وإرسالها كـ imageUrl
        final imagePath = await _chatService.saveLocalFile(file);
        await _chatService.sendMessage(
          chatId: widget.chatId,
          text: '',
          imageUrl: imagePath,
        );
        setState(() => _isSending = false);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showError('فشل إرسال الصورة: $e');
    }
  }

  // ✅ إظهار قائمة اختيار الصورة
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر مصدر الصورة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'المعرض',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'الكاميرا',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D5257).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D5257).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0D5257), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D5257),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.userName),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {
              ChatNavigation.openCall(
                context,
                chatId: 'call_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}',
                doctorName: widget.userName,
                doctorId: widget.userId,
                isVideo: false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () {
              ChatNavigation.openCall(
                context,
                chatId: 'call_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}',
                doctorName: widget.userName,
                doctorId: widget.userId,
                isVideo: true,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatService.getMessages(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('خطأ: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;
                    if (messages.isEmpty) {
                      return const Center(child: Text('ابدأ المحادثة الآن'));
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index].data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                        return _buildMessageBubble(data, isMe, isDark);
                      },
                    );
                  },
                ),
              ),
              _buildInputBar(isDark, primaryColor),
            ],
          ),
          if (_isSending)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ بناء فقاعة الرسالة - منفردة (نص OR صورة OR صوت)
  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe, bool isDark) {
    final hasImage = data['imageUrl'] != null && data['imageUrl'].isNotEmpty;
    final hasText = data['text'] != null && data['text'].isNotEmpty;
    final isVoice = data['audioUrl'] != null && data['audioUrl'].isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF0D5257).withOpacity(0.1),
              child: Text(
                widget.userName[0],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5257),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xFF0D5257)
                  : (isDark ? const Color(0xFF1A2540) : Colors.white),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ صورة منفردة
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: data['imageUrl'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                // ✅ نص منفرد
                if (hasText && !hasImage)
                  Text(
                    data['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontSize: 14,
                    ),
                  ),
                // ✅ صوت منفرد
                if (isVoice)
                  Row(
                    children: [
                      Icon(Icons.play_arrow, color: isMe ? Colors.white : const Color(0xFF0D5257)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white54 : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '0:30',
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(data['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ شريط الإدخال المحسّن
  Widget _buildInputBar(bool isDark, Color primaryColor) {
    final hasText = _messageController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
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
          // ✅ زر إرفاق صورة
          IconButton(
            icon: Icon(
              Icons.image_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: _showImagePickerOptions,
          ),
          // ✅ زر إرفاق ملف
          IconButton(
            icon: Icon(
              Icons.attach_file_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: () {},
          ),
          // ✅ حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.emoji_emotions_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: _isRecording ? 'جاري التسجيل...' : 'اكتب رسالة...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ✅ زر الإرسال (نص) أو الميكروفون (صوت)
          if (hasText)
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendTextMessage,
                padding: EdgeInsets.zero,
              ),
            )
          else
            GestureDetector(
              onLongPress: () {
                setState(() => _isRecording = true);
                // بدء التسجيل
              },
              onLongPressEnd: (_) {
                setState(() => _isRecording = false);
                // إيقاف التسجيل وإرسال الصوت
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: _isRecording ? Colors.red : primaryColor,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ إرسال رسالة نصية منفردة
  Future<void> _sendTextMessage() async {
    if (_messageController.text.isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();
    setState(() {});

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: text,
      );
    } catch (e) {
      _showError('فشل إرسال الرسالة: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        if (date.day == now.day && date.month == now.month && date.year == now.year) {
          return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        }
        return '${date.day}/${date.month}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
