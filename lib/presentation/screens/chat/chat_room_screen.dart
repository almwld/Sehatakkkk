import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final bool isGroup;
  final String? groupImage;
  final String? lastMessage;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    this.isGroup = false,
    this.groupImage,
    this.lastMessage,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chat = ChatService();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _chatSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  List<MessageModel> _messages = [];
  bool _loading = true;
  bool _online = false;
  bool _muted = false;
  bool _pinned = false;

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      _firestore.collection('chats').doc(widget.chatId).collection('messages');

  @override
  void initState() {
    super.initState();
    _listen();
    _markRead();
  }

  void _listen() {
    _chatSub = _firestore.collection('chats').doc(widget.chatId).snapshots().listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      final data = snapshot.data() ?? <String, dynamic>{};
      setState(() {
        _muted = data['isMuted'] == true;
        _pinned = data['isPinned'] == true;
      });
    });

    _userSub = _firestore.collection('users').doc(widget.otherUserId).snapshots().listen((snapshot) {
      if (mounted) setState(() => _online = snapshot.data()?['isOnline'] == true);
    });

    _messagesSub = _messagesRef
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
          .toList();
      setState(() {
        _messages = messages;
        _loading = false;
      });
      _markRead();
    }, onError: (error) {
      debugPrint('chat stream: $error');
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _markRead() async {
    try {
      await _chat.markAsRead(widget.chatId);
    } catch (error) {
      debugPrint('mark read: $error');
    }
  }

  void _call(bool video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: widget.chatId,
          doctorName: widget.otherUserName,
          doctorId: widget.otherUserId,
          doctorImage: widget.otherUserImage ?? widget.groupImage,
          isVideo: video,
          isOutgoing: true,
        ),
      ),
    );
  }

  void _profile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ChatContactProfile(
          userId: widget.otherUserId,
          name: widget.otherUserName,
          imageUrl: widget.otherUserImage ?? widget.groupImage,
        ),
      ),
    );
  }

  Future<void> _toggleMute() async {
    try {
      await _chat.muteChat(widget.chatId, !_muted);
    } catch (error) {
      debugPrint('mute chat: $error');
    }
  }

  Future<void> _togglePin() async {
    try {
      await _chat.pinChat(widget.chatId, !_pinned);
    } catch (error) {
      debugPrint('pin chat: $error');
    }
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _chatSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final image = widget.otherUserImage ?? widget.groupImage;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF2F5F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF101827) : Colors.white,
        leading: const BackButton(),
        titleSpacing: 0,
        title: InkWell(
          onTap: _profile,
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.primary.withOpacity(.12),
                backgroundImage: image != null ? CachedNetworkImageProvider(image) : null,
                child: image == null
                    ? Text(widget.otherUserName.isEmpty ? 'م' : widget.otherUserName.characters.first)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isGroup ? 'المجموعة' : widget.otherUserName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _online ? 'متصل الآن' : 'غير متصل',
                      style: TextStyle(fontSize: 11, color: _online ? Colors.green : Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!widget.isGroup)
            IconButton(onPressed: () => _call(false), icon: const Icon(Icons.call_rounded)),
          if (!widget.isGroup)
            IconButton(onPressed: () => _call(true), icon: const Icon(Icons.videocam_rounded)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mute') _toggleMute();
              if (value == 'pin') _togglePin();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'mute',
                child: Text(_muted ? 'إلغاء كتم الإشعارات' : 'كتم الإشعارات'),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Text(_pinned ? 'إلغاء تثبيت المحادثة' : 'تثبيت المحادثة'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('ابدأ المحادثة'))
                    : ChatBackground(
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: _messages.length,
                          itemBuilder: (_, index) {
                            final message = _messages[index];
                            return MessageBubble(
                              key: ValueKey(message.id),
                              message: message.toFirestore(),
                              isMe: message.senderId == _auth.currentUser?.uid,
                              onCallAgain: (_) => _call(false),
                              onReaction: (emoji) => _chat.addReaction(
                                widget.chatId,
                                message.id,
                                emoji,
                              ),
                            );
                          },
                        ),
                      ),
          ),
          ChatInputBar(
            chatId: widget.chatId,
            onSendMessage: (_) {},
            onSendImage: (_) {},
          ),
        ],
      ),
    );
  }
}

class _ChatContactProfile extends StatelessWidget {
  final String userId;
  final String name;
  final String? imageUrl;

  const _ChatContactProfile({
    required this.userId,
    required this.name,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? <String, dynamic>{};
          final image = imageUrl ?? data['photoUrl']?.toString() ?? data['imageUrl']?.toString();
          final displayName = data['name']?.toString() ?? data['displayName']?.toString() ?? name;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: image != null ? CachedNetworkImageProvider(image) : null,
                    child: image == null ? const Icon(Icons.person, size: 52) : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if ('${data['specialty'] ?? ''}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(data['specialty'].toString()),
                    ),
                  if ('${data['bio'] ?? ''}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(data['bio'].toString(), textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
