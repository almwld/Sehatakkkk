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
import 'widgets/chat_background.dart';
import 'widgets/reply_banner.dart';
import 'widgets/message_reactions.dart';
import 'widgets/media_viewer.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/contact_info_sheet.dart';
import 'package:sehatak/core/services/location_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final LocationService _locationService = LocationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  bool _isTyping = false;
  bool _isRecording = false;
  String? _recordingPath;
  bool _showVoiceRecorder = false;

  // ✅ معلومات الطبيب
  Map<String, dynamic> _doctorInfo = {};
  bool _isLoadingDoctor = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    _markAsRead();
    _playNotificationSound();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/notification.mp3'));
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  Future<void> _loadDoctorInfo() async {
    setState(() => _isLoadingDoctor = true);
    try {
      // ✅ جلب معلومات الطبيب من Firestore
      final snapshot = await _firestore
          .collection('doctors')
          .where('name', isEqualTo: widget.userName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _doctorInfo = snapshot.docs.first.data();
      } else {
        // ✅ بيانات افتراضية
        _doctorInfo = {
          'name': widget.userName,
          'specialty': 'طبيب عام',
          'rating': 4.9,
          'reviews': 328,
          'experience': '10+ سنة',
          'image': ImageKit.doctor1,
          'available': true,
        };
      }
    } catch (e) {
      print('❌ Error loading doctor info: $e');
      _doctorInfo = {
        'name': widget.userName,
        'specialty': 'طبيب عام',
        'rating': 4.9,
        'reviews': 328,
        'experience': '10+ سنة',
        'image': ImageKit.doctor1,
        'available': true,
      };
    }
    setState(() => _isLoadingDoctor = false);
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

      // ✅ تحديث unreadCount
      await _firestore.collection('chats').doc(widget.chatId).update({
        'unreadCount.${_auth.currentUser?.uid}': 0,
      });
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

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

      setState(() {
        _replyToMessage = null;
        _replyToMessageId = null;
        _isTyping = false;
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
    }
  }

  void _sendImage(String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final file = File(imagePath);
      final ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
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

  void _shareLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      
      if (position == null) {
        ToastService.showError('❌ لا يمكن الحصول على الموقع');
        return;
      }

      final address = await _locationService.getAddressFromLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final user = _auth.currentUser;
      if (user == null) return;

      final messageData = {
        'text': '📍 $address',
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'location',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'isRead': false,
      };

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📍 تم مشاركة موقع',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ToastService.showSuccess('✅ تم مشاركة الموقع');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل مشاركة الموقع: $e');
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

  void _showReactions(String messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageReactions(
        currentReactions: [],
        onReactionSelected: (emoji) {
          _addReaction(messageId, emoji);
        },
      ),
    );
  }

  void _addReaction(String messageId, String emoji) async {
    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions': FieldValue.arrayUnion([emoji]),
      });
    } catch (e) {
      print('❌ Error adding reaction: $e');
    }
  }

  void _deleteMessage(String messageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل أنت متأكد من حذف هذه الرسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .doc(messageId)
                  .delete();
              ToastService.showSuccess('✅ تم حذف الرسالة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _copyMessage(String text) {
    ToastService.showSuccess('✅ تم نسخ النص');
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
        title: GestureDetector(
          onTap: _showContactInfo,
          child: Row(
            children: [
              // ✅ صورة الطبيب (صورة واحدة فقط - محلية)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(_doctorInfo['image'] ?? ImageKit.doctor1),
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _doctorInfo['specialty'] ?? 'طبيب عام',
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
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
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          // ✅ زر مكالمة صوتية
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
            tooltip: 'مكالمة صوتية',
          ),
          // ✅ زر مكالمة فيديو
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
            tooltip: 'مكالمة فيديو',
          ),
          // ✅ زر القائمة
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'contact':
                  _showContactInfo();
                  break;
                case 'search':
                  ToastService.showInfo('🔍 بحث في المحادثة');
                  break;
                case 'mute':
                  ToastService.showSuccess('🔇 تم كتم الإشعارات');
                  break;
                case 'delete':
                  _deleteChat();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('معلومات جهة الاتصال'),
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
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('كتم الإشعارات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف المحادثة', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ChatBackground(
        child: Column(
          children: [
            if (_replyToMessage != null)
              ReplyBanner(
                message: _replyToMessage?['text'] ?? '',
                senderName: _replyToMessage?['senderName'] ?? 'مستخدم',
                onCancel: () => setState(() {
                  _replyToMessage = null;
                  _replyToMessageId = null;
                }),
              ),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'حدث خطأ في تحميل الرسائل',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'يرجى المحاولة مرة أخرى',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
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
            ChatInputBar(
              chatId: widget.chatId,
              onSendMessage: _sendMessage,
              onSendImage: _sendImage,
              onShareLocation: _shareLocation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, String messageId, bool isMe, bool isDark) {
    final text = message['text'] ?? '';
    final type = message['type'] ?? 'text';
    final imageUrl = message['imageUrl'];
    final audioUrl = message['audioUrl'];
    final time = _formatTime(message['timestamp'] as Timestamp?);
    final isRead = message['isRead'] as bool? ?? false;
    final reactions = List<String>.from(message['reactions'] ?? []);
    final replyToText = message['replyToText'];
    final replyToSender = message['replyToSender'];

    return GestureDetector(
      onLongPress: () => _showMessageOptions(messageId, text, isMe),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
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
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (type == 'image' && imageUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediaViewer(
                            mediaUrl: imageUrl,
                            mediaType: 'image',
                          ),
                        ),
                      );
                    }
                    if (type == 'audio' && audioUrl != null) {
                      ToastService.showInfo('🎵 تشغيل الصوت...');
                    }
                  },
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          ),
                        if (type == 'audio' && audioUrl != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: isMe ? Colors.white : AppColors.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '🎤 رسالة صوتية',
                                style: TextStyle(
                                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                            ],
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
                        if (reactions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A2540) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: reactions.map((emoji) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Text(emoji, style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(String messageId, String text, bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _reactionOption('👍'),
                  _reactionOption('❤️'),
                  _reactionOption('😂'),
                  _reactionOption('😮'),
                  _reactionOption('😢'),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.reply, color: AppColors.primary),
                title: const Text('رد'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyToMessage = {'text': text, 'senderName': 'مستخدم'};
                    _replyToMessageId = messageId;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: AppColors.primary),
                title: const Text('نسخ'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(text);
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('حذف', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(messageId);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reactionOption(String emoji) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  void _showContactInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactInfoSheet(
        name: widget.userName,
        phone: _doctorInfo['phone'] ?? '+967 777 777 777',
        imageUrl: _doctorInfo['image'] ?? ImageKit.doctor1,
      ),
    );
  }

  void _deleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل أنت متأكد من حذف هذه المحادثة؟ سيتم حذف جميع الرسائل.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ToastService.showSuccess('✅ تم حذف المحادثة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
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
