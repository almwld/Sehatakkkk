// ============================================================
// 🌌 شاشة الدردشة - النموذج الموحد الشامل الكامل
// ============================================================
// دمج: v_b5eae300_27k + v_fd0e2518_41k + v_ff1047a4_85k
// مستوحاة من: WhatsApp + Telegram + iMessage + Signal + Discord
// ============================================================

import 'dart:async';
import 'dart:io';
import 'dart:math';

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
import 'package:sehatak/core/services/location_service.dart';
import 'package:sehatak/bloc/messages/messages_bloc.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';

// ============================================================
// 📦 النماذج المساعدة
// ============================================================

class Reaction {
  final String emoji;
  final List<String> users;
  Reaction({required this.emoji, required this.users});
}

class MessageReaction {
  final String messageId;
  final List<Reaction> reactions;
  MessageReaction({required this.messageId, required this.reactions});
}

// ============================================================
// 🏗️ الشاشة الرئيسية
// ============================================================

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

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        TickerProviderStateMixin {
  // ============================================================
  // 🔥 القسم 1: الخدمات والمتغيرات الأساسية
  // ============================================================

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();
  final FocusNode _focusNode = FocusNode();

  // ✅ قائمة الرسائل
  final List<MessageModel> _messages = [];
  final List<MessageReaction> _messageReactions = [];
  List<File> _selectedFiles = [];

  // ============================================================
  // 🎯 القسم 2: حالة الشاشة
  // ============================================================

  // ═══ حالة المستخدم ═══
  List<String> _typingUsers = [];
  bool _isOnline = false;
  String? _lastSeen;
  bool _isBlocked = false;
  bool _isBlockedByUser = false;

  // ═══ حالة المحادثة ═══
  bool _isMuted = false;
  bool _isPinned = false;
  bool _isArchived = false;
  bool _isSpam = false;
  bool _isEncrypted = true;
  String? _chatColor;

  // ═══ حالة الواجهة ═══
  bool _showScrollToBottom = false;
  bool _isLoadingMore = false;
  bool _isReplying = false;
  MessageModel? _replyMessage;
  double _appBarOpacity = 0;
  bool _isScrollingUp = false;
  bool _showEmojiPicker = false;
  bool _showAttachmentMenu = false;
  bool _showSearchBar = false;
  String _searchQuery = '';
  List<int> _highlightedIndices = [];
  int _currentHighlightIndex = -1;

  // ═══ حالة التسجيل الصوتي ═══
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  double _recordingAmplitude = 0;

  // ═══ حالة الملفات ═══
  bool _isUploadingFiles = false;
  double _uploadProgress = 0;

  // ═══ حالة الردود ═══
  bool _showReactionPicker = false;
  String? _reactionMessageId;
  bool _isEditing = false;
  MessageModel? _editingMessage;
  bool _isForwarding = false;
  List<MessageModel> _forwardMessages = [];
  bool _isMultiSelect = false;
  List<MessageModel> _selectedMessages = [];

  // ═══ حالة التقويم ═══
  DateTime? _selectedDate;
  bool _showCalendar = false;

  // ═══ حالة البول ═══
  bool _isPoll = false;
  String? _pollQuestion;
  List<String> _pollOptions = [];
  Map<String, int> _pollResults = {};

  // ═══ حالة القناة ═══
  bool _isChannel = false;
  int _subscribersCount = 0;
  bool _isSubscribed = false;

  // ═══ للتوافق مع النسخة القديمة ═══
  String? _replyToMessageId;

  // ============================================================
  // 🎬 القسم 3: التحكمات والأنيميشن
  // ============================================================

  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  final Random _random = Random();

  // ============================================================
  // 🔌 القسم 4: الاتصالات (Streams)
  // ============================================================

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _typingSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userStatusSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _muteSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _pinSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _blockSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reactionsSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _encryptionSubscription;

  // ============================================================
  // 🔄 القسم 5: دورة الحياة
  // ============================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeAnimations();
    _loadMessages();
    _loadEncryptionStatus();
    _loadBlockStatus();
    _loadChatSettings();

    _listenToTyping();
    _checkUserStatus();
    _listenToReactions();
    _listenToPin();
    _listenToBlock();
    _listenToEncryption();

    _scrollController.addListener(_onScroll);
    _markMessagesAsRead();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllSubscriptions();
    _textController.dispose();
    _scrollController.dispose();
    _mainController.dispose();
    _focusNode.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  // ============================================================
  // ⚙️ القسم 6: التهيئة والإعدادات
  // ============================================================

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );
  }

  void _disposeAllSubscriptions() {
    _typingSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _muteSubscription?.cancel();
    _pinSubscription?.cancel();
    _blockSubscription?.cancel();
    _reactionsSubscription?.cancel();
    _encryptionSubscription?.cancel();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showEmojiPicker = false;
        _showAttachmentMenu = false;
        _showReactionPicker = false;
      });
    }
  }

  // ============================================================
  // 📥 القسم 7: تحميل البيانات
  // ============================================================

  void _loadMessages() {
    context.read<MessagesBloc>().add(
          LoadMessages(chatId: widget.chatId, limit: 30),
        );
  }

  void _loadEncryptionStatus() async {
    try {
      final doc = await _firestore.collection('chats').doc(widget.chatId).get();
      if (doc.exists && mounted) {
        setState(() {
          _isEncrypted = doc.data()?['isEncrypted'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading encryption status: $e');
    }
  }

  void _loadBlockStatus() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blocked')
          .doc(widget.otherUserId)
          .get();

      if (mounted) {
        setState(() {
          _isBlockedByUser = doc.exists;
        });
      }
    } catch (e) {
      debugPrint('Error loading block status: $e');
    }
  }

  void _loadChatSettings() async {
    try {
      final doc = await _firestore.collection('chats').doc(widget.chatId).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _isMuted = data?['isMuted'] ?? false;
          _isPinned = data?['isPinned'] ?? false;
          _isArchived = data?['isArchived'] ?? false;
          _isSpam = data?['isSpam'] ?? false;
          _chatColor = data?['color'];
        });
      }
    } catch (e) {
      debugPrint('Error loading chat settings: $e');
    }
  }

  // ============================================================
  // 👂 القسم 8: الاستماع للحالة
  // ============================================================

  void _listenToTyping() {
    _typingSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      final data = snapshot.data();
      final typing = data?['typing'] as Map? ?? {};
      final users = typing.entries
          .where((e) => e.value == true)
          .map((e) => e.key.toString())
          .where((id) => id != _auth.currentUser?.uid)
          .toList();
      if (mounted) setState(() => _typingUsers = users);
    });
  }

  void _checkUserStatus() {
    _userStatusSubscription = _firestore
        .collection('users')
        .doc(widget.otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      final data = snapshot.data();
      if (mounted) {
        setState(() {
          _isOnline = data?['isOnline'] == true;
          _lastSeen = data?['lastSeen']?.toString();
        });
      }
    });
  }

  void _listenToReactions() {
    _reactionsSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final reactions = <MessageReaction>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reacts = data['reactions'] as Map? ?? {};
        final reactionList = <Reaction>[];
        reacts.forEach((emoji, users) {
          if (users is List) {
            reactionList.add(Reaction(
              emoji: emoji,
              users: users.map((e) => e.toString()).toList(),
            ));
          }
        });
        if (reactionList.isNotEmpty) {
          reactions.add(MessageReaction(
            messageId: doc.id,
            reactions: reactionList,
          ));
        }
      }
      if (mounted) {
        setState(() {
          _messageReactions.clear();
          _messageReactions.addAll(reactions);
        });
      }
    });
  }

  void _listenToPin() {
    _pinSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      if (mounted) {
        setState(() {
          _isPinned = snapshot.data()?['isPinned'] == true;
        });
      }
    });
  }

  void _listenToBlock() {
    _blockSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      if (mounted) {
        setState(() {
          _isBlocked = snapshot.data()?['isBlocked'] == true;
        });
      }
    });
  }

  void _listenToEncryption() {
    _encryptionSubscription = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      if (mounted) {
        setState(() {
          _isEncrypted = snapshot.data()?['isEncrypted'] ?? true;
        });
      }
    });
  }

  // ============================================================
  // 📜 القسم 9: التمرير والتحميل
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;

    setState(() {
      _showScrollToBottom = position.pixels < -350;
      _isScrollingUp = position.pixels < -150;
      _appBarOpacity = min(1, max(0, -position.pixels / 150));
    });

    if (position.pixels >= position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }

    if (_showSearchBar && _searchQuery.isNotEmpty) {
      _updateHighlightedIndices();
    }
  }

  void _loadMoreMessages() {
    if (_isLoadingMore) return;
    final bloc = context.read<MessagesBloc>();
    final state = bloc.state;
    if (state is! MessagesLoaded || !state.hasMore || state.isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    bloc.add(LoadMoreMessages(chatId: widget.chatId, limit: 30));
  }

  void _scrollToBottom({bool animated = true}) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
    });
  }

  // ============================================================
  // 🔍 القسم 10: البحث
  // ============================================================

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchQuery = '';
        _highlightedIndices.clear();
        _currentHighlightIndex = -1;
      }
    });
  }

  void _updateHighlightedIndices() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _highlightedIndices.clear();
        _currentHighlightIndex = -1;
      });
      return;
    }

    final indices = <int>[];
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i]
          .text
          .toLowerCase()
          .contains(_searchQuery.toLowerCase())) {
        indices.add(i);
      }
    }
    setState(() {
      _highlightedIndices = indices;
      if (_currentHighlightIndex >= indices.length) {
        _currentHighlightIndex = -1;
      }
    });
  }

  void _navigateToNextHighlight() {
    if (_highlightedIndices.isEmpty) return;
    setState(() {
      _currentHighlightIndex =
          (_currentHighlightIndex + 1) % _highlightedIndices.length;
    });
  }

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
              errorBuilder: (_, __, ___) => const Icon(Icons.search),
            ),
            const SizedBox(width: 8),
            const Text('بحث في المحادثة'),
          ],
        ),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'اكتب كلمة البحث...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
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

  // ============================================================
  // 📨 القسم 11: إرسال الرسائل
  // ============================================================

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _showEmojiPicker = false;
      _showAttachmentMenu = false;
      _showReactionPicker = false;
      _isReplying = false;
    });

    context.read<MessagesBloc>().add(
          SendMessage(
            chatId: widget.chatId,
            text: text.trim(),
            replyToId: _replyMessage?.id ?? _replyToMessageId,
            idempotencyKey: '${DateTime.now().millisecondsSinceEpoch}',
          ),
        );

    setState(() {
      _replyMessage = null;
      _replyToMessageId = null;
    });

    _scrollToBottom();
  }

  // ============================================================
  // 📷 القسم 12: إرسال الصور
  // ============================================================

  Future<void> _sendImage(dynamic imagePath) async {
    try {
      XFile? image;
      if (imagePath is XFile) {
        image = imagePath;
      } else if (imagePath is String && imagePath.isNotEmpty) {
        image = XFile(imagePath);
      } else {
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
      }

      if (image == null) return;
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() => _showAttachmentMenu = false);

      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/images/$fileName');

      setState(() {
        _isUploadingFiles = true;
        _uploadProgress = 0;
      });

      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0 && mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await uploadTask;
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
        'isDeleted': false,
        'isEdited': false,
        'reactions': {},
      });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📷 صورة',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _isUploadingFiles = false;
        _uploadProgress = 0;
      });
      ToastService.showSuccess('✅ تم إرسال الصورة');
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingFiles = false;
          _uploadProgress = 0;
        });
      }
      ToastService.showError('❌ فشل إرسال الصورة: $e');
    }
  }

  // ============================================================
  // 📁 القسم 13: إرسال الملفات
  // ============================================================

  void _sendFile() {
    ToastService.showInfo('📁 جاري إرسال الملف...');
    setState(() => _showAttachmentMenu = false);
    // TODO: تنفيذ إرسال الملفات عبر file_picker
  }

  // ============================================================
  // 👤 القسم 14: إرسال جهة الاتصال
  // ============================================================

  void _sendContact() {
    ToastService.showInfo('👤 جاري إرسال جهة الاتصال...');
    setState(() => _showAttachmentMenu = false);
    // TODO: تنفيذ إرسال جهة الاتصال
  }

  // ============================================================
  // 📊 القسم 15: إنشاء استطلاع
  // ============================================================

  void _sendPoll() {
    ToastService.showInfo('📊 جاري إنشاء استطلاع الرأي...');
    setState(() => _showAttachmentMenu = false);

    // ✅ نافذة إنشاء استطلاع
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 إنشاء استطلاع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'السؤال',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _pollQuestion = value,
            ),
            const SizedBox(height: 12),
            ...List.generate(_pollOptions.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'الخيار ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => _pollOptions[index] = value,
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _pollOptions.add('');
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة خيار'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: إرسال الاستطلاع
              ToastService.showInfo('📊 تم إنشاء الاستطلاع');
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📍 القسم 16: مشاركة الموقع
  // ============================================================

  Future<void> _shareLocation() async {
    try {
      setState(() => _showAttachmentMenu = false);

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

      final locationUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

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
        'locationUrl': locationUrl,
        'locationLat': position.latitude,
        'locationLng': position.longitude,
        'locationAddress': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'isRead': false,
        'isDelivered': false,
        'isDeleted': false,
        'reactions': {},
      });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': '📍 تم مشاركة موقع',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ToastService.showSuccess('✅ تم مشاركة الموقع');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل مشاركة الموقع: $e');
    }
  }

  // ============================================================
  // 🎤 القسم 17: التسجيل الصوتي
  // ============================================================

  void _startRecording() {
    if (_isRecording) {
      _stopRecording();
      return;
    }

    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _recordingAmplitude = 0;
    });

    _recordingTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration += const Duration(milliseconds: 100);
          _recordingAmplitude = 0.3 + 0.7 * _random.nextDouble();
        });
      }
    });

    ToastService.showInfo('🎤 جاري التسجيل...');
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingAmplitude = 0;
    });
    ToastService.showInfo(
        '⏹️ تم إيقاف التسجيل (${_recordingDuration.inSeconds}s)');
    // TODO: حفظ التسجيل في Firebase Storage
  }

  // ============================================================
  // 📞 القسم 18: المكالمات
  // ============================================================

  Future<void> _saveCallMessage(bool isVideo) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final message = isVideo ? '📹 مكالمة فيديو' : '📞 مكالمة صوتية';

      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'chatId': widget.chatId,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'senderPhotoUrl': user.photoURL,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
        'callType': isVideo ? 'video' : 'audio',
        'metadata': {'callType': isVideo ? 'video' : 'audio'},
        'isRead': false,
        'isDelivered': false,
        'isDeleted': false,
        'isEdited': false,
        'reactions': {},
      });

      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ فشل حفظ رسالة النظام: $e');
    }
  }

  void _startCall(bool isVideo) {
    _saveCallMessage(isVideo);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: widget.chatId,
          doctorName: widget.otherUserName,
          doctorId: widget.otherUserId,
          isVideo: isVideo,
          doctorImage: widget.otherUserImage ?? widget.groupImage,
          isOutgoing: true,
        ),
      ),
    );
  }

  // ============================================================
  // 👤 القسم 19: معلومات جهة الاتصال
  // ============================================================

  void _showContactInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PatientProfile()),
    );
  }

  void _showUserProfile() {
    ToastService.showInfo('👤 عرض ملف ${widget.otherUserName}');
  }

  // ============================================================
  // 🔧 القسم 20: إعدادات المحادثة
  // ============================================================

  Future<void> _toggleMute() async {
    final newMute = !_isMuted;
    try {
      await _firestore.collection('chats').doc(widget.chatId).update({
        'isMuted': newMute,
      });
      if (!mounted) return;
      setState(() => _isMuted = newMute);
      ToastService.showSuccess(
        newMute ? '🔇 تم كتم الإشعارات' : '🔊 تم إلغاء كتم الإشعارات',
      );
    } catch (e) {
      ToastService.showError('❌ فشل تغيير حالة الكتم: $e');
    }
  }

  Future<void> _togglePin() async {
    try {
      final newPin = !_isPinned;
      await _firestore.collection('chats').doc(widget.chatId).update({
        'isPinned': newPin,
      });
      setState(() => _isPinned = newPin);
      ToastService.showSuccess(
        newPin ? '📌 تم تثبيت المحادثة' : '📌 تم إلغاء التثبيت',
      );
    } catch (e) {
      ToastService.showError('❌ فشل تغيير حالة التثبيت');
    }
  }

  Future<void> _archiveChat() async {
    try {
      final newArchive = !_isArchived;
      await _firestore.collection('chats').doc(widget.chatId).update({
        'isArchived': newArchive,
      });
      setState(() => _isArchived = newArchive);
      ToastService.showSuccess(
        newArchive ? '📦 تم أرشفة المحادثة' : '📦 تم إلغاء الأرشفة',
      );
      if (newArchive && mounted) Navigator.pop(context);
    } catch (e) {
      ToastService.showError('❌ فشل الأرشفة');
    }
  }

  Future<void> _markAsSpam() async {
    try {
      await _firestore.collection('chats').doc(widget.chatId).update({
        'isSpam': true,
      });
      setState(() => _isSpam = true);
      ToastService.showSuccess('🚫 تم وضع علامة Spam');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ToastService.showError('❌ فشل وضع علامة Spam');
    }
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚫 حظر المستخدم'),
        content: const Text('هل أنت متأكد من حظر هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final uid = _auth.currentUser?.uid;
                if (uid == null) return;
                await _firestore
                    .collection('users')
                    .doc(uid)
                    .collection('blocked')
                    .doc(widget.otherUserId)
                    .set({
                  'blockedAt': FieldValue.serverTimestamp(),
                  'blockedBy': uid,
                });
                setState(() => _isBlockedByUser = true);
                ToastService.showSuccess('🚫 تم حظر المستخدم');
              } catch (e) {
                ToastService.showError('❌ فشل الحظر');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حظر'),
          ),
        ],
      ),
    );
  }

  Future<void> _unblockUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('blocked')
          .doc(widget.otherUserId)
          .delete();
      setState(() => _isBlockedByUser = false);
      ToastService.showSuccess('✅ تم إلغاء الحظر');
    } catch (e) {
      ToastService.showError('❌ فشل إلغاء الحظر');
    }
  }

  void _reportUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📝 إبلاغ عن المستخدم'),
        content: const Text('سيتم مراجعة البلاغ من قبل فريق الدعم.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastService.showSuccess('📝 تم إرسال البلاغ بنجاح');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('إبلاغ'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🗑️ القسم 21: حذف ومسح
  // ============================================================

  void _clearChat() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.delete_sweep, color: Colors.red),
            SizedBox(width: 8),
            Text('🗑️ مسح المحادثة'),
          ],
        ),
        content: const Text('هل أنت متأكد من مسح جميع رسائل هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final snapshot = await _firestore
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .get();
                final docs = snapshot.docs;

                for (int start = 0; start < docs.length; start += 450) {
                  final end =
                      (start + 450 < docs.length) ? start + 450 : docs.length;
                  final batch = _firestore.batch();
                  for (int i = start; i < end; i++) {
                    batch.delete(docs[i].reference);
                  }
                  await batch.commit();
                }

                if (!mounted) return;
                ToastService.showSuccess('🗑️ تم مسح جميع الرسائل');
              } catch (e) {
                if (!mounted) return;
                ToastService.showError('❌ فشل مسح المحادثة: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ حذف الرسالة'),
        content: const Text('هل أنت متأكد من حذف هذه الرسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MessagesBloc>().add(
                    DeleteMessage(
                      chatId: widget.chatId,
                      messageId: message.id,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📋 القسم 22: التحديد المتعدد
  // ============================================================

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelect = !_isMultiSelect;
      if (!_isMultiSelect) _selectedMessages.clear();
    });
  }

  void _selectMessage(MessageModel message) {
    setState(() {
      if (_selectedMessages.contains(message)) {
        _selectedMessages.remove(message);
      } else {
        _selectedMessages.add(message);
      }
    });
  }

  void _deleteSelectedMessages() {
    if (_selectedMessages.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🗑️ حذف ${_selectedMessages.length} رسالة'),
        content: const Text('هل أنت متأكد من حذف الرسائل المحددة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (final message in _selectedMessages) {
                context.read<MessagesBloc>().add(
                      DeleteMessage(
                        chatId: widget.chatId,
                        messageId: message.id,
                      ),
                    );
              }
              setState(() {
                _selectedMessages.clear();
                _isMultiSelect = false;
              });
              ToastService.showSuccess('🗑️ تم حذف الرسائل المحددة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📤 القسم 23: إعادة التوجيه
  // ============================================================

  void _toggleForwardMode() {
    setState(() {
      _isForwarding = !_isForwarding;
      if (!_isForwarding) _forwardMessages.clear();
    });
  }

  void _selectMessageForForward(MessageModel message) {
    setState(() {
      if (_forwardMessages.contains(message)) {
        _forwardMessages.remove(message);
      } else {
        _forwardMessages.add(message);
      }
    });
  }

  void _forwardSelectedMessages() {
    if (_forwardMessages.isEmpty) return;
    ToastService.showInfo(
        '📤 جاري إعادة توجيه ${_forwardMessages.length} رسالة');
    setState(() {
      _isForwarding = false;
      _forwardMessages.clear();
    });
  }

  // ============================================================
  // ✏️ القسم 24: تحرير الرسائل
  // ============================================================

  void _editMessage(MessageModel message) {
    setState(() {
      _isEditing = true;
      _editingMessage = message;
      _textController.text = message.text;
      _focusNode.requestFocus();
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingMessage = null;
      _textController.clear();
    });
  }

  // ============================================================
  // ⚡ القسم 25: قراءة الرسائل
  // ============================================================

  void _markMessagesAsRead() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: uid)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      await _firestore.collection('chats').doc(widget.chatId).update({
        'unreadCount.${widget.otherUserId}': 0,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // ============================================================
  // 🏗️ القسم 26: Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFE8E8E8),
      body: _isBlockedByUser
          ? _buildBlockedScreen(isDark)
          : _buildMainScreen(isDark),
    );
  }

  Widget _buildMainScreen(bool isDark) {
    return Stack(
      children: [
        const SizedBox.shrink(),
        Column(
          children: [
            _buildCustomAppBar(isDark),
            if (_showSearchBar) _buildSearchBar(isDark),
            if (_isMultiSelect) _buildMultiSelectBar(isDark),
            if (_isForwarding) _buildForwardBar(isDark),
            if (_isReplying && _replyMessage != null) _buildReplyBanner(isDark),
            if (_typingUsers.isNotEmpty) _buildTypingIndicator(isDark),
            Expanded(
              child: BlocConsumer<MessagesBloc, MessagesState>(
                listener: (context, state) {
                  if (state is MessagesLoaded) {
                    _isLoadingMore = false;
                    if (mounted) {
                      _messages.clear();
                      _messages.addAll(state.messages);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is MessagesLoading)
                    return _buildLoadingState(isDark);
                  if (state is MessagesError) {
                    return _buildErrorState(isDark, state.message);
                  }
                  if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) return _buildEmptyState(isDark);
                    return _buildMessagesList(state, isDark);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (!_isBlockedByUser) _buildAdvancedInputBar(isDark),
          ],
        ),
        if (_showScrollToBottom) _buildScrollToBottomButton(),
        if (_showReactionPicker) _buildReactionPicker(isDark),
      ],
    );
  }

  Widget _buildBlockedScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '🔒 تم حظر هذه المحادثة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لن تتمكن من إرسال أو استقبال الرسائل',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _unblockUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إلغاء الحظر'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 القسم 27: عناصر الواجهة
  // ============================================================

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF1A1A1A),
                  const Color(0xFF0D0D0D),
                ]
              : [
                  const Color(0xFFE8E8E8),
                  const Color(0xFFF5F5F5),
                  const Color(0xFFEAEAEA),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 8, left: 4, right: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_appBarOpacity * 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: _showUserProfile,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      (widget.otherUserImage ?? widget.groupImage) != null
                          ? CachedNetworkImageProvider(
                              widget.otherUserImage ?? widget.groupImage!)
                          : null,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: (widget.otherUserImage ?? widget.groupImage) == null
                      ? Text(
                          widget.otherUserName.isNotEmpty
                              ? widget.otherUserName[0].toUpperCase()
                              : 'م',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
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
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                if (_isEncrypted)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 10,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _showUserProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.isGroup ? 'المجموعة' : widget.otherUserName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isPinned)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.push_pin,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      if (_isMuted)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_typingUsers.isNotEmpty)
                        Text(
                          'يكتب...',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (_isOnline && !widget.isGroup)
                        Text(
                          'متصل الآن',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (!widget.isGroup && _lastSeen != null)
                        Text(
                          'آخر ظهور: ${_formatLastSeen()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        )
                      else
                        Text(
                          'غير متصل',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                      const SizedBox(width: 4),
                      if (_typingUsers.isEmpty && !_isOnline && !widget.isGroup)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: _toggleSearch,
          ),
          if (!widget.isGroup)
            IconButton(
              icon: Icon(
                Icons.phone,
                color: isDark ? Colors.white : AppColors.primary,
                size: 20,
              ),
              onPressed: () => _startCall(false),
            ),
          if (!widget.isGroup)
            IconButton(
              icon: Icon(
                Icons.videocam,
                color: isDark ? Colors.white : AppColors.primary,
                size: 20,
              ),
              onPressed: () => _startCall(true),
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'pin':
                  _togglePin();
                  break;
                case 'mute':
                  _toggleMute();
                  break;
                case 'archive':
                  _archiveChat();
                  break;
                case 'multi_select':
                  _toggleMultiSelect();
                  break;
                case 'forward':
                  _toggleForwardMode();
                  break;
                case 'clear':
                  _clearChat();
                  break;
                case 'spam':
                  _markAsSpam();
                  break;
                case 'block':
                  _blockUser();
                  break;
                case 'report':
                  _reportUser();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                      _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 18,
                      color: _isPinned ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPinned ? 'إلغاء التثبيت' : 'تثبيت',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isPinned ? AppColors.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(
                      _isMuted ? Icons.volume_up : Icons.volume_off,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isMuted ? 'إلغاء الكتم' : 'كتم الإشعارات',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(
                      _isArchived ? Icons.unarchive : Icons.archive,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isArchived ? 'إلغاء الأرشفة' : 'أرشفة',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'multi_select',
                child: Row(
                  children: [
                    Icon(Icons.checklist, size: 18),
                    SizedBox(width: 8),
                    Text('تحديد متعدد', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'forward',
                child: Row(
                  children: [
                    Icon(Icons.forward, size: 18),
                    SizedBox(width: 8),
                    Text('إعادة توجيه', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'مسح المحادثة',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'spam',
                child: Row(
                  children: [
                    Icon(Icons.report_off, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'تبليغ كـ Spam',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'حظر',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'إبلاغ',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastSeen() {
    if (_lastSeen == null) return 'غير معروف';
    try {
      final date = DateTime.parse(_lastSeen!);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inHours < 1) return '${diff.inMinutes} دقيقة';
      if (diff.inDays < 1) return '${diff.inHours} ساعة';
      if (diff.inDays < 7) return '${diff.inDays} يوم';
      return date.toString().substring(0, 10);
    } catch (e) {
      return 'غير معروف';
    }
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateHighlightedIndices();
                });
              },
              decoration: InputDecoration(
                hintText: 'بحث في المحادثة...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_highlightedIndices.isNotEmpty)
                            Text(
                              '${_currentHighlightIndex + 1}/${_highlightedIndices.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward,
                              size: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onPressed: _navigateToNextHighlight,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onPressed: _toggleSearch,
                          ),
                        ],
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Text(
            '${_selectedMessages.length} مختارة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed:
                _selectedMessages.isEmpty ? null : _deleteSelectedMessages,
          ),
          IconButton(
            icon: const Icon(Icons.forward, color: AppColors.primary),
            onPressed: _selectedMessages.isEmpty
                ? null
                : () {
                    ToastService.showInfo(
                        '📤 جاري إعادة توجيه ${_selectedMessages.length} رسالة');
                  },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: _toggleMultiSelect,
          ),
        ],
      ),
    );
  }

  Widget _buildForwardBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.forward, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            '${_forwardMessages.length} رسالة للتوجيه',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed:
                _forwardMessages.isEmpty ? null : _forwardSelectedMessages,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: _toggleForwardMode,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.primary, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.reply, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرد على ${_replyMessage?.senderName ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _replyMessage?.text ?? '',
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
          GestureDetector(
            onTap: () {
              setState(() {
                _isReplying = false;
                _replyMessage = null;
                _replyToMessageId = null;
              });
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            child: Text(
              _typingUsers.first.isNotEmpty
                  ? _typingUsers.first[0].toUpperCase()
                  : 'م',
              style: TextStyle(
                fontSize: 8,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_typingUsers.first} يكتب...',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          _buildTypingDots(isDark),
        ],
      ),
    );
  }

  Widget _buildTypingDots(bool isDark) {
    return SizedBox(
      width: 30,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: Transform.translate(
              offset: Offset(
                0,
                -3 *
                    sin(index * 1.5 +
                        DateTime.now().millisecondsSinceEpoch / 500),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // 📝 القسم 28: قائمة الرسائل
  // ============================================================

  Widget _buildMessagesList(MessagesLoaded state, bool isDark) {
    final messages = state.messages;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ChatBackground(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: messages.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final message = messages[index];
                final isMe = message.senderId == _auth.currentUser?.uid;

                final showDate = index == 0 ||
                    (message.timestamp != null &&
                        messages[index - 1].timestamp != null &&
                        _isDifferentDay(
                          message.timestamp!.toDate(),
                          messages[index - 1].timestamp!.toDate(),
                        ));

                return Column(
                  children: [
                    if (showDate)
                      _buildDateDivider(message.timestamp?.toDate(), isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: MessageBubble(
                        message: message.toFirestore(),
                        isMe: isMe,
                        onReply: () {
                          setState(() {
                            _isReplying = true;
                            _replyMessage = message;
                            _replyToMessageId = message.id;
                          });
                        },
                        onDelete: () => _deleteMessage(message),
                        onReaction: (emoji) {
                          context.read<MessagesBloc>().add(
                                AddReaction(
                                  chatId: widget.chatId,
                                  messageId: message.id,
                                  emoji: emoji,
                                ),
                              );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  Widget _buildDateDivider(DateTime? timestamp, bool isDark) {
    if (timestamp == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final difference = today.difference(date).inDays;

    String label;
    if (difference == 0) {
      label = 'اليوم';
    } else if (difference == 1) {
      label = 'أمس';
    } else if (difference < 7) {
      label = [
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت'
      ][date.weekday % 7];
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.8)
                : Colors.grey[200]!.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 القسم 29: حالات الشاشة
  // ============================================================

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'جاري تحميل الرسائل...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'حدث خطأ في تحميل الرسائل',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('إعادة المحاولة', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '👋 مرحباً',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ابدأ المحادثة مع ${widget.otherUserName}',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.message, size: 16),
            label: const Text('أرسل رسالة', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎛️ القسم 30: شريط الإدخال المتقدم
  // ============================================================

  Widget _buildAdvancedInputBar(bool isDark) {
    return Column(
      children: [
        if (_showAttachmentMenu) _buildAttachmentMenu(isDark),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                  color: isDark ? Colors.white : Colors.grey[700],
                  size: 24,
                ),
                onPressed: _toggleEmojiPicker,
              ),
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: isDark ? Colors.white : Colors.grey[700],
                  size: 24,
                ),
                onPressed: _toggleAttachmentMenu,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: _isEditing ? 'تعديل الرسالة...' : 'اكتب رسالة...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  onSubmitted: (text) => _sendMessage(text),
                ),
              ),
              if (_textController.text.isEmpty)
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording
                        ? Colors.red
                        : (isDark ? Colors.white : Colors.grey[700]),
                    size: 24,
                  ),
                  onPressed: _startRecording,
                )
              else
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primary, size: 24),
                  onPressed: () => _sendMessage(_textController.text),
                ),
            ],
          ),
        ),
        if (_isRecording) _buildRecordingIndicator(isDark),
        if (_showEmojiPicker) _buildEmojiPicker(isDark),
        if (_isUploadingFiles) _buildUploadProgress(isDark),
      ],
    );
  }

  Widget _buildAttachmentMenu(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttachmentItem(
            icon: Icons.image,
            label: 'صورة',
            color: Colors.blue,
            onTap: () => _sendImage(null),
          ),
          _buildAttachmentItem(
            icon: Icons.video_library,
            label: 'فيديو',
            color: Colors.purple,
            onTap: () => _sendImage(null),
          ),
          _buildAttachmentItem(
            icon: Icons.insert_drive_file,
            label: 'ملف',
            color: Colors.orange,
            onTap: _sendFile,
          ),
          _buildAttachmentItem(
            icon: Icons.person,
            label: 'جهة اتصال',
            color: Colors.green,
            onTap: _sendContact,
          ),
          _buildAttachmentItem(
            icon: Icons.location_on,
            label: 'موقع',
            color: Colors.red,
            onTap: _shareLocation,
          ),
          _buildAttachmentItem(
            icon: Icons.poll,
            label: 'استطلاع',
            color: Colors.teal,
            onTap: _sendPoll,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '🎤 تسجيل ${_recordingDuration.inSeconds}s',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 20,
            child: Row(
              children: List.generate(20, (index) {
                final height =
                    4 + 16 * (_recordingAmplitude * (1 - index / 20));
                return Expanded(
                  child: Container(
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Row(
        children: [
          const Icon(Icons.cloud_upload, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جاري رفع الملفات...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker(bool isDark) {
    final emojis = [
      '😊',
      '😂',
      '🤣',
      '❤️',
      '😍',
      '🥰',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😛',
      '😝',
      '😜',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😎',
      '🥸',
      '🤩',
      '🥳',
      '😏',
      '😒',
      '😞',
      '😔',
      '😟',
      '😕',
      '🙁',
      '☹️',
      '😣',
      '😖',
      '😫',
      '😩',
      '🥺',
      '😢',
      '😭',
      '😤',
      '😠',
      '😡',
      '🤬',
      '🤯',
      '😳',
      '🥵',
      '🥶',
      '😱',
      '😨',
      '😰',
      '😥',
      '😓',
      '🤗',
      '🤔',
      '🤭',
      '🤫',
      '🤥',
      '😶',
      '😐',
      '😑',
      '😬',
      '🙄',
      '😯',
      '😦',
      '😧',
      '😮',
      '😲',
      '🥱',
      '😴',
      '🤤',
      '😪',
      '😵',
      '🤐',
      '🥴',
      '🤢',
      '🤮',
      '🤧',
      '😷',
      '🤒',
      '🤕',
      '🤑',
      '🤠',
    ];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _textController.text += emojis[index];
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey[800] : Colors.grey[100],
              ),
              child: Center(
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 📌 القسم 31: تفاعلات الرسائل
  // ============================================================

  Widget _buildReactionPicker(bool isDark) {
    final reactions = ['❤️', '😂', '😮', '😢', '😡', '👍', '👎', '🎉'];

    return GestureDetector(
      onTap: () => setState(() => _showReactionPicker = false),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: reactions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _showReactionPicker = false);
                    if (_reactionMessageId != null) {
                      context.read<MessagesBloc>().add(
                            AddReaction(
                              chatId: widget.chatId,
                              messageId: _reactionMessageId!,
                              emoji: emoji,
                            ),
                          );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ⬇️ القسم 32: زر التمرير للأسفل
  // ============================================================

  Widget _buildScrollToBottomButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: _showScrollToBottom ? 100 : 60,
      right: 16,
      child: GestureDetector(
        onTap: () => _scrollToBottom(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_downward,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔧 القسم 33: دوال التحكم
  // ============================================================

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      _showAttachmentMenu = false;
      _showReactionPicker = false;
      if (_showEmojiPicker) _focusNode.unfocus();
    });
  }

  void _toggleAttachmentMenu() {
    setState(() {
      _showAttachmentMenu = !_showAttachmentMenu;
      _showEmojiPicker = false;
      _showReactionPicker = false;
      if (_showAttachmentMenu) _focusNode.unfocus();
    });
  }
}
