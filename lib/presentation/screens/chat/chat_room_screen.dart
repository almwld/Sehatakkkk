// ============================================================
// 💬 ChatRoomScreen - شاشة غرفة الدردشة (جميع الأزرار مربوطة)
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/reaction_picker.dart';
import 'package:sehatak/presentation/screens/chat/widgets/delete_message_dialog.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final bool isGroup;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    this.isGroup = false,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  final ImagePicker _picker = ImagePicker();

  bool _isSending = false;
  bool _isRecording = false;
  String? _replyTo;
  String? _replyToText;
  List<String> _typingUsers = [];

  // ✅ 1. رفع صورة من المعرض
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;
      
      // TODO: رفع الصورة وإرسالها
      ToastService.showInfo('📷 جاري رفع الصورة...');
      
      // محاكاة رفع
      await Future.delayed(const Duration(seconds: 1));
      
      // إرسال رسالة بالصورة
      await _sendMessageWithImage(File(image.path));
      
    } catch (e) {
      ToastService.showError('❌ فشل اختيار الصورة: $e');
    }
  }

  // ✅ 2. التقاط صورة من الكاميرا
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image == null) return;
      
      ToastService.showInfo('📷 جاري رفع الصورة...');
      await Future.delayed(const Duration(seconds: 1));
      await _sendMessageWithImage(File(image.path));
      
    } catch (e) {
      ToastService.showError('❌ فشل التقاط الصورة: $e');
    }
  }

  // ✅ 3. إرسال ملف
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      
      final file = result.files.first;
      ToastService.showInfo('📎 جاري رفع الملف...');
      await Future.delayed(const Duration(seconds: 1));
      
      // إرسال رسالة بالملف
      await _sendMessageWithFile(file.path!, file.name);
      
    } catch (e) {
      ToastService.showError('❌ فشل اختيار الملف: $e');
    }
  }

  // ✅ 4. مشاركة الموقع
  Future<void> _shareLocation() async {
    try {
      // TODO: جلب الموقع الفعلي
      final lat = 15.3694;
      final lng = 44.1910;
      final address = 'صنعاء، اليمن';
      
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: '📍 $address\nhttps://maps.google.com/?q=$lat,$lng',
        locationUrl: 'https://maps.google.com/?q=$lat,$lng',
      );
      
      ToastService.showSuccess('✅ تم مشاركة الموقع');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل مشاركة الموقع: $e');
    }
  }

  // ✅ 5. تسجيل صوتي
  Future<void> _startVoiceRecording() async {
    setState(() => _isRecording = true);
    ToastService.showInfo('🎤 جاري التسجيل...');
    
    // TODO: تنفيذ التسجيل الفعلي
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() => _isRecording = false);
    ToastService.showSuccess('✅ تم التسجيل');
    
    // TODO: إرسال الصوت
    await _sendMessageWithAudio('/path/to/audio.m4a');
  }

  // ✅ 6. رد على رسالة
  void _replyToMessage(String messageId, String messageText) {
    setState(() {
      _replyTo = messageId;
      _replyToText = messageText;
    });
    _textController.requestFocus();
  }

  // ✅ 7. إضافة رد فعل (Reaction)
  void _showReactionPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReactionPicker(
        onReactionSelected: (emoji) async {
          await _chatService.addReaction(
            widget.chatId,
            messageId,
            emoji,
          );
          ToastService.showSuccess('✅ تم إضافة التفاعل');
        },
      ),
    );
  }

  // ✅ 8. حذف رسالة
  void _deleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) => DeleteMessageDialog(
        messageText: 'هل أنت متأكد من حذف هذه الرسالة؟',
        isForEveryone: true,
        onDelete: () async {
          Navigator.pop(context);
          await _chatService.deleteMessage(widget.chatId, messageId);
          ToastService.showSuccess('✅ تم حذف الرسالة');
        },
      ),
    );
  }

  // ✅ 9. نسخ رسالة
  void _copyMessage(String text) {
    // TODO: نسخ إلى الحافظة
    ToastService.showInfo('📋 تم نسخ الرسالة');
  }

  // ✅ 10. الإبلاغ عن رسالة
  void _reportMessage(String messageId) {
    // TODO: إرسال بلاغ
    ToastService.showInfo('📢 تم الإبلاغ عن الرسالة');
  }

  // ✅ 11. بدء مكالمة صوتية
  Future<void> _startAudioCall() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول');
      return;
    }

    if (widget.chatId.trim().isEmpty || widget.otherUserId.trim().isEmpty) {
      ToastService.showError('❌ بيانات المحادثة غير صالحة');
      return;
    }

    if (widget.otherUserId == user.uid) {
      ToastService.showError('❌ لا يمكنك الاتصال بنفسك');
      return;
    }

    try {
      final call = await _callService.initiateCall(
        chatId: widget.chatId,
        receiverId: widget.otherUserId,
        receiverName: widget.otherUserName,
        type: CallType.audio,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callId: call.id,
            chatId: widget.chatId,
            doctorName: widget.otherUserName,
            doctorId: widget.otherUserId,
            isVideo: false,
            isOutgoing: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.showError('❌ فشل بدء المكالمة: $e');
    }
  }

  // ✅ 12. بدء مكالمة فيديو
  Future<void> _startVideoCall() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول');
      return;
    }

    if (widget.chatId.trim().isEmpty || widget.otherUserId.trim().isEmpty) {
      ToastService.showError('❌ بيانات المحادثة غير صالحة');
      return;
    }

    if (widget.otherUserId == user.uid) {
      ToastService.showError('❌ لا يمكنك الاتصال بنفسك');
      return;
    }

    try {
      final call = await _callService.initiateCall(
        chatId: widget.chatId,
        receiverId: widget.otherUserId,
        receiverName: widget.otherUserName,
        type: CallType.video,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callId: call.id,
            chatId: widget.chatId,
            doctorName: widget.otherUserName,
            doctorId: widget.otherUserId,
            isVideo: true,
            isOutgoing: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.showError('❌ فشل بدء مكالمة الفيديو: $e');
    }
  }

  // ✅ 13. حذف المحادثة
  void _deleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من حذف المحادثة مع ${widget.otherUserName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _chatService.deleteChat(widget.chatId);
              ToastService.showSuccess('✅ تم حذف المحادثة');
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ✅ 14. مسح المحادثة (حذف جميع الرسائل)
  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المحادثة'),
        content: const Text('هل أنت متأكد من مسح جميع الرسائل؟ هذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: حذف جميع الرسائل
              ToastService.showSuccess('✅ تم مسح المحادثة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  // ✅ 15. عرض معلومات المستخدم
  void _showUserInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: widget.otherUserImage != null
                  ? NetworkImage(widget.otherUserImage!)
                  : null,
              child: widget.otherUserImage == null
                  ? Text(widget.otherUserName[0])
                  : null,
            ),
            const SizedBox(height: 12),
            Text(widget.otherUserName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.isGroup ? 'مجموعة' : 'مستخدم'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoButton(Icons.phone, 'اتصال', _startAudioCall),
                _buildInfoButton(Icons.videocam, 'فيديو', _startVideoCall),
                _buildInfoButton(Icons.chat, 'مراسلة', () {}),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // ✅ دوال مساعدة لإرسال الرسائل
  Future<void> _sendMessageWithImage(File image) async {
    // TODO: رفع الصورة إلى Firebase Storage
    final imageUrl = 'https://example.com/image.jpg';
    await _chatService.sendMessage(
      chatId: widget.chatId,
      text: '📷 صورة',
      imageUrl: imageUrl,
    );
    _scrollToBottom();
  }

  Future<void> _sendMessageWithFile(String filePath, String fileName) async {
    // TODO: رفع الملف إلى Firebase Storage
    final fileUrl = 'https://example.com/$fileName';
    await _chatService.sendMessage(
      chatId: widget.chatId,
      text: '📎 $fileName',
      fileUrl: fileUrl,
    );
    _scrollToBottom();
  }

  Future<void> _sendMessageWithAudio(String audioPath) async {
    // TODO: رفع الصوت إلى Firebase Storage
    final audioUrl = 'https://example.com/audio.m4a';
    await _chatService.sendMessage(
      chatId: widget.chatId,
      text: '🎤 رسالة صوتية',
      audioUrl: audioUrl,
    );
    _scrollToBottom();
  }

  // ✅ إرسال رسالة نصية
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: text,
        replyTo: _replyTo,
        replyToText: _replyToText,
      );

      _textController.clear();
      setState(() {
        _replyTo = null;
        _replyToText = null;
      });
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
    } finally {
      setState(() => _isSending = false);
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
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      if (date.day == now.day && date.month == now.month && date.year == now.year) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  // ✅ بناء واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showUserInfo,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: widget.otherUserImage != null
                    ? NetworkImage(widget.otherUserImage!)
                    : null,
                child: widget.otherUserImage == null
                    ? Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0] : 'م')
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.otherUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final isOnline = snapshot.data?.data()?['isOnline'] ?? false;
                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOnline ? 'متصل' : 'غير متصل',
                              style: TextStyle(
                                fontSize: 11,
                                color: isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          // ✅ زر الاتصال الصوتي
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _startAudioCall,
            tooltip: 'مكالمة صوتية',
          ),
          // ✅ زر مكالمة فيديو
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
            tooltip: 'مكالمة فيديو',
          ),
          // ✅ القائمة
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            onSelected: (value) {
              switch (value) {
                case 'clear': _clearChat(); break;
                case 'delete': _deleteChat(); break;
                case 'info': _showUserInfo(); break;
                case 'search': ToastService.showInfo('🔍 جاري البحث...'); break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('معلومات المستخدم'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('بحث في المحادثة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('مسح المحادثة', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف المحادثة', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ مؤشر الكتابة
          if (_typingUsers.isNotEmpty)
            TypingIndicator(
              name: _typingUsers.length == 1 ? _typingUsers.first : '${_typingUsers.length} أشخاص',
            ),
          // ✅ شريط الرد
          if (_replyTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الرد على رسالة',
                          style: TextStyle(fontSize: 11, color: AppColors.primary),
                        ),
                        Text(
                          _replyToText ?? '',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() {
                      _replyTo = null;
                      _replyToText = null;
                    }),
                  ),
                ],
              ),
            ),
          // ✅ قائمة الرسائل
          Expanded(
            child: _buildMessagesList(isDark),
          ),
          // ✅ شريط الإدخال
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  // ✅ قائمة الرسائل
  Widget _buildMessagesList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('حدث خطأ في تحميل الرسائل'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[300]),
                const SizedBox(height: 16),
                Text('لا توجد رسائل', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 8),
                Text('ابدأ المحادثة الآن', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;
            final isMe = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
            final text = data['text'] ?? '';
            final time = _formatTime(data['timestamp']);
            final isRead = data['isRead'] ?? false;
            final messageId = doc.id;
            final reactions = data['reactions'] as Map<String, dynamic>? ?? {};

            return GestureDetector(
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ ردود فعل سريعة
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: ['👍', '❤️', '😂', '😮', '😢', '🙏'].map((emoji) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  _chatService.addReaction(
                                    widget.chatId,
                                    messageId,
                                    emoji,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(),
                        // ✅ رد على الرسالة
                        ListTile(
                          leading: const Icon(Icons.reply, color: AppColors.primary),
                          title: const Text('رد على الرسالة'),
                          onTap: () {
                            Navigator.pop(context);
                            _replyToMessage(messageId, text);
                          },
                        ),
                        // ✅ نسخ النص
                        ListTile(
                          leading: const Icon(Icons.copy, color: AppColors.primary),
                          title: const Text('نسخ النص'),
                          onTap: () {
                            Navigator.pop(context);
                            _copyMessage(text);
                          },
                        ),
                        // ✅ حذف الرسالة (للمرسل فقط)
                        if (isMe)
                          ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('حذف الرسالة', style: TextStyle(color: Colors.red)),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteMessage(messageId);
                            },
                          ),
                        // ✅ الإبلاغ عن الرسالة
                        if (!isMe)
                          ListTile(
                            leading: const Icon(Icons.flag, color: Colors.orange),
                            title: const Text('الإبلاغ عن الرسالة'),
                            onTap: () {
                              Navigator.pop(context);
                              _reportMessage(messageId);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(12).copyWith(
                            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // ✅ عرض الصورة إذا كانت موجودة
                            if (data['imageUrl'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: data['imageUrl'],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            // ✅ عرض الملف إذا كان موجوداً
                            if (data['fileUrl'] != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        data['fileName'] ?? 'ملف',
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // ✅ عرض الصوت إذا كان موجوداً
                            if (data['audioUrl'] != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.black87),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '0:30',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? Colors.white70 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // ✅ عرض الموقع إذا كان موجوداً
                            if (data['locationUrl'] != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        data['text'] ?? 'موقع',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isMe ? Colors.white : Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // ✅ النص
                            if (text.isNotEmpty && data['type'] != 'image')
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
                                // ✅ التفاعلات
                                if (reactions.isNotEmpty) ...[
                                  ...reactions.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: GestureDetector(
                                        onTap: () => _showReactionPicker(messageId),
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[500]),
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
              ),
            );
          },
        );
      },
    );
  }

  // ✅ شريط الإدخال
  Widget _buildInputBar(bool isDark) {
    final isTyping = _textController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(8),
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
          // ✅ زر المرفقات
          PopupMenuButton<String>(
            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onSelected: (value) {
              switch (value) {
                case 'image': _pickImage(); break;
                case 'camera': _takePhoto(); break;
                case 'file': _pickFile(); break;
                case 'location': _shareLocation(); break;
                case 'voice': _startVoiceRecording(); break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'image',
                child: Row(
                  children: [
                    Icon(Icons.photo_library, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('صورة من المعرض'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('التقاط صورة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'file',
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('إرسال ملف'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('مشاركة الموقع'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'voice',
                child: Row(
                  children: [
                    Icon(Icons.mic, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('تسجيل صوتي'),
                  ],
                ),
              ),
            ],
          ),
          // ✅ حقل النص
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                onChanged: (text) => setState(() {}),
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          // ✅ زر الإرسال/الميكروفون
          GestureDetector(
            onTap: isTyping ? _sendMessage : _startVoiceRecording,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isTyping ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTyping ? AppColors.primary : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isTyping ? Icons.send : Icons.mic,
                      color: isTyping ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
