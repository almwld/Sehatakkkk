import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/reply_banner.dart';
import 'package:sehatak/presentation/screens/chat/widgets/voice_recorder.dart';

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
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _reactions = [];

  // ✅ حالة الرد على رسالة
  Map<String, dynamic>? _replyTo;
  bool _showVoiceRecorder = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messages.addAll([
      {
        'id': '1',
        'text': 'مرحباً! كيف يمكنني مساعدتك؟',
        'isUser': false,
        'time': '10:00 ص',
        'senderName': widget.userName,
        'reactions': ['👍', '❤️'],
        'isRead': true,
        'type': 'text',
      },
      {
        'id': '2',
        'text': 'أريد حجز موعد مع الدكتور',
        'isUser': true,
        'time': '10:05 ص',
        'senderName': 'أنا',
        'reactions': [],
        'isRead': true,
        'type': 'text',
      },
      {
        'id': '3',
        'text': 'https://picsum.photos/200/200',
        'isUser': false,
        'time': '10:06 ص',
        'senderName': widget.userName,
        'reactions': ['😂'],
        'isRead': true,
        'type': 'image',
        'mediaUrl': 'https://picsum.photos/200/200',
      },
      {
        'id': '4',
        'text': 'تفضل، اختر الوقت المناسب',
        'isUser': false,
        'time': '10:06 ص',
        'senderName': widget.userName,
        'reactions': [],
        'isRead': false,
        'type': 'text',
      },
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'isUser': true,
      'time': 'الآن',
      'senderName': 'أنا',
      'reactions': [],
      'isRead': false,
      'type': 'text',
      'replyTo': _replyTo != null ? _replyTo!['text'] : null,
      'replyToSender': _replyTo != null ? _replyTo!['senderName'] : null,
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _replyTo = null;
    });

    _scrollToBottom();

    // ✅ محاكاة الرد
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'شكراً لتواصلك! سأرد عليك قريباً',
          'isUser': false,
          'time': 'الآن',
          'senderName': widget.userName,
          'reactions': [],
          'isRead': true,
          'type': 'text',
        });
      });
      _scrollToBottom();
    });
  }

  void _sendVoiceMessage(String path) {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'رسالة صوتية',
        'isUser': true,
        'time': 'الآن',
        'senderName': 'أنا',
        'reactions': [],
        'isRead': false,
        'type': 'audio',
        'mediaUrl': path,
      });
      _showVoiceRecorder = false;
    });
    _scrollToBottom();
  }

  void _addReaction(String messageId, String emoji) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg['id'] == messageId);
      if (index != -1) {
        final reactions = List<String>.from(_messages[index]['reactions'] ?? []);
        if (reactions.contains(emoji)) {
          reactions.remove(emoji);
        } else {
          reactions.add(emoji);
        }
        _messages[index]['reactions'] = reactions;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
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
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // ✅ بدء مكالمة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📞 جاري الاتصال...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // ✅ بدء مكالمة فيديو
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📹 جاري بدء مكالمة فيديو...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط الرد على رسالة
          if (_replyTo != null)
            ReplyBanner(
              message: _replyTo!['text'] as String,
              senderName: _replyTo!['senderName'] as String,
              onCancel: () => setState(() => _replyTo = null),
            ),
          // ✅ قائمة الرسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message['isUser'] as bool;
                final messageId = message['id'] as String;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MessageBubble(
                    text: message['text'] as String,
                    type: message['type'] as String? ?? 'text',
                    mediaUrl: message['mediaUrl'] as String?,
                    isMe: isUser,
                    time: message['time'] as String,
                    isRead: message['isRead'] as bool? ?? false,
                    senderName: message['senderName'] as String?,
                    reactions: List<String>.from(message['reactions'] ?? []),
                    onReact: (emoji) => _addReaction(messageId, emoji),
                    onReply: () {
                      setState(() {
                        _replyTo = {
                          'text': message['text'],
                          'senderName': message['senderName'] ?? 'مستخدم',
                          'id': messageId,
                        };
                      });
                      _focusNode.requestFocus();
                    },
                    onDelete: () {
                      setState(() {
                        _messages.removeWhere((msg) => msg['id'] == messageId);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // ✅ حقل إدخال الرسالة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_showVoiceRecorder)
                  VoiceRecorder(
                    onRecordComplete: _sendVoiceMessage,
                  ),
                Row(
                  children: [
                    // ✅ زر المرفقات
                    IconButton(
                      icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      onPressed: _showAttachmentOptions,
                    ),
                    // ✅ زر التسجيل الصوتي
                    IconButton(
                      icon: Icon(
                        _showVoiceRecorder ? Icons.keyboard : Icons.mic,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => _showVoiceRecorder = !_showVoiceRecorder);
                      },
                    ),
                    // ✅ حقل النص
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          onChanged: (text) {
                            setState(() => _isTyping = text.trim().isNotEmpty);
                          },
                          onSubmitted: (_) => _sendMessage(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
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
              ],
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
        child: Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentOption(Icons.photo_library, 'صورة', Colors.purple),
                  _attachmentOption(Icons.videocam, 'فيديو', Colors.blue),
                  _attachmentOption(Icons.picture_as_pdf, 'PDF', Colors.red),
                  _attachmentOption(Icons.location_on, 'موقع', Colors.green),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📎 جاري إرسال $label...'),
            backgroundColor: color,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
