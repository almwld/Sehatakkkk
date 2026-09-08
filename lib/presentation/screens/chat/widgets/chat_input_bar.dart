import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/reliable_message_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class ChatInputBar extends StatefulWidget {
  final String chatId;
  final Function(String) onSendMessage;
  final Function(String)? onSendImage;
  final VoidCallback? onShareLocation;

  const ChatInputBar({
    super.key,
    required this.chatId,
    required this.onSendMessage,
    this.onSendImage,
    this.onShareLocation,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _nextcloud = NextcloudService();

  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String? _recordingPath;
  bool _isRecording = false;
  bool _isSending = false;

  late final AnimationController _switchController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_hasText) {
      _switchController.forward();
    } else {
      _switchController.reverse();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _recorder.dispose();
    _switchController.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await ReliableMessageService.sendText(
        chatId: widget.chatId,
        text: text,
      );
      _controller.clear();
    } catch (e) {
      ToastService.showError('تعذر إرسال الرسالة. تحقق من الاتصال وحاول مجددًا.');
      debugPrint('Chat text error: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<String?> _upload(File file, String folder) async {
    try {
      final result = await _nextcloud.uploadFile(
        file: file,
        path: 'chats/${widget.chatId}/$folder',
      );
      return result.success ? result.url : null;
    } catch (e) {
      debugPrint('Nextcloud upload error: $e');
      return null;
    }
  }

  Future<void> _sendImage({required ImageSource source}) async {
    if (_isSending) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    await _sendPickedFile(
      File(picked.path),
      type: 'image',
      folder: 'images',
      text: '📷 صورة',
      extra: const {'imageUrl': null},
    );
  }

  Future<void> _sendVideo() async {
    if (_isSending) return;
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
    );
    if (picked == null) return;

    await _sendPickedFile(
      File(picked.path),
      type: 'video',
      folder: 'videos',
      text: '🎬 فيديو',
      extra: const {'videoUrl': null},
    );
  }

  Future<void> _sendFile() async {
    if (_isSending) return;
    final result = await FilePicker.platform.pickFiles(
      withData: false,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;

    final item = result.files.single;
    await _sendPickedFile(
      File(item.path!),
      type: 'file',
      folder: 'files',
      text: '📎 ${item.name}',
      extra: {
        'fileName': item.name,
        'fileSize': _formatBytes(item.size),
        'fileMimeType': item.extension == null
            ? null
            : 'application/${item.extension}',
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _sendPickedFile(
    File file, {
    required String type,
    required String folder,
    required String text,
    required Map<String, dynamic> extra,
  }) async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      final url = await _upload(file, folder);
      final user = _auth.currentUser;
      if (url == null || user == null) throw Exception('upload_failed');

      final data = <String, dynamic>{
        'type': type,
        'text': text,
        ...extra,
      };
      if (type == 'image') data['imageUrl'] = url;
      if (type == 'video') data['videoUrl'] = url;
      if (type == 'file') data['fileUrl'] = url;

      await _writeMediaMessage(user, data);
      if (type == 'image') widget.onSendImage?.call(url);
    } catch (e) {
      final message = type == 'video'
          ? 'تعذر إرسال الفيديو.'
          : type == 'file'
              ? 'تعذر إرسال الملف.'
              : 'تعذر إرسال الصورة.';
      ToastService.showError(message);
      debugPrint('Media send error: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _writeMediaMessage(
    User user,
    Map<String, dynamic> data,
  ) async {
    final payload = <String, dynamic>{
      'chatId': widget.chatId,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'senderPhotoUrl': user.photoURL,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': false,
      'isDeleted': false,
      'isEdited': false,
      'reactions': <String, dynamic>{},
      ...data,
    };

    final chatRef = _firestore.collection('chats').doc(widget.chatId);
    final ref = chatRef.collection('messages').doc();
    final batch = _firestore.batch();

    batch.set(ref, payload);
    batch.update(chatRef, {
      'lastMessage': payload['text'],
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> _startRecording() async {
    if (_hasText || _isRecording || _isSending) return;
    if (!await _recorder.hasPermission()) {
      ToastService.showError('يلزم السماح بالوصول إلى الميكروفون.');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/chat_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() => _recordingDuration += const Duration(seconds: 1));
        }
      },
    );

    setState(() {
      _isRecording = true;
      _recordingPath = path;
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    _recordingTimer?.cancel();
    final path = _recordingPath;
    _recordingPath = null;
    if (!_isRecording) return;

    await _recorder.stop();
    if (mounted) setState(() => _isRecording = false);
    if (path == null) return;

    final file = File(path);
    if (cancel) {
      if (await file.exists()) await file.delete();
      return;
    }

    if (!await file.exists() || await file.length() < 1000) {
      if (await file.exists()) await file.delete();
      ToastService.showError('التسجيل قصير جدًا.');
      return;
    }

    setState(() => _isSending = true);
    try {
      final url = await _upload(file, 'audio');
      final user = _auth.currentUser;
      if (url == null || user == null) {
        throw Exception('audio_upload_failed');
      }

      await _writeMediaMessage(user, {
        'type': 'audio',
        'text': '🎵 رسالة صوتية',
        'audioUrl': url,
        'duration': _recordingDuration.inSeconds,
      });
    } catch (e) {
      ToastService.showError('تعذر إرسال التسجيل الصوتي.');
      debugPrint('Audio send error: $e');
    } finally {
      if (await file.exists()) await file.delete();
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _durationText(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _assetIcon(String name, {double size = 24}) {
    return Image.asset(
      'assets/images/chat/$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF172033) : Colors.white;
    final field = dark ? const Color(0xFF26344D) : const Color(0xFFF1F4F5);

    return Material(
      color: background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isRecording
                ? _recordingBar(field)
                : _inputRow(field),
          ),
        ),
      ),
    );
  }

  Widget _inputRow(Color field) {
    return Row(
      key: const ValueKey('input'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _roundButton(
          asset: 'attach_file',
          onTap: _showAttachmentOptions,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: field,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _animatedVoiceSendButton(),
      ],
    );
  }

  Widget _animatedVoiceSendButton() {
    return GestureDetector(
      onTap: _hasText ? _sendText : null,
      onLongPress: _hasText ? null : _startRecording,
      onLongPressUp: _hasText ? null : _stopRecording,
      child: SizedBox(
        width: 50,
        height: 50,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );
            return ScaleTransition(
              scale: curved,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _hasText
              ? Container(
                  key: const ValueKey('send'),
                  decoration: BoxDecoration(
                    color: _isSending ? Colors.grey : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(13),
                  child: _assetIcon('send_button', size: 24),
                )
              : Container(
                  key: const ValueKey('mic'),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(13),
                  child: _assetIcon('microphone', size: 24),
                ),
        ),
      ),
    );
  }

  Widget _recordingBar(Color field) {
    return Container(
      key: const ValueKey('recording'),
      height: 50,
      decoration: BoxDecoration(
        color: field,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _stopRecording(cancel: true),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '✕',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          ),
          const Text('●', style: TextStyle(color: Colors.red)),
          const SizedBox(width: 8),
          Text(
            _durationText(_recordingDuration),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 3),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _assetIcon('send_button', size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required String asset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Center(child: _assetIcon(asset, size: 25)),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Wrap(
            spacing: 20,
            runSpacing: 18,
            children: [
              _attachment('gallery', 'المعرض', () {
                Navigator.pop(context);
                _sendImage(source: ImageSource.gallery);
              }),
              _attachment('camera', 'الكاميرا', () {
                Navigator.pop(context);
                _sendImage(source: ImageSource.camera);
              }),
              _attachment('camera', 'فيديو', () {
                Navigator.pop(context);
                _sendVideo();
              }),
              _attachment('file', 'ملف', () {
                Navigator.pop(context);
                _sendFile();
              }),
              _attachment('location', 'الموقع', () {
                Navigator.pop(context);
                widget.onShareLocation?.call();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachment(String asset, String label, VoidCallback onTap) {
    return SizedBox(
      width: 75,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _assetIcon(asset, size: 28),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
