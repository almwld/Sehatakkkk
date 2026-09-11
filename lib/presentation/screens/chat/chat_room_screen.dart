import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:sehatak/core/services/chat_media_transfer_service.dart';
import 'package:sehatak/core/services/chat_reply_context.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/message_search_screen.dart';
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
  const ChatRoomScreen({super.key, required this.chatId, required this.otherUserId, required this.otherUserName, this.otherUserImage, this.isGroup = false, this.groupImage, this.lastMessage});
  @override State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chat = ChatService();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _chatSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  Timer? _pendingRefreshTimer;
  List<MessageModel> _messages = [];
  final List<Map<String, dynamic>> _localMedia = [];
  bool _loading = true;
  bool _online = false;
  bool _muted = false;
  bool _pinned = false;
  MessageModel? _replyingTo;
  CollectionReference<Map<String, dynamic>> get _messagesRef => _firestore.collection('chats').doc(widget.chatId).collection('messages');
  @override void initState() { super.initState(); _listen(); _loadPendingMedia(); _startPendingRefresh(); _markRead(); }
  void _startPendingRefresh() { _pendingRefreshTimer?.cancel(); var delay = const Duration(seconds: 2); void schedule() { _pendingRefreshTimer = Timer(delay, () async { if (!mounted) return; await _loadPendingMedia(); final pending = _localMedia.isNotEmpty; final nextSeconds = (delay.inSeconds * 2).clamp(2, 16).toInt(); delay = pending ? Duration(seconds: nextSeconds) : const Duration(seconds: 8); schedule(); }); } schedule(); }
  Future<void> _loadPendingMedia() async { try { final jobs = await ChatMediaTransferService.instance.pendingForChat(widget.chatId); if (!mounted) return; setState(() => _localMedia..clear()..addAll(jobs.map(_pendingMap))); } catch (e) { debugPrint('pending media load: $e'); } }
  Map<String, dynamic> _pendingMap(Map<String, dynamic> job) { final type = job['type']?.toString() ?? 'file'; final local = job['local_path']?.toString() ?? ''; final status = job['status']?.toString() ?? 'queued'; final progress = (job['progress'] as num?)?.toDouble() ?? 0.0; return {'id': job['id'], 'chatId': widget.chatId, 'senderId': _auth.currentUser?.uid ?? 'local', 'senderName': _auth.currentUser?.displayName ?? 'مستخدم', 'type': type, 'text': job['preview']?.toString() ?? 'مرفق', 'imageUrl': type == 'image' ? local : null, 'videoUrl': type == 'video' ? local : null, 'audioUrl': type == 'audio' ? local : null, 'fileUrl': type == 'file' ? local : null, 'fileName': job['file_name'], 'fileSize': job['file_size'], 'fileMimeType': job['mime_type'], 'audioDuration': job['audio_duration'], 'isLocal': true, 'isSending': status != 'retry', 'isUploading': status == 'uploading' || status == 'queued' || status == 'retry', 'hasError': status == 'retry', 'uploadProgress': progress, 'outboxId': job['id'], 'timestamp': job['created_at'] ?? DateTime.now().toIso8601String(), 'onRetry': () async { await ChatMediaTransferService.instance.retry(job['id'].toString()); if (mounted) await _loadPendingMedia(); }}; }
  void _addLocalMedia(Map<String, dynamic> media) { if (!mounted) return; setState(() { _localMedia.removeWhere((m) => m['outboxId'] == media['outboxId']); _localMedia.add(media); }); unawaited(_loadPendingMedia()); }
  bool _hiddenForCurrentUser(Map<String, dynamic> data) { final uid = _auth.currentUser?.uid; if (uid == null) return false; final deletedFor = data['deletedFor']; return deletedFor is Map && deletedFor[uid] == true; }
  void _listen() {
    _chatSub = _firestore.collection('chats').doc(widget.chatId).snapshots().listen((snapshot) { if (!mounted || !snapshot.exists) return; final data = snapshot.data() ?? <String, dynamic>{}; final uid = _auth.currentUser?.uid; final mutedFor = data['mutedFor']; final pinnedFor = data['pinnedFor']; setState(() { _muted = uid != null && mutedFor is Map && mutedFor[uid] == true ? true : data['isMuted'] == true && mutedFor is! Map; _pinned = uid != null && pinnedFor is Map && pinnedFor[uid] == true ? true : data['isPinned'] == true && pinnedFor is! Map; }); });
    _userSub = _firestore.collection('users').doc(widget.otherUserId).snapshots().listen((snapshot) { if (mounted) setState(() => _online = snapshot.data()?['isOnline'] == true); });
    _messagesSub = _messagesRef.orderBy('timestamp', descending: true).limit(100).snapshots().listen((snapshot) { if (!mounted) return; final messages = snapshot.docs.map((doc) => MessageModel.fromFirestore(doc.id, doc.data())).where((m) => !_hiddenForCurrentUser(m.toFirestore())).toList(); final remoteIds = messages.map((m) => m.id).toSet(); setState(() { _messages = messages; _localMedia.removeWhere((m) => remoteIds.contains(m['id'])); _loading = false; }); _markRead(); unawaited(_loadPendingMedia()); }, onError: (error) { debugPrint('chat stream: $error'); if (mounted) setState(() => _loading = false); });
  }
  DateTime _messageTime(dynamic value) { if (value is Timestamp) return value.toDate(); if (value is DateTime) return value; if (value is num) { final n = value.toInt(); return DateTime.fromMillisecondsSinceEpoch(n > 100000000000 ? n : n * 1000); } if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0); return DateTime.fromMillisecondsSinceEpoch(0); }
  Future<void> _markRead() async { try { await _chat.markAsRead(widget.chatId); } catch (error) { debugPrint('mark read: $error'); } }
  void _call(bool video) { Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallScreen(chatId: widget.chatId, doctorName: widget.otherUserName, doctorId: widget.otherUserId, doctorImage: widget.otherUserImage ?? widget.groupImage, isVideo: video, isOutgoing: true))); }
  void _profile() { Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ChatContactProfile(userId: widget.otherUserId, name: widget.otherUserName, imageUrl: widget.otherUserImage ?? widget.groupImage))); }
  void _searchMessages() { Navigator.of(context).push(MaterialPageRoute(builder: (_) => MessageSearchScreen(chatId: widget.chatId))); }
  Future<void> _toggleMute() async { try { await _chat.muteChat(widget.chatId, !_muted); } catch (e) { debugPrint('mute chat: $e'); } }
  Future<void> _togglePin() async { try { await _chat.pinChat(widget.chatId, !_pinned); } catch (e) { debugPrint('pin chat: $e'); } }
  Future<void> _deleteMessage(MessageModel message) async { if (message.senderId != _auth.currentUser?.uid) return; try { await _chat.deleteMessage(widget.chatId, message.id); } catch (e) { debugPrint('delete message: $e'); } }
  void _startReply(MessageModel message) { setState(() => _replyingTo = message); ChatReplyContext.instance.set(widget.chatId, message); }
  void _clearReply() { setState(() => _replyingTo = null); ChatReplyContext.instance.clear(widget.chatId); }
  Future<void> _shareLocation() async { try { if (!await Geolocator.isLocationServiceEnabled()) { ToastService.showError('فعّل خدمة الموقع أولاً.'); return; } var permission = await Geolocator.checkPermission(); if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission(); if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) { ToastService.showError('يلزم السماح بالوصول إلى الموقع.'); return; } final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high); String address = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'; try { final marks = await placemarkFromCoordinates(position.latitude, position.longitude); if (marks.isNotEmpty) { final p = marks.first; final parts = [p.street, p.locality, p.administrativeArea].where((x) => x != null && x!.trim().isNotEmpty).map((x) => x!.trim()).toList(); if (parts.isNotEmpty) address = parts.join('، '); } } catch (_) {} final url = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'; await _chat.sendMessage(chatId: widget.chatId, text: address, locationUrl: url); } catch (e) { debugPrint('share location: $e'); ToastService.showError('تعذر إرسال موقعك حالياً.'); } }
  @override void dispose() { _pendingRefreshTimer?.cancel(); _messagesSub?.cancel(); _chatSub?.cancel(); _userSub?.cancel(); ChatReplyContext.instance.clear(widget.chatId); super.dispose(); }
  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final image = widget.otherUserImage ?? widget.groupImage;
    final all = <Map<String, dynamic>>[..._localMedia, ..._messages.map((m) => m.toFirestore()..['id'] = m.id)];
    all.sort((a, b) => _messageTime(b['timestamp']).compareTo(_messageTime(a['timestamp'])));
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF2F5F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF101827) : Colors.white,
        leading: const BackButton(),
        titleSpacing: 0,
        title: InkWell(onTap: _profile, child: Row(children: [CircleAvatar(radius: 21, backgroundColor: AppColors.primary.withOpacity(.12), backgroundImage: image != null ? CachedNetworkImageProvider(image) : null, child: image == null ? Text(widget.otherUserName.isEmpty ? 'م' : widget.otherUserName.substring(0, 1)) : null), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.isGroup ? 'المجموعة' : widget.otherUserName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), Text(_online ? 'متصل الآن' : 'غير متصل', style: TextStyle(fontSize: 11, color: _online ? Colors.green : Colors.grey))]))])),
        actions: [IconButton(onPressed: _searchMessages, tooltip: 'البحث داخل الرسائل', icon: const Icon(Icons.search_rounded)), if (!widget.isGroup) IconButton(onPressed: () => _call(false), icon: const Icon(Icons.call_rounded)), if (!widget.isGroup) IconButton(onPressed: () => _call(true), icon: const Icon(Icons.videocam_rounded)), PopupMenuButton<String>(onSelected: (value) { if (value == 'mute') _toggleMute(); if (value == 'pin') _togglePin(); }, itemBuilder: (_) => [PopupMenuItem(value: 'mute', child: Text(_muted ? 'إلغاء كتم الإشعارات' : 'كتم الإشعارات')), PopupMenuItem(value: 'pin', child: Text(_pinned ? 'إلغاء تثبيت المحادثة' : 'تثبيت المحادثة'))])],
      ),
      body: Column(children: [
        Expanded(child: _loading && all.isEmpty ? const Center(child: CircularProgressIndicator()) : all.isEmpty ? const Center(child: Text('ابدأ المحادثة')) : ChatBackground(child: ListView.builder(reverse: true, padding: const EdgeInsets.all(8), itemCount: all.length, itemBuilder: (_, index) { final message = all[index]; final remote = message['isLocal'] != true; final messageId = message['id']?.toString(); final model = remote && messageId != null ? _messages.firstWhere((m) => m.id == messageId, orElse: () => MessageModel(id: '', chatId: '', senderId: '', senderName: '')) : null; return MessageBubble(key: ValueKey(message['id'] ?? index), message: message, isMe: message['senderId'] == _auth.currentUser?.uid || message['isLocal'] == true, onReply: model == null || model.id.isEmpty ? null : () => _startReply(model), onDelete: model == null || model.id.isEmpty ? null : () => _deleteMessage(model), onCallAgain: (_) => _call(false), onReaction: remote && messageId != null ? (emoji) => _chat.addReaction(widget.chatId, messageId, emoji) : null); }))),
        if (_replyingTo != null) _replyBanner(_replyingTo!),
        ChatInputBar(chatId: widget.chatId, onSendMessage: (_) { if (_replyingTo != null) _clearReply(); }, onSendImage: (_) {}, onLocalMedia: _addLocalMedia, onShareLocation: _shareLocation),
      ]),
    );
  }
  Widget _replyBanner(MessageModel message) { final text = message.text?.trim().isNotEmpty == true ? message.text!.trim() : _replyTypeLabel(message.type); return Material(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF162039) : Colors.white, child: Container(padding: const EdgeInsets.fromLTRB(12, 8, 8, 8), decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.primary.withOpacity(.35)))), child: Row(children: [Container(width: 3, height: 38, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 9), const Icon(Icons.reply, color: AppColors.primary, size: 19), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('الرد على ${message.senderName}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))])), IconButton(onPressed: _clearReply, icon: const Icon(Icons.close, size: 19))]))); }
  String _replyTypeLabel(MessageType type) { switch (type) { case MessageType.image: return 'صورة'; case MessageType.video: return 'فيديو'; case MessageType.audio: return 'رسالة صوتية'; case MessageType.file: return 'ملف'; case MessageType.location: return 'موقع'; default: return 'رسالة'; } }
}

class _ChatContactProfile extends StatelessWidget {
  final String userId; final String name; final String? imageUrl;
  const _ChatContactProfile({required this.userId, required this.name, this.imageUrl});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')), body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(future: FirebaseFirestore.instance.collection('users').doc(userId).get(), builder: (context, snapshot) { final data = snapshot.data?.data() ?? <String, dynamic>{}; final image = imageUrl ?? data['photoUrl']?.toString() ?? data['imageUrl']?.toString(); final displayName = data['name']?.toString() ?? data['displayName']?.toString() ?? name; return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [CircleAvatar(radius: 52, backgroundImage: image != null ? CachedNetworkImageProvider(image) : null, child: image == null ? const Icon(Icons.person, size: 52) : null), const SizedBox(height: 14), Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), if ('${data['specialty'] ?? ''}'.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(data['specialty'].toString())), if ('${data['bio'] ?? ''}'.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(data['bio'].toString(), textAlign: TextAlign.center))]))); }));
}
