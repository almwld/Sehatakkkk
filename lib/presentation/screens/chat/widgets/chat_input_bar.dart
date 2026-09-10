import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_media_transfer_service.dart';
import 'package:sehatak/core/services/reliable_message_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class ChatInputBar extends StatefulWidget {
  final String chatId;
  final Function(String) onSendMessage;
  final Function(String)? onSendImage;
  final Function(Map<String, dynamic>)? onLocalMedia;
  final VoidCallback? onShareLocation;

  const ChatInputBar({
    super.key,
    required this.chatId,
    required this.onSendMessage,
    this.onSendImage,
    this.onLocalMedia,
    this.onShareLocation,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  Timer? _timer;
  Duration _duration = Duration.zero;
  String? _recordPath;
  bool _recording = false;
  bool _paused = false;
  bool _sending = false;
  bool _attachments = false;

  bool get _hasText => _controller.text.trim().isNotEmpty;
  bool get _hasRecording => _recordPath != null;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending || _recording || _hasRecording) return;
    setState(() => _sending = true);
    try {
      await ReliableMessageService.sendText(chatId: widget.chatId, text: text);
      widget.onSendMessage(text);
      _controller.clear();
    } catch (e) {
      debugPrint('chat text send: $e');
      ToastService.showError('تعذر إرسال الرسالة. تحقق من الاتصال.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _enqueueMedia(
    File file, {
    required String type,
    required String folder,
    required String preview,
    String? name,
    String? size,
    String? mime,
    String? audioDuration,
  }) async {
    final id = await ChatMediaTransferService.instance.enqueue(
      chatId: widget.chatId,
      sourceFile: file,
      type: type,
      folder: folder,
      preview: preview,
      fileName: name,
      fileSize: size,
      mimeType: mime,
      audioDuration: audioDuration,
    );

    // The original local file is shown immediately. The persistent outbox owns
    // its copied version and will continue after the widget/app is rebuilt.
    widget.onLocalMedia?.call({
      'id': id,
      'chatId': widget.chatId,
      'senderId': 'local',
      'senderName': 'مستخدم',
      'type': type,
      'text': preview,
      'imageUrl': type == 'image' ? file.path : null,
      'videoUrl': type == 'video' ? file.path : null,
      'audioUrl': type == 'audio' ? file.path : null,
      'fileUrl': type == 'file' ? file.path : null,
      'fileName': name ?? file.path.split(Platform.pathSeparator).last,
      'fileSize': size,
      'fileMimeType': mime,
      'audioDuration': audioDuration,
      'isLocal': true,
      'isSending': true,
      'isUploading': true,
      'uploadProgress': 0.0,
      'outboxId': id,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _sendMedia(
    File file, {
    required String type,
    required String folder,
    required String preview,
    String? name,
    String? size,
    String? mime,
  }) async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _attachments = false;
    });
    try {
      await _enqueueMedia(file, type: type, folder: folder, preview: preview, name: name, size: size, mime: mime);
    } catch (e) {
      debugPrint('media enqueue: $e');
      ToastService.showError('تعذر تجهيز الوسائط للإرسال.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final x = await _picker.pickImage(source: source, imageQuality: 90);
    if (x != null) await _sendMedia(File(x.path), type: 'image', folder: 'images', preview: '📷 صورة');
  }

  Future<void> _pickVideo() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 10));
    if (x != null) await _sendMedia(File(x.path), type: 'video', folder: 'videos', preview: '🎬 فيديو');
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    final picked = result?.files.single;
    if (picked?.path == null) return;
    await _sendMedia(
      File(picked!.path!),
      type: 'file',
      folder: 'files',
      preview: '📎 ${picked.name}',
      name: picked.name,
      size: _formatBytes(picked.size),
      mime: picked.extension == null ? null : 'application/${picked.extension}',
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  Future<void> _startRecording() async {
    if (_sending || _recording || _hasRecording || _hasText) return;
    if (!await _recorder.hasPermission()) {
      ToastService.showError('يلزم السماح بالوصول إلى الميكروفون.');
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/sehatak_chat_${DateTime.now().millisecondsSinceEpoch}.m4a';
    try {
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      _duration = Duration.zero;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _recording && !_paused) setState(() => _duration += const Duration(seconds: 1));
      });
      setState(() {
        _recording = true;
        _paused = false;
        _recordPath = path;
      });
    } catch (e) {
      debugPrint('record start: $e');
      ToastService.showError('تعذر بدء التسجيل الصوتي.');
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;
    _timer?.cancel();
    try {
      await _recorder.stop();
    } catch (e) {
      debugPrint('record stop: $e');
    }
    if (mounted) setState(() { _recording = false; _paused = false; });
  }

  Future<void> _togglePause() async {
    if (!_recording) return;
    try {
      if (_paused) {
        await _recorder.resume();
      } else {
        await _recorder.pause();
      }
      if (mounted) setState(() => _paused = !_paused);
    } catch (e) {
      debugPrint('record pause/resume: $e');
    }
  }

  Future<void> _deleteRecording() async {
    _timer?.cancel();
    try { await _recorder.stop(); } catch (_) {}
    final path = _recordPath;
    _recordPath = null;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    if (mounted) setState(() { _recording = false; _paused = false; _duration = Duration.zero; });
  }

  Future<void> _sendRecording() async {
    if (_sending || _recordPath == null) return;
    if (_recording) await _stopRecording();
    final path = _recordPath;
    if (path == null) return;
    final file = File(path);
    if (!await file.exists() || await file.length() < 1000) {
      await _deleteRecording();
      ToastService.showError('التسجيل قصير جدًا.');
      return;
    }
    setState(() => _sending = true);
    try {
      await _enqueueMedia(
        file,
        type: 'audio',
        folder: 'audio',
        preview: '🎤 رسالة صوتية',
        name: file.path.split(Platform.pathSeparator).last,
        mime: 'audio/mp4',
        audioDuration: _duration.inSeconds.toString(),
      );
      _recordPath = null;
      _duration = Duration.zero;
    } catch (e) {
      debugPrint('audio enqueue: $e');
      ToastService.showError('تعذر تجهيز التسجيل للإرسال.');
    } finally {
      try { if (await file.exists()) await file.delete(); } catch (_) {}
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (_recording || _hasRecording) return _voiceBar(dark);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_attachments) _mediaMenu(dark),
        Material(
          color: dark ? const Color(0xFF121A29) : Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(onPressed: _sending ? null : () => setState(() => _attachments = !_attachments), icon: const Icon(Icons.add_circle_outline)),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 46, maxHeight: 130),
                      decoration: BoxDecoration(color: dark ? const Color(0xFF26344D) : const Color(0xFFF1F4F5), borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        minLines: 1,
                        maxLines: 5,
                        textDirection: TextDirection.rtl,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(hintText: 'اكتب رسالة...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 11)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _hasText ? _sendText : _startRecording,
                    child: CircleAvatar(radius: 23, backgroundColor: _sending ? Colors.grey : AppColors.primary, child: Icon(_hasText ? Icons.send_rounded : Icons.mic_rounded, color: Colors.white, size: 21)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _voiceBar(bool dark) => Material(
    color: dark ? const Color(0xFF121A29) : Colors.white,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            IconButton(onPressed: _sending ? null : _deleteRecording, icon: const Icon(Icons.delete_outline, color: Colors.red)),
            IconButton(onPressed: _sending || !_recording ? null : _togglePause, icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: AppColors.primary)),
            Expanded(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: dark ? const Color(0xFF26344D) : const Color(0xFFF1F4F5), borderRadius: BorderRadius.circular(23)),
                child: Row(children: [
                  Icon(_recording ? Icons.mic : Icons.mic_none, color: _recording ? Colors.red : AppColors.primary),
                  const SizedBox(width: 8),
                  Text('${_duration.inMinutes.toString().padLeft(2, '0')}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}'),
                  const SizedBox(width: 10),
                  const Expanded(child: LinearProgressIndicator(minHeight: 3)),
                ]),
              ),
            ),
            IconButton(onPressed: _sending ? null : (_recording ? _stopRecording : _sendRecording), icon: Icon(_recording ? Icons.stop_circle_outlined : Icons.send_rounded, color: AppColors.primary, size: 29)),
          ],
        ),
      ),
    ),
  );

  Widget _mediaMenu(bool dark) => Container(
    padding: const EdgeInsets.all(10),
    color: dark ? const Color(0xFF121A29) : Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _mediaItem(Icons.camera_alt, 'كاميرا', () => _pickImage(ImageSource.camera)),
        _mediaItem(Icons.photo, 'صورة', () => _pickImage(ImageSource.gallery)),
        _mediaItem(Icons.video_library, 'فيديو', _pickVideo),
        _mediaItem(Icons.attach_file, 'ملف', _pickFile),
      ],
    ),
  );

  Widget _mediaItem(IconData icon, String label, VoidCallback action) => InkWell(
    onTap: action,
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Column(children: [
        CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.1), child: Icon(icon, color: AppColors.primary)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 10)),
      ]),
    ),
  );
}
