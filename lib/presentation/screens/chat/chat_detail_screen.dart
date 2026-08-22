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
import 'package:sehatak/presentation/screens/chat/widgets/reaction_picker.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'dart:io';
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
        _sendTypingStatus(true);
      });
    } else {
      _sendTypingStatus(false);
    }
  }

  void _sendTypingStatus(bool isTyping) {
    // TODO: إرسال حالة الكتابة إلى Firestore
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
        'reactions': {},
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

  void _addReaction(String messageId, String emoji) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId);

      await messageRef.update({
        'reactions.${_auth.currentUser?.uid}': emoji,
      });
      
      setState(() => _selectedReactionMessageId = null);
      ToastService.showSuccess('✅ تم إضافة التفاعل');
    } catch (e) {
      ToastService.showError('❌ فشل إضافة التفاعل');
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      final user = _auth.currentUser;
      if (user == null) return;

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
      ToastService.showSuccess('✅ تم إرسال الصورة');
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الصورة: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordingDuration += const Duration(seconds: 1));
        });
      }
    } catch (e) {
      ToastService.showError('❌ فشل بدء التسجيل: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _showVoiceRecorder = false;
    });
    if (path != null) {
      ToastService.showSuccess('✅ تم تسجيل الصوت بنجاح');
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
                ToastService.showInfo('📷 جاري فتح الكاميرا...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                ToastService.showInfo('📎 جاري إرسال الملف...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: AppColors.primary),
              title: const Text('تسجيل صوتي'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _showVoiceRecorder = true);
              },
            ),
          ],
        ),
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
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: _showDoctorInfo,
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
              child: Column(
                children: [
                  if (_replyToMessage != null)
                    _buildReplyBanner(isDark),
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

                            return _buildMessageBubble(data, message.id, isMe, isDark);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ✅ مؤشر الكتابة (Typing Indicator)
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chats')
                .doc(widget.chatId)
                .collection('typing')
                .where('isTyping', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }
              final typingUsers = snapshot.data!.docs.map((doc) {
                return doc.data()['userName'] as String?;
              }).where((name) => name != null && name != _auth.currentUser?.displayName).toList();

              if (typingUsers.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TypingIndicator(name: typingUsers.first),
              );
            },
          ),
          // ✅ حقل الإدخال
          Container(
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
            child: _showVoiceRecorder
                ? _buildVoiceRecorder(isDark)
                : _buildInputField(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner(bool isDark) {
    return Container(
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
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, String messageId, bool isMe, bool isDark) {
    final text = message['text'] ?? '';
    final type = message['type'] ?? 'text';
    final imageUrl = message['imageUrl'];
    final time = _formatTime(message['timestamp'] as Timestamp?);
    final isRead = message['isRead'] as bool? ?? false;
    final reactions = message['reactions'] as Map<String, dynamic>? ?? {};
    final replyToText = message['replyToText'];
    final replyToSender = message['replyToSender'];
    final isSelectedForReaction = _selectedReactionMessageId == messageId;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectedReactionMessageId = isSelectedForReaction ? null : messageId;
        });
      },
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ✅ رسالة مقتبسة (Reply)
          if (replyToText != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  right: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الرد على $replyToSender',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    replyToText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          // ✅ فقاعة الرسالة
          Row(
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
                      if (type == 'image' && imageUrl != null)
                        GestureDetector(
                          onTap: () => _showFullScreenImage(imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          ),
                        ),
                      if (type == 'text' || (type == 'image' && text != '📷 صورة'))
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
          // ✅ ردود الفعل (Reactions)
          if (reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Wrap(
                spacing: 4,
                children: reactions.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          // ✅ Reaction Picker (عند الضغط الطويل)
          if (isSelectedForReaction)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ReactionPicker(
                onReactionSelected: (emoji) => _addReaction(messageId, emoji),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          onPressed: _showAttachmentOptions,
        ),
        IconButton(
          icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          onPressed: _sendImage,
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
          onPressed: () {
            setState(() => _showVoiceRecorder = true);
          },
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
    );
  }

  Widget _buildVoiceRecorder(bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              _showVoiceRecorder = false;
              _isRecording = false;
            });
            _recorder.stop();
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202c33) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isRecording
                          ? 'تسجيل... ${_recordingDuration.inSeconds}s'
                          : 'اضغط للتسجيل',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  if (_isRecording)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white),
          ),
        ),
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
