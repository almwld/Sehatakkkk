import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/reply_banner.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/core/services/location_service.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final bool isGroup;
  final String? groupImage;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.isGroup = false,
    this.groupImage,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();

  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  bool _isTyping = false;
  bool _isLoading = true;
  List<String> _typingUsers = [];
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _markMessagesAsRead();
    _listenToTyping();
    _checkUserStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
      _updateOnlineStatus(true);
    } else if (state == AppLifecycleState.paused) {
      _updateOnlineStatus(false);
    }
  }

  void _updateOnlineStatus(bool isOnline) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('⚠️ Status update error: $e');
    }
  }

  void _checkUserStatus() {
    _firestore
        .collection('users')
        .doc(widget.otherUserId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            setState(() {
              _isOnline = data?['isOnline'] ?? false;
            });
          }
        });
  }

  void _listenToTyping() {
    _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            final typing = data?['typing'] as Map? ?? {};
            final users = typing.entries
                .where((e) => e.value == true)
                .map((e) => e.key)
                .where((id) => id != _auth.currentUser?.uid)
                .toList();
            setState(() => _typingUsers = users);
          }
        });
  }

  void _markMessagesAsRead() async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: _auth.currentUser?.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      await _firestore.collection('chats').doc(widget.chatId).update({
        'unreadCount.${_auth.currentUser?.uid}': 0,
      });
    } catch (e) {
      print('⚠️ Mark as read error: $e');
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final messageData = {
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'senderPhotoUrl': user.photoURL,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'isRead': false,
        'isDelivered': false,
        'replyToId': _replyToMessageId,
        'replyToText': _replyToMessage?['text'],
        'replyToSender': _replyToMessage?['senderName'],
        'reactions': {},
      };

      final batch = _firestore.batch();
      final messageRef = _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc();

      batch.set(messageRef, messageData);

      batch.update(_firestore.collection('chats').doc(widget.chatId), {
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث unreadCount للمشاركين الآخرين
      final chatDoc = await _firestore.collection('chats').doc(widget.chatId).get();
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      for (final pid in participants) {
        if (pid != user.uid) {
          batch.update(_firestore.collection('chats').doc(widget.chatId), {
            'unreadCount.$pid': FieldValue.increment(1),
          });
        }
      }

      await batch.commit();

      setState(() {
        _replyToMessage = null;
        _replyToMessageId = null;
        _isTyping = false;
      });
      _textController.clear();
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
    }
  }

  void _sendImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      final messageData = {
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'senderPhotoUrl': user.photoURL,
        'text': '📷 صورة',
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'image',
        'isRead': false,
        'isDelivered': false,
        'reactions': {},
      };

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📷 صورة',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _scrollToBottom();
      ToastService.showSuccess('✅ تم إرسال الصورة');
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الصورة: $e');
    }
  }

  void _shareLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;

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

      final messageData = {
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'senderPhotoUrl': user.photoURL,
        'text': '📍 $address',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'location',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'isRead': false,
        'isDelivered': false,
        'reactions': {},
      };

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📍 تم مشاركة موقع',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ToastService.showSuccess('✅ تم مشاركة الموقع');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل مشاركة الموقع: $e');
    }
  }

  void _startCall(bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: widget.chatId,
          doctorName: widget.otherUserName,
          doctorId: widget.otherUserId,
          isVideo: isVideo,
        ),
      ),
    );
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
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  Widget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      title: GestureDetector(
        onTap: () => ToastService.showInfo('👤 معلومات جهة الاتصال'),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.groupImage != null
                      ? CachedNetworkImageProvider(widget.groupImage!)
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: widget.groupImage == null
                      ? Text(
                          widget.otherUserName.isNotEmpty
                              ? widget.otherUserName[0].toUpperCase()
                              : 'م',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (_isOnline && !widget.isGroup)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isGroup ? 'المجموعة' : widget.otherUserName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _typingUsers.isNotEmpty
                        ? 'يكتب...'
                        : _isOnline && !widget.isGroup
                            ? 'متصل'
                            : 'غير متصل',
                    style: TextStyle(
                      fontSize: 11,
                      color: _typingUsers.isNotEmpty
                          ? AppColors.primary
                          : (_isOnline ? Colors.green : (isDark ? Colors.grey[500] : Colors.grey[500])),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!widget.isGroup)
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
            tooltip: 'مكالمة صوتية',
          ),
        if (!widget.isGroup)
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
            tooltip: 'مكالمة فيديو',
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
          onSelected: (value) {
            switch (value) {
              case 'search':
                ToastService.showInfo('🔍 بحث في المحادثة');
                break;
              case 'mute':
                ToastService.showSuccess('🔇 تم كتم الإشعارات');
                break;
              case 'clear':
                ToastService.showInfo('🗑️ تم مسح المحادثة');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search, size: 18),
                  SizedBox(width: 8),
                  Text('بحث'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(Icons.volume_off, size: 18),
                  SizedBox(width: 8),
                  Text('كتم الإشعارات'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('مسح المحادثة', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDark),
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
            if (_typingUsers.isNotEmpty)
              const TypingIndicator(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final data = message.data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == _auth.currentUser?.uid;

                      return MessageBubble(
                        message: data,
                        messageId: message.id,
                        isMe: isMe,
                        onReply: () {
                          setState(() {
                            _replyToMessage = data;
                            _replyToMessageId = message.id;
                          });
                        },
                        onDelete: () {
                          _firestore
                              .collection('chats')
                              .doc(widget.chatId)
                              .collection('messages')
                              .doc(message.id)
                              .delete();
                          ToastService.showSuccess('✅ تم حذف الرسالة');
                        },
                        onReaction: (emoji) {
                          _firestore
                              .collection('chats')
                              .doc(widget.chatId)
                              .collection('messages')
                              .doc(message.id)
                              .update({
                            'reactions': FieldValue.arrayUnion([emoji]),
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            ChatInputBar(
              chatId: widget.chatId,
              onSendMessage: _sendMessage,
              onSendImage: (path) => _sendImage(File(path)),
              onShareLocation: _shareLocation,
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
            color: isDark ? Colors.grey[600] : Colors.grey[400],
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
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
