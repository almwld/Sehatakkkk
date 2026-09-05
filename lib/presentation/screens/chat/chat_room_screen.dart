import package:sehatak/presentation/screens/patient/patient_profile.dart;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/bloc/messages/messages_bloc.dart';
import 'package:sehatak/bloc/chat/chat_bloc.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/core/services/location_service.dart';

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

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();

  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  List<String> _typingUsers = [];
  bool _isOnline = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
    _listenToTyping();
    _checkUserStatus();
    _checkMuteStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
            setState(() { _typingUsers = List<String>.from(users); });
          }
        });
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

  void _checkMuteStatus() {
    _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            setState(() {
              _isMuted = data?['isMuted'] ?? false;
            });
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

  void _startCall(bool isVideo) {

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
    Navigator.push(

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
      context,

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
      MaterialPageRoute(

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
        builder: (_) => CallScreen(

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
          chatId: widget.chatId,

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
          doctorName: widget.otherUserName,

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
          doctorId: widget.otherUserId,

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
          isVideo: isVideo,

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
        ),

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
      ),

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
    );

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }
  }

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(
          userId: widget.otherUserId,
        ),
      ),
    );
  }

  // ✅ تفعيل زر البحث
  void _searchInChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 بحث في المحادثة'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'اكتب كلمة البحث...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            ToastService.showInfo('🔍 جاري البحث عن: $value');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  // ✅ تفعيل زر كتم الإشعارات
  void _toggleMute() {
    final newMute = !_isMuted;
    _firestore.collection('chats').doc(widget.chatId).update({
      'isMuted': newMute,
    });
    setState(() => _isMuted = newMute);
    ToastService.showSuccess(
      newMute ? '🔇 تم كتم الإشعارات' : '🔊 تم إلغاء كتم الإشعارات'
    );
  }

  // ✅ تفعيل زر مسح المحادثة
  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ مسح المحادثة'),
        content: const Text('هل أنت متأكد من مسح جميع رسائل هذه المحادثة؟'),
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
                  .get()
                  .then((snapshot) {
                    final batch = _firestore.batch();
                    for (var doc in snapshot.docs) {
                      batch.delete(doc.reference);
                    }
                    batch.commit();
                  });
              ToastService.showInfo('🗑️ تم مسح جميع الرسائل');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  // ✅ تفعيل زر مشاركة الموقع
  Future<void> _shareLocation() async {
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

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
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
          });

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

  // ✅ تفعيل زر إرسال الصورة
  Future<void> _sendImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;

      final user = _auth.currentUser;
      if (user == null) return;

      final file = File(image.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
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
          });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📷 صورة',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ToastService.showSuccess('✅ تم إرسال الصورة');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الصورة: $e');
    }
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
              _buildReplyBanner(),
            if (_typingUsers.isNotEmpty)
              TypingIndicator(name: _typingUsers.isNotEmpty ? _typingUsers.first : ""),
            Expanded(
              child: BlocBuilder<MessagesBloc, MessagesState>(
                builder: (context, state) {
                  if (state is MessagesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MessagesError) {
                    return _buildErrorState(isDark);
                  }
                  if (state is MessagesLoaded) {
                    final messages = state.messages;
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
                        final isMe = message.senderId == _auth.currentUser?.uid;
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          onReply: () {
                            setState(() {
                              _replyToMessage = message as Map<String, dynamic>?;
                              _replyToMessageId = message.id;
                            });
                          },
                          onDelete: () {
                            context.read<MessagesBloc>().add(
                              DeleteMessage(
                                chatId: widget.chatId,
                                messageId: message.id,
                              ),
                            );
                          },
                          onReaction: (emoji) {
                            context.read<MessagesBloc>().add(
                              AddReaction(
                                chatId: widget.chatId,
                                messageId: message.id,
                                emoji: emoji,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            ChatInputBar(
              chatId: widget.chatId,
              onSendMessage: (text) {
                context.read<MessagesBloc>().add(
                  SendMessage(
                    chatId: widget.chatId,
                    text: text,
                    replyToId: _replyToMessageId,
                  ),
                );
                setState(() {
                  _replyToMessage = null;
                  _replyToMessageId = null;
                });
                _textController.clear();
                _scrollToBottom();
              },
              onSendImage: (String path) { _sendImage(); },
              onShareLocation: _shareLocation,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      title: GestureDetector(
        onTap: () => _showContactInfo(),
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
        // ✅ زر مكالمة صوتية - مفعل
        if (!widget.isGroup)
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
            tooltip: 'مكالمة صوتية',
          ),
        // ✅ زر مكالمة فيديو - مفعل
        if (!widget.isGroup)
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
            tooltip: 'مكالمة فيديو',
          ),
        // ✅ زر القائمة - مفعل بالكامل
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
          onSelected: (value) {
            switch (value) {
              case 'search':
                _searchInChat();
                break;
              case 'mute':
                _toggleMute();
                break;
              case 'clear':
                _clearChat();
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
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(_isMuted ? Icons.volume_up : Icons.volume_off, size: 18),
                  SizedBox(width: 8),
                  Text(_isMuted ? 'إلغاء الكتم' : 'كتم الإشعارات'),
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

  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2540)
            : Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.reply, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرد على ${_replyToMessage?['senderName'] ?? 'مستخدم'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _replyToMessage?['text'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _replyToMessage = null;
                _replyToMessageId = null;
              });
            },
            child: Icon(Icons.close, size: 16),
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

  Widget _buildErrorState(bool isDark) {
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
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
