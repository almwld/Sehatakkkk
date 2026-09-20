import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_location_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/core/services/chat_media_transfer_service.dart';
import 'package:sehatak/core/services/chat_reply_context.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/notification_service.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/message_search_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/media_upload_status_widget.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final bool isGroup;
  final String? groupImage;
  final String? lastMessage;
  const ChatRoomScreen(
      {super.key,
      required this.chatId,
      required this.otherUserId,
      required this.otherUserName,
      this.otherUserImage,
      this.isGroup = false,
      this.groupImage,
      this.lastMessage});
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  const _SwipeToReply({required this.child, required this.onReply});

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply> {
  static const double _triggerDistance = 64;
  double _dx = 0;

  void _reset() {
    if (mounted) setState(() => _dx = 0);
  }

  @override
  Widget build(BuildContext context) {
    final distance = _dx.abs();
    final progress = (distance / _triggerDistance).clamp(0.0, 1.0);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final iconAlignment = _dx >= 0
        ? AlignmentDirectional.centerStart
        : AlignmentDirectional.centerEnd;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          start: isRtl ? null : 4,
          end: isRtl ? 4 : null,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: iconAlignment,
            child: Opacity(
              opacity: progress,
              child: Transform.scale(
                scale: .75 + (.25 * progress),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.reply_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(_dx, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              final next = (_dx + details.delta.dx).clamp(-96.0, 96.0);
              setState(() => _dx = next);
            },
            onHorizontalDragEnd: (_) {
              if (_dx.abs() >= _triggerDistance) {
                widget.onReply();
              }
              _reset();
            },
            onHorizontalDragCancel: _reset,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class _ChatRoomScreenState extends State<ChatRoomScreen> with WidgetsBindingObserver {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chat = ChatService();
  final _statusService = StatusService();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _chatSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  Timer? _pendingRefreshTimer;
  Timer? _typingClearTimer;
  bool _otherTyping = false;
  List<MessageModel> _messages = [];
  final List<Map<String, dynamic>> _localMedia = [];
  final Set<String> _knownMessageIds = <String>{};
  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  Set<String> _newMessageIds = <String>{};
  bool _hasInitialMessageSnapshot = false;
  bool _loading = true;
  bool _online = false;
  DateTime? _lastSeen;
  bool _muted = false;
  bool _pinned = false;
  MessageModel? _replyingTo;
  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      _firestore.collection('chats').doc(widget.chatId).collection('messages');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listen();
    _loadPendingMedia();
    _startPendingRefresh();
    unawaited(NotificationService().cancelChatNotifications(widget.chatId));
    _markRead();
  }

  Future<void> _setTyping(bool typing) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _typingClearTimer?.cancel();
    if (typing) {
      _typingClearTimer =
          Timer(const Duration(seconds: 2), () => _setTyping(false));
    }
    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .set({'typing.$uid': typing}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('typing update: $e');
    }
  }

  

  

  

  void _startPendingRefresh() {
    _pendingRefreshTimer?.cancel();
    var delay = const Duration(seconds: 2);
    void schedule() {
      _pendingRefreshTimer = Timer(delay, () async {
        if (!mounted) return;
        await _loadPendingMedia();
        final pending = _localMedia.isNotEmpty;
        final nextSeconds = (delay.inSeconds * 2).clamp(2, 16).toInt();
        delay = pending
            ? Duration(seconds: nextSeconds)
            : const Duration(seconds: 8);
        schedule();
      });
    }

    schedule();
  }

  Future<void> _loadPendingMedia() async {
    try {
      final jobs =
          await ChatMediaTransferService.instance.pendingForChat(widget.chatId);
      if (!mounted) return;
      setState(() => _localMedia
        ..clear()
        ..addAll(jobs.map(_pendingMap)));
    } catch (e) {
      debugPrint('pending media load: $e');
    }
  }

  Map<String, dynamic> _pendingMap(Map<String, dynamic> job) {
    final type = job['type']?.toString() ?? 'file';
    final local = job['local_path']?.toString() ?? '';
    final status = job['status']?.toString() ?? 'queued';
    final progress = (job['progress'] as num?)?.toDouble() ?? 0.0;
    final uploadStatus = status == 'retry'
        ? 'failed'
        : status == 'queued'
            ? 'pending'
            : 'uploading';
    return {
      'id': job['id'],
      'chatId': widget.chatId,
      'senderId': _auth.currentUser?.uid ?? 'local',
      'senderName': _auth.currentUser?.displayName ?? 'مستخدم',
      'type': type,
      'text': job['preview']?.toString() ?? 'مرفق',
      'imageUrl': type == 'image' ? local : null,
      'videoUrl': type == 'video' ? local : null,
      'audioUrl': type == 'audio' ? local : null,
      'fileUrl': type == 'file' ? local : null,
      'fileName': job['file_name'],
      'fileSize': job['file_size'],
      'fileMimeType': job['mime_type'],
      'audioDuration': job['audio_duration'],
      'isLocal': true,
      'isSending': status != 'retry',
      'isUploading':
          status == 'uploading' || status == 'queued' || status == 'retry',
      'hasError': status == 'retry',
      'uploadStatus': uploadStatus,
      'uploadProgress': progress,
      'outboxId': job['id'],
      'timestamp': job['created_at'] ?? DateTime.now().toIso8601String(),
      'onRetry': () async {
        await ChatMediaTransferService.instance.retry(job['id'].toString());
        if (mounted) await _loadPendingMedia();
      },
      'onCancel': () async {
        await ChatMediaTransferService.instance.cancel(job['id'].toString());
        if (mounted) await _loadPendingMedia();
      },
    };
  }

  void _addLocalMedia(Map<String, dynamic> media) {
    if (!mounted) return;
    setState(() {
      _localMedia.removeWhere((m) => m['outboxId'] == media['outboxId']);
      _localMedia.add(media);
    });
    unawaited(_loadPendingMedia());
  }

  bool _hiddenForCurrentUser(Map<String, dynamic> data) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final deletedFor = data['deletedFor'];
    return deletedFor is Map && deletedFor[uid] == true;
  }

  void _listen() {
    _chatSub = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;
      final data = snapshot.data() ?? <String, dynamic>{};
      final uid = _auth.currentUser?.uid;
      final mutedFor = data['mutedFor'];
      final pinnedFor = data['pinnedFor'];
      final typing = data['typing'];
      final otherId = widget.otherUserId;
      final otherTyping = typing is Map && typing[otherId] == true;
      if (mounted && _otherTyping != otherTyping)
        setState(() => _otherTyping = otherTyping);
      setState(() {
        _muted = uid != null && mutedFor is Map && mutedFor[uid] == true
            ? true
            : data['isMuted'] == true && mutedFor is! Map;
        _pinned = uid != null && pinnedFor is Map && pinnedFor[uid] == true
            ? true
            : data['isPinned'] == true && pinnedFor is! Map;
      });
    });
    _userSub = _firestore
        .collection('users')
        .doc(widget.otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final data = snapshot.data() ?? <String, dynamic>{};
        final rawLastSeen = data['lastSeen'];
        final lastSeen = rawLastSeen is Timestamp ? rawLastSeen.toDate() : (rawLastSeen is DateTime ? rawLastSeen : null);
        setState(() { _online = data['isOnline'] == true; _lastSeen = lastSeen; });
      }
    });
    _messagesSub = _messagesRef
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
          .where((m) => !_hiddenForCurrentUser(m.toFirestore()))
          .toList();
      final remoteIds = messages.map((m) => m.id).toSet();
      final currentIds = remoteIds;
      final newIds = _hasInitialMessageSnapshot
          ? currentIds.difference(_knownMessageIds)
          : <String>{};
      _knownMessageIds
        ..clear()
        ..addAll(currentIds);
      _newMessageIds = newIds;
      _hasInitialMessageSnapshot = true;
      setState(() {
        _messages = messages;
        _localMedia.removeWhere((m) => remoteIds.contains(m['id']));
        _loading = false;
      });
      unawaited(_markDeliveryAndRead());
      unawaited(_loadPendingMedia());
    }, onError: (error) {
      debugPrint('chat stream: $error');
      if (mounted) setState(() => _loading = false);
    });
  }

  DateTime _messageTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) {
      final n = value.toInt();
      return DateTime.fromMillisecondsSinceEpoch(
          n > 100000000000 ? n : n * 1000);
    }
    if (value is String)
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _markDeliveryAndRead() async { try { await _chat.markDelivered(widget.chatId); } catch (error) { debugPrint('mark delivered: $error'); } await _markRead(); }

  Future<void> _markRead() async {
    try {
      await _chat.markAsRead(widget.chatId);
    } catch (error) {
      debugPrint('mark read: $error');
    }
  }

  String _lastSeenLabel() {
    final value = _lastSeen;
    if (value == null) return 'غير متصل';
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) return 'آخر ظهور منذ لحظات';
    if (diff.inMinutes < 60) return 'آخر ظهور منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'آخر ظهور منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'آخر ظهور منذ ${diff.inDays} يوم';
    return 'آخر ظهور ${value.day.toString().padLeft(2,'0')}/${value.month.toString().padLeft(2,'0')}';
  }

  void _call(bool video) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CallScreen(
            chatId: widget.chatId,
            doctorName: widget.otherUserName,
            doctorId: widget.otherUserId,
            doctorImage: widget.otherUserImage ?? widget.groupImage,
            isVideo: video,
            isOutgoing: true)));
  }

  void _profile() {
    if (widget.otherUserId.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientProfile(userId: widget.otherUserId),
      ),
    );
  }

  Future<void> _openOtherUserStatus(UserStatusModel status) async { if (!mounted || status.stories.isEmpty) return; await Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerScreen(status: status))); }

  Future<void> _searchMessages() async {
    final id = await Navigator.of(context).push<String>(MaterialPageRoute(
        builder: (_) => MessageSearchScreen(chatId: widget.chatId)));
    if (!mounted || id == null || id.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _messageKeys[id];
      final target = key?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 350), curve: Curves.easeOut, alignment: .45);
      }
    });
  }

  Future<void> _toggleMute() async {
    try {
      await _chat.muteChat(widget.chatId, !_muted);
    } catch (e) {
      debugPrint('mute chat: $e');
    }
  }

  Future<void> _deleteChatForMe() async { try { await _chat.deleteChat(widget.chatId); if(mounted)Navigator.of(context).pop(); } catch(e){debugPrint('delete chat: $e');} }

  Future<void> _togglePin() async {
    try {
      await _chat.pinChat(widget.chatId, !_pinned);
    } catch (e) {
      debugPrint('pin chat: $e');
    }
  }

  Future<void> _toggleMessagePin(MessageModel message) async { try { await _chat.pinMessage(widget.chatId, message.id, !message.isPinned); } catch (e) { debugPrint('pin message: $e'); } }

  Future<void> _deleteMessageForMe(MessageModel message) async { try { await _chat.deleteMessageForMe(widget.chatId, message.id); } catch (e) { debugPrint('delete message for me: $e'); } }
  Future<void> _editMessage(MessageModel message) async {
    final controller=TextEditingController(text: message.text ?? '');
    final result=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('تعديل الرسالة'),
      content:TextField(controller:controller,maxLines:5,autofocus:true,decoration:const InputDecoration(hintText:'نص الرسالة')),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,controller.text.trim()),child:const Text('حفظ'))]));
    controller.dispose();
    if(result==null||result.isEmpty||result==message.text?.trim())return;
    try{await _chat.editMessage(widget.chatId,message.id,result);}catch(e){if(mounted)ToastService.showError('تعذر تعديل الرسالة.');debugPrint('edit message: $e');}
  }
  Future<void> _confirmDeleteMessage(MessageModel message) async {
    final all=message.senderId==_auth.currentUser?.uid;
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(all?'حذف الرسالة؟':'حذف الرسالة لديك؟'),
      content:Text(all?'سيتم حذف الرسالة لدى جميع المشاركين.':'سيتم إخفاء الرسالة لديك فقط.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حذف'))]));
    if(ok!=true)return;
    if(all)await _deleteMessage(message);else await _deleteMessageForMe(message);
  }
  Future<void> _showPinnedMessages() async {
    try{
      final items=await _chat.getPinnedMessages(widget.chatId);
      if(!mounted)return;
      showModalBottomSheet<void>(context:context,isScrollControlled:true,builder:(ctx)=>SafeArea(child:SizedBox(
        height:MediaQuery.of(ctx).size.height*.55,
        child:Column(children:[
          const Padding(padding:EdgeInsets.all(16),child:Text('الرسائل المثبتة',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800))),
          Expanded(child:items.isEmpty?const Center(child:Text('لا توجد رسائل مثبتة')):ListView.separated(
            itemCount:items.length,separatorBuilder:(_,__)=>const Divider(height:1),
            itemBuilder:(_,i){final m=items[i];return ListTile(
              leading:const Icon(Icons.push_pin_outlined,color:AppColors.primary),
              title:Text(m.text?.isNotEmpty==true?m.text!:'مرفق',maxLines:2,overflow:TextOverflow.ellipsis),
              subtitle:Text(m.senderName),onTap:()=>Navigator.pop(ctx));}))
        ]))));
    }catch(e){if(mounted)ToastService.showError('تعذر تحميل الرسائل المثبتة.');debugPrint('pinned messages: $e');}
  }

  Future<void> _deleteMessage(MessageModel message) async {
    if (message.senderId != _auth.currentUser?.uid) return;
    try {
      await _chat.deleteMessage(widget.chatId, message.id);
    } catch (e) {
      debugPrint('delete message: $e');
    }
  }

  void _startReply(MessageModel message) {
    setState(() => _replyingTo = message);
    ChatReplyContext.instance.set(widget.chatId, message);
  }

  void _clearReply() {
    setState(() => _replyingTo = null);
    ChatReplyContext.instance.clear(widget.chatId);
  }

  Future<void> _shareLocation() async {
    try {
      final location = await Navigator.of(context).push<ChatLocationData>(
        MaterialPageRoute(builder: (_) => const ChatLocationPicker()),
      );
      if (!mounted || location == null) return;
      final url = 'https://www.openstreetmap.org/?mlat=${location.latitude}&mlon=${location.longitude}#map=18/${location.latitude}/${location.longitude}';
      await _chat.sendMessage(
        chatId: widget.chatId,
        text: location.address,
        locationUrl: url,
        locationLat: location.latitude,
        locationLng: location.longitude,
        locationAddress: location.address,
        metadata: {
          'locationStreet': location.street,
          'locationNeighborhood': location.neighborhood,
          'locationCity': location.city,
          'locationState': location.state,
          'locationCountry': location.country,
          'osmType': location.osmType,
          'osmId': location.osmId,
        },
      );
    } catch (e) {
      debugPrint('share chat location: $e');
      ToastService.showError('تعذر إرسال الموقع حالياً.');
    }
  }

  UploadStatus? _uploadStatusFor(Map<String, dynamic> message) {
    if (!message.containsKey('type')) return null;
    final type = message['type']?.toString();
    if (!{'image', 'video', 'audio', 'file'}.contains(type)) return null;
    if (message['isLocal'] == true) {
      switch (message['uploadStatus']?.toString()) {
        case 'failed':
          return UploadStatus.failed;
        case 'pending':
          return UploadStatus.pending;
        case 'uploading':
          return UploadStatus.uploading;
      }
      if (message['hasError'] == true) return UploadStatus.failed;
      if (message['isUploading'] == true) return UploadStatus.uploading;
    }
    if (message['isLocal'] != true &&
        message['senderId'] == _auth.currentUser?.uid)
      return UploadStatus.delivered;
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_firestore.collection('users').doc(uid).set({'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
      unawaited(_markDeliveryAndRead());
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      unawaited(_firestore.collection('users').doc(uid).set({'isOnline': false, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      unawaited(_firestore.collection('users').doc(uid).set({'isOnline': false, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
    }
    _pendingRefreshTimer?.cancel();
    _typingClearTimer?.cancel();
    unawaited(_setTyping(false));
    _messagesSub?.cancel();
    _chatSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final image = widget.otherUserImage ?? widget.groupImage;
    final all = <Map<String, dynamic>>[
      ..._localMedia,
      ..._messages.map((m) => m.toFirestore()..['id'] = m.id)
    ];
    all.sort((a, b) =>
        _messageTime(b['timestamp']).compareTo(_messageTime(a['timestamp'])));
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFE3F1EF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF101827) : const Color(0xFFF7FBFA),
        foregroundColor: dark ? null : AppColors.primary,
        leading: BackButton(color: dark ? null : AppColors.primary),
        titleSpacing: 0,
        title: StreamBuilder<UserStatusModel?>(
            stream: _statusService.streamUserStatus(widget.otherUserId),
            builder: (context, snapshot) {
              final status = snapshot.data;
              final hasStoryImage =
                  status != null &&
                  status.stories.isNotEmpty &&
                  status.stories.first.type == 'image' &&
                  status.stories.first.url.isNotEmpty;
              final avatar = InkWell(
                onTap: status != null && status.stories.isNotEmpty
                    ? () => _openOtherUserStatus(status)
                    : _profile,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: status != null && status.stories.isNotEmpty
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: ClipOval(
                    child: hasStoryImage
                        ? CachedNetworkImage(
                            imageUrl: status.stories.first.url,
                            fit: BoxFit.cover,
                          )
                        : image != null
                            ? CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.primary.withOpacity(.12),
                                child: Center(
                                  child: Text(
                                    widget.otherUserName.isEmpty
                                        ? 'م'
                                        : widget.otherUserName.substring(0, 1),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ),
              );
              return Row(children: [
                avatar,
                const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.isGroup ? 'المجموعة' : widget.otherUserName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: dark ? null : AppColors.primary)),
                    Text(
                        _otherTyping
                            ? 'يكتب الآن...'
                            : (_online ? 'متصل الآن' : _lastSeenLabel()),
                        style: TextStyle(
                            fontSize: 11,
                            color: _otherTyping
                                ? AppColors.primary
                                : (_online ? Colors.green : Colors.grey)))
                  ]))
              ]);
            },
          ),
        actions: [
          IconButton(
              onPressed: _searchMessages,
              tooltip: 'البحث داخل الرسائل',
              icon: Icon(Icons.search_rounded,
                  color: dark ? null : AppColors.primary)),
          if (!widget.isGroup)
            IconButton(
                onPressed: () => _call(false),
                icon: Icon(Icons.call_rounded,
                    color: dark ? null : AppColors.primary)),
          if (!widget.isGroup)
            IconButton(
                onPressed: () => _call(true),
                icon: Icon(Icons.videocam_rounded,
                    color: dark ? null : AppColors.primary)),
          PopupMenuButton<String>(
              iconColor: dark ? null : AppColors.primary,
              onSelected: (value) {
                if (value == 'mute') _toggleMute();
                if (value == 'pin') _togglePin();
                if (value == 'pinned') _showPinnedMessages();
                if (value == 'profile') _profile();
                if (value == 'delete') _deleteChatForMe();
              },
              itemBuilder: (_) => [
                    const PopupMenuItem(value: 'profile', child: Text('معلومات جهة الاتصال')),
                    const PopupMenuItem(value: 'pinned', child: Text('الرسائل المثبتة')),
                    PopupMenuItem(value: 'mute', child: Text(_muted ? 'إلغاء كتم الإشعارات' : 'كتم الإشعارات')),
                    PopupMenuItem(value: 'pin', child: Text(_pinned ? 'إلغاء تثبيت المحادثة' : 'تثبيت المحادثة')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'delete', child: Text('حذف المحادثة لدي')),
                  ])
        ],
      ),
      body: Column(children: [
        Expanded(
            child: ChatBackground(
                child: Stack(children: [
          if (all.isEmpty)
            Center(
                child: Text('ابدأ المحادثة',
                    style: TextStyle(
                        color: dark ? Colors.white70 : const Color(0xFF49615E),
                        fontWeight: FontWeight.w600)))
          else
            ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: all.length,
                itemBuilder: (_, index) {
                  final message = all[index];
                  final remote = message['isLocal'] != true;
                  final rawMessageId = message['id']?.toString();
                  final model = remote && rawMessageId != null
                      ? _messages.firstWhere(
                          (m) => m.id == rawMessageId,
                          orElse: () => MessageModel(
                              id: '', chatId: '', senderId: '', senderName: ''))
                      : null;
                  final status = _uploadStatusFor(message);
                  final messageId = rawMessageId ?? index.toString();
                  final messageKey = _messageKeys.putIfAbsent(messageId, GlobalKey.new);
                  Widget bubble = MessageBubble(
                      key: ValueKey(messageId),
                      message: message,
                      isMe: message['senderId'] == _auth.currentUser?.uid ||
                          message['isLocal'] == true,
                      onReply: model == null || model.id.isEmpty
                          ? null
                          : () => _startReply(model),
                      onDelete: model == null || model.id.isEmpty || model.senderId != _auth.currentUser?.uid ? null : () => _confirmDeleteMessage(model),
                      onEdit: model == null || model.id.isEmpty || model.senderId != _auth.currentUser?.uid ? null : () => _editMessage(model),
                      onDeleteForMe: model == null || model.id.isEmpty
                          ? null
                          : () => _deleteMessageForMe(model),
                      onPin: model == null || model.id.isEmpty
                          ? null
                          : () => _toggleMessagePin(model),
                      onCallAgain: (_) => _call(false),
                      onReaction: remote && messageId != null
                          ? (emoji) => _chat.addReaction(
                              widget.chatId, messageId, emoji)
                          : null);
                  if (messageId != null && _newMessageIds.contains(messageId)) {
                    bubble = TweenAnimationBuilder<double>(
                        key: ValueKey('entrance-$messageId'),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child)),
                        child: bubble);
                  }
                  Widget messageWidget = status == null
                      ? bubble
                      : Stack(clipBehavior: Clip.none, children: [
                          bubble,
                          MediaUploadStatusWidget(
                              status: status,
                              progress:
                                  (message['uploadProgress'] as num?)?.toDouble() ??
                                      0.0,
                              onRetry: () => message['onRetry']?.call(),
                              onCancel: () => message['onCancel']?.call())
                        ]);
                  if (model != null && model.id.isNotEmpty) {
                    messageWidget = _SwipeToReply(
                      onReply: () => _startReply(model),
                      child: messageWidget,
                    );
                  }
                  return messageWidget;
                }),
          if (_loading)
            Positioned.fill(
                child: IgnorePointer(
                    child: ColoredBox(
                        color: dark
                            ? const Color(0xFF0B1121).withOpacity(.12)
                            : const Color(0xFFE3F1EF).withOpacity(.12),
                        child: Center(
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary))))))
        ]))),
        AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: FadeTransition(opacity: animation, child: child)),
            child: _replyingTo == null
                ? const SizedBox.shrink(key: ValueKey('no-reply'))
                : _replyBanner(_replyingTo!)),
        ChatInputBar(
            chatId: widget.chatId,
            onSendMessage: (_) {
              unawaited(_setTyping(false));
              if (_replyingTo != null) _clearReply();
            },
            onTyping: _setTyping,
            onSendImage: (_) {},
            onLocalMedia: _addLocalMedia,
            onShareLocation: _shareLocation),
      ]),
    );
  }

  Widget _replyBanner(MessageModel message) {
    final text = message.text?.trim().isNotEmpty == true
        ? message.text!.trim()
        : _replyTypeLabel(message.type);
    return Material(
        key: ValueKey('reply-${message.id}'),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF162039)
            : const Color(0xFFF7FBFA),
        child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(
                border: Border(
                    top:
                        BorderSide(color: AppColors.primary.withOpacity(.35)))),
            child: Row(children: [
              Container(
                  width: 3,
                  height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 9),
              const Icon(Icons.reply, color: AppColors.primary, size: 19),
              const SizedBox(width: 7),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('الرد على ${message.senderName}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12))
                  ])),
              IconButton(
                  onPressed: _clearReply,
                  icon: const Icon(Icons.close, size: 19))
            ])));
  }

  String _replyTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'صورة';
      case MessageType.video:
        return 'فيديو';
      case MessageType.audio:
        return 'رسالة صوتية';
      case MessageType.file:
        return 'ملف';
      case MessageType.location:
        return 'موقع';
      default:
        return 'رسالة';
    }
  }
}

