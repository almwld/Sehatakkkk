import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/bloc/messages/messages_bloc.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:sehatak/core/services/location_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';

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
  final TextEditingController _textController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final ImagePicker _picker =
      ImagePicker();

  final LocationService _locationService =
      LocationService();

  String? _replyToMessageId;
  MessageModel? _replyToMessage;

  List<String> _typingUsers = [];

  bool _isOnline = false;
  bool _isMuted = false;
  bool _isLoadingMore = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _typingSubscription;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userStatusSubscription;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _muteSubscription;

  @override
  void initState() {
    super.initState();

    context.read<MessagesBloc>().add(
          LoadMessages(
            chatId: widget.chatId,
            limit: 30,
          ),
        );

    _scrollController.addListener(_onScroll);

    _listenToTyping();
    _checkUserStatus();
    _checkMuteStatus();
  }

  @override
  void dispose() {
    _typingSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _muteSubscription?.cancel();

    _textController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // 📜 Pagination
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.maxScrollExtent <= 0) {
      return;
    }

    if (position.pixels >=
        position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    if (_isLoadingMore) {
      return;
    }

    final bloc = context.read<MessagesBloc>();
    final state = bloc.state;

    if (state is! MessagesLoaded) {
      return;
    }

    if (!state.hasMore) {
      return;
    }

    if (state.isLoadingMore) {
      return;
    }

    _isLoadingMore = true;

    bloc.add(
      LoadMoreMessages(
        chatId: widget.chatId,
        limit: 30,
      ),
    );
  }

  // ============================================================
  // ⌨️ مؤشر الكتابة
  // ============================================================

  void _listenToTyping() {
    _typingSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted || !snapshot.exists) {
          return;
        }

        final data = snapshot.data();

        final rawTyping = data?['typing'];

        final Map typing = rawTyping is Map
            ? rawTyping
            : <dynamic, dynamic>{};

        final users = typing.entries
            .where(
              (entry) => entry.value == true,
            )
            .map(
              (entry) => entry.key.toString(),
            )
            .where(
              (id) =>
                  id != _auth.currentUser?.uid,
            )
            .toList();

        setState(() {
          _typingUsers = users;
        });
      },
    );
  }

  // ============================================================
  // 🟢 حالة المستخدم
  // ============================================================

  void _checkUserStatus() {
    _userStatusSubscription = _firestore
        .collection('users')
        .doc(widget.otherUserId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted || !snapshot.exists) {
          return;
        }

        final data = snapshot.data();

        setState(() {
          _isOnline =
              data?['isOnline'] == true;
        });
      },
    );
  }

  // ============================================================
  // 🔇 حالة الكتم
  // ============================================================

  void _checkMuteStatus() {
    _muteSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted || !snapshot.exists) {
          return;
        }

        final data = snapshot.data();

        setState(() {
          _isMuted =
              data?['isMuted'] == true;
        });
      },
    );
  }

  // ============================================================
  // ⬇️ التمرير لآخر رسالة
  // ============================================================

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (!mounted) {
          return;
        }

        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // ============================================================
  // 📞 حفظ رسالة المكالمة
  // ============================================================

  Future<void> _saveCallMessage(
    bool isVideo,
  ) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return;
      }

      final message = isVideo
          ? '📹 مكالمة فيديو'
          : '📞 مكالمة صوتية';

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName':
            user.displayName ?? 'مستخدم',
        'senderPhotoUrl': user.photoURL,
        'text': message,
        'timestamp':
            FieldValue.serverTimestamp(),

        // MessageModel يدعم system.
        'type': 'system',

        // توافق إضافي.
        'callType':
            isVideo ? 'video' : 'audio',

        'metadata': {
          'callType':
              isVideo ? 'video' : 'audio',
        },

        'isRead': false,
        'isDelivered': false,
        'isDeleted': false,
        'isEdited': false,
        'reactions': {},
      });

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage': message,
        'lastMessageTime':
            FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(
        '❌ فشل حفظ رسالة النظام: $e',
      );
    }
  }

  // ============================================================
  // 📞 بدء المكالمة
  // ============================================================

  void _startCall(bool isVideo) {
    _saveCallMessage(isVideo);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId:
              'call_${DateTime.now().millisecondsSinceEpoch}',
          doctorName:
              widget.otherUserName,
          doctorId:
              widget.otherUserId,
          isVideo: isVideo,
        ),
      ),
    );
  }

  // ============================================================
  // 👤 معلومات جهة الاتصال
  // ============================================================

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfile(),
      ),
    );
  }

  // ============================================================
  // 🔍 البحث في المحادثة
  // ============================================================

  void _searchInChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/images/icons/search/Search_button.png',
              width: 24,
              height: 24,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(Icons.search),
            ),
            const SizedBox(width: 8),
            const Text(
              'بحث في المحادثة',
            ),
          ],
        ),
        content: TextField(
          decoration:
              const InputDecoration(
            hintText:
                'اكتب كلمة البحث...',
            prefixIcon:
                Icon(Icons.search),
            border:
                OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);

            ToastService.showInfo(
              '🔍 جاري البحث عن: $value',
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child:
                const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔇 كتم الإشعارات
  // ============================================================

  Future<void> _toggleMute() async {
    final newMute = !_isMuted;

    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'isMuted': newMute,
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isMuted = newMute;
      });

      ToastService.showSuccess(
        newMute
            ? '🔇 تم كتم الإشعارات'
            : '🔊 تم إلغاء كتم الإشعارات',
      );
    } catch (e) {
      ToastService.showError(
        '❌ فشل تغيير حالة الكتم: $e',
      );
    }
  }

  // ============================================================
  // 🗑️ مسح المحادثة
  // ============================================================

  void _clearChat() {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.delete_sweep,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            const Text(
              '🗑️ مسح المحادثة',
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من مسح جميع رسائل هذه المحادثة؟',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
            ),
            child:
                const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(
                dialogContext,
              );

              try {
                final snapshot =
                    await _firestore
                        .collection(
                          'chats',
                        )
                        .doc(
                          widget.chatId,
                        )
                        .collection(
                          'messages',
                        )
                        .get();

                final docs = snapshot.docs;

                // Firestore Batch له حد أقصى.
                // نستخدم 450 لكل دفعة.
                for (
                  int start = 0;
                  start < docs.length;
                  start += 450
                ) {
                  final end =
                      (start + 450 <
                              docs.length)
                          ? start + 450
                          : docs.length;

                  final batch =
                      _firestore.batch();

                  for (
                    int i = start;
                    i < end;
                    i++
                  ) {
                    batch.delete(
                      docs[i].reference,
                    );
                  }

                  await batch.commit();
                }

                if (!mounted) {
                  return;
                }

                ToastService.showInfo(
                  '🗑️ تم مسح جميع الرسائل',
                );
              } catch (e) {
                if (!mounted) {
                  return;
                }

                ToastService.showError(
                  '❌ فشل مسح المحادثة: $e',
                );
              }
            },
            style:
                TextButton.styleFrom(
              foregroundColor:
                  Colors.red,
            ),
            child:
                const Text('مسح'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📍 مشاركة الموقع
  // ============================================================

  Future<void> _shareLocation() async {
    try {
      final position =
          await _locationService
              .getCurrentLocation();

      if (position == null) {
        ToastService.showError(
          '❌ لا يمكن الحصول على الموقع',
        );
        return;
      }

      final address =
          await _locationService
              .getAddressFromLocation(
        latitude:
            position.latitude,
        longitude:
            position.longitude,
      );

      final user =
          _auth.currentUser;

      if (user == null) {
        return;
      }

      final locationUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName':
            user.displayName ?? 'مستخدم',
        'senderPhotoUrl':
            user.photoURL,
        'text': '📍 $address',
        'timestamp':
            FieldValue.serverTimestamp(),
        'type': 'location',

        'locationUrl':
            locationUrl,

        'locationLat':
            position.latitude,

        'locationLng':
            position.longitude,

        'locationAddress':
            address,

        // توافق مع البيانات القديمة.
        'latitude':
            position.latitude,

        'longitude':
            position.longitude,

        'address':
            address,

        'isRead': false,
        'isDelivered': false,
        'isDeleted': false,
        'reactions': {},
      });

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage':
            '📍 تم مشاركة موقع',
        'lastMessageTime':
            FieldValue.serverTimestamp(),
        'lastMessageSenderId':
            user.uid,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ToastService.showSuccess(
        '✅ تم مشاركة الموقع',
      );

      _scrollToBottom();
    } catch (e) {
      ToastService.showError(
        '❌ فشل مشاركة الموقع: $e',
      );
    }
  }

  // ============================================================
  // 📷 إرسال الصور
  // ============================================================

  Future<void> _sendImage(
    dynamic imagePath,
  ) async {
    try {
      XFile? image;

      if (imagePath is XFile) {
        image = imagePath;
      } else if (imagePath is String &&
          imagePath.isNotEmpty) {
        image = XFile(imagePath);
      } else {
        image = await _picker.pickImage(
          source:
              ImageSource.gallery,
          imageQuality: 70,
        );
      }

      if (image == null) {
        return;
      }

      final user =
          _auth.currentUser;

      if (user == null) {
        return;
      }

      final file =
          File(image.path);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref =
          FirebaseStorage.instance
              .ref()
              .child(
                'chats/${widget.chatId}/images/$fileName',
              );

      await ref.putFile(file);

      final imageUrl =
          await ref.getDownloadURL();

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName':
            user.displayName ?? 'مستخدم',
        'senderPhotoUrl':
            user.photoURL,
        'text': '📷 صورة',
        'imageUrl':
            imageUrl,
        'timestamp':
            FieldValue.serverTimestamp(),
        'type': 'image',
        'isRead': false,
        'isDelivered': false,
        'isDeleted': false,
        'reactions': {},
      });

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage':
            '📷 صورة',
        'lastMessageTime':
            FieldValue.serverTimestamp(),
        'lastMessageSenderId':
            user.uid,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ToastService.showSuccess(
        '✅ تم إرسال الصورة',
      );

      _scrollToBottom();
    } catch (e) {
      ToastService.showError(
        '❌ فشل إرسال الصورة: $e',
      );
    }
  }

  // ============================================================
  // 🏗️ Build
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),

      appBar:
          _buildAppBar(isDark),

      body: ChatBackground(
        child: Column(
          children: [
            if (_replyToMessage != null)
              _buildReplyBanner(),

            if (_typingUsers.isNotEmpty)
              TypingIndicator(
                name:
                    _typingUsers.first,
              ),

            Expanded(
              child: BlocListener<
                  MessagesBloc,
                  MessagesState>(
                listener:
                    (context, state) {
                  if (state
                          is MessagesLoaded &&
                      !state
                          .isLoadingMore) {
                    _isLoadingMore =
                        false;
                  }

                  if (state
                      is MessagesError) {
                    _isLoadingMore =
                        false;
                  }
                },
                child: BlocBuilder<
                    MessagesBloc,
                    MessagesState>(
                  builder:
                      (context, state) {
                    if (state
                        is MessagesLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (state
                        is MessagesError) {
                      return _buildErrorState(
                        isDark,
                      );
                    }

                    if (state
                        is MessagesLoaded) {
                      final messages =
                          state.messages;

                      if (messages
                          .isEmpty) {
                        return _buildEmptyState(
                          isDark,
                        );
                      }

                      return ListView
                          .builder(
                        controller:
                            _scrollController,
                        reverse: true,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount:
                            messages.length +
                                (state
                                        .isLoadingMore
                                    ? 1
                                    : 0),
                        itemBuilder:
                            (context, index) {
                          if (index ==
                              messages.length) {
                            return const Padding(
                              padding:
                                  EdgeInsets
                                      .all(8),
                              child: Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            );
                          }

                          final message =
                              messages[index];

                          final isMe =
                              message
                                      .senderId ==
                                  _auth
                                      .currentUser
                                      ?.uid;

                          return MessageBubble(
                            message: message.toFirestore(),
                            isMe:
                                isMe,
                            onReply: () {
                              setState(() {
                                _replyToMessage =
                                    message;

                                _replyToMessageId =
                                    message.id;
                              });
                            },
                            onDelete: () {
                              context
                                  .read<
                                      MessagesBloc>()
                                  .add(
                                    DeleteMessage(
                                      chatId:
                                          widget.chatId,
                                      messageId:
                                          message.id,
                                    ),
                                  );
                            },
                            onReaction:
                                (emoji) {
                              context
                                  .read<
                                      MessagesBloc>()
                                  .add(
                                    AddReaction(
                                      chatId:
                                          widget.chatId,
                                      messageId:
                                          message.id,
                                      emoji:
                                          emoji,
                                    ),
                                  );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox
                        .shrink();
                  },
                ),
              ),
            ),

            // ==================================================
            // شريط الإدخال
            // ==================================================

            ChatInputBar(
              chatId:
                  widget.chatId,

              onSendMessage:
                  (text) {
                final value =
                    text.trim();

                if (value.isEmpty) {
                  return;
                }

                context
                    .read<
                        MessagesBloc>()
                    .add(
                      SendMessage(
                        chatId:
                            widget.chatId,
                        text:
                            value,
                        replyToId:
                            _replyToMessageId,
                      ),
                    );

                setState(() {
                  _replyToMessage =
                      null;

                  _replyToMessageId =
                      null;
                });

                _textController
                    .clear();

                _scrollToBottom();
              },

              onSendImage:
                  (path) {
                _sendImage(path);
              },

              onShareLocation:
                  _shareLocation,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📱 AppBar
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : Colors.white,

      foregroundColor: isDark
          ? Colors.white
          : Colors.black87,

      elevation: 0,

      title: GestureDetector(
        onTap:
            _showContactInfo,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,

                  backgroundImage:
                      widget.groupImage !=
                              null
                          ? CachedNetworkImageProvider(
                              widget
                                  .groupImage!,
                            )
                          : null,

                  backgroundColor:
                      AppColors.primary
                          .withOpacity(
                    0.1,
                  ),

                  child:
                      widget.groupImage ==
                              null
                          ? Text(
                              widget
                                      .otherUserName
                                      .isNotEmpty
                                  ? widget
                                      .otherUserName[0]
                                      .toUpperCase()
                                  : 'م',
                              style:
                                  TextStyle(
                                color:
                                    AppColors.primary,
                                fontSize:
                                    14,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            )
                          : null,
                ),

                if (_isOnline &&
                    !widget.isGroup)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child:
                        Container(
                      width: 10,
                      height: 10,
                      decoration:
                          const BoxDecoration(
                        color:
                            Colors.green,
                        shape:
                            BoxShape
                                .circle,
                        border:
                            Border.fromBorderSide(
                          BorderSide(
                            color:
                                Colors.white,
                            width:
                                1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    widget.isGroup
                        ? 'المجموعة'
                        : widget
                            .otherUserName,
                    style:
                        TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),

                  Text(
                    _typingUsers
                            .isNotEmpty
                        ? 'يكتب...'
                        : _isOnline &&
                                !widget
                                    .isGroup
                            ? 'متصل'
                            : 'غير متصل',
                    style:
                        TextStyle(
                      fontSize: 11,
                      color:
                          _typingUsers
                                  .isNotEmpty
                              ? AppColors
                                  .primary
                              : (_isOnline
                                  ? Colors
                                      .green
                                  : Colors
                                      .grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      actions: [
        // 📞 صوتية
        if (!widget.isGroup)
          IconButton(
            icon: Image.asset(
              'assets/images/chat/phone_call.png',
              width: 24,
              height: 24,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(
                Icons.call,
              ),
            ),
            onPressed: () =>
                _startCall(false),
            tooltip:
                'مكالمة صوتية',
          ),

        // 📹 فيديو
        if (!widget.isGroup)
          IconButton(
            icon: Image.asset(
              'assets/images/chat/video_call.png',
              width: 24,
              height: 24,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(
                Icons.videocam,
              ),
            ),
            onPressed: () =>
                _startCall(true),
            tooltip:
                'مكالمة فيديو',
          ),

        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark
                ? Colors.white
                : Colors.black87,
          ),

          onSelected:
              (value) {
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

          itemBuilder:
              (context) => [
            const PopupMenuItem(
              value: 'search',
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 18,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text('بحث'),
                ],
              ),
            ),

            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(
                    _isMuted
                        ? Icons.volume_up
                        : Icons.volume_off,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _isMuted
                        ? 'إلغاء الكتم'
                        : 'كتم الإشعارات',
                  ),
                ],
              ),
            ),

            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_sweep,
                    size: 18,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'مسح المحادثة',
                    style:
                        TextStyle(
                      color:
                          Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // 💬 شريط الرد
  // ============================================================

  Widget _buildReplyBanner() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color: Theme.of(context)
                    .brightness ==
                Brightness.dark
            ? const Color(
                0xFF1A2540,
              )
            : Colors.white,

        border:
            Border(
          right: BorderSide(
            color:
                AppColors.primary,
            width: 3,
          ),
        ),
      ),

      child: Row(
        children: [
          Icon(
            Icons.reply,
            color:
                AppColors.primary,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'الرد على ${_replyToMessage?.senderName ?? 'مستخدم'}',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                    color:
                        AppColors.primary,
                  ),
                ),

                Text(
                  _replyToMessage
                          ?.text ??
                      '',
                  style:
                      TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                              context,
                            ).brightness ==
                            Brightness.dark
                        ? Colors
                            .grey[300]
                        : Colors
                            .grey[700],
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                _replyToMessage =
                    null;

                _replyToMessageId =
                    null;
              });
            },
            child: const Icon(
              Icons.close,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📭 حالة فارغة
  // ============================================================

  Widget _buildEmptyState(
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ui/chat_bubble.png',
            width: 60,
            height: 60,
            color: isDark
                ? Colors.grey[600]
                : Colors.grey[400],
            errorBuilder:
                (_, __, ___) =>
                    Icon(
              Icons
                  .chat_bubble_outline,
              size: 60,
              color: isDark
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            'لا توجد رسائل',
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black87,
              fontSize: 16,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'ابدأ المحادثة الآن',
            style: TextStyle(
              color: isDark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ❌ حالة الخطأ
  // ============================================================

  Widget _buildErrorState(
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color:
                Colors.red[300],
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            'حدث خطأ في تحميل الرسائل',
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          ElevatedButton(
            onPressed: () {
              _isLoadingMore =
                  false;

              context
                  .read<
                      MessagesBloc>()
                  .add(
                    LoadMessages(
                      chatId:
                          widget.chatId,
                      limit: 30,
                    ),
                  );
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primary,
              foregroundColor:
                  Colors.white,
            ),
            child:
                const Text(
              'إعادة المحاولة',
            ),
          ),
        ],
      ),
    );
  }
}
