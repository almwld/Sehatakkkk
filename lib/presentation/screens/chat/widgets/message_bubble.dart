import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final Function(String)? onReaction;

  const MessageBubble({super.key, required this.message, required this.isMe, this.onReply, this.onDelete, this.onReaction});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.message['type'] == 'audio' && (widget.message['audioUrl'] ?? '').toString().isNotEmpty) _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final type = (widget.message['type'] ?? 'text').toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: widget.isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
          child: _buildContent(type, dark),
        ),
      ),
    );
  }

  Widget _shell(Widget child, bool dark) => GestureDetector(
    onLongPress: () => _showMessageOptions(widget.message),
    child: Container(
      decoration: BoxDecoration(color: widget.isMe ? AppColors.primary : (dark ? const Color(0xFF1A2540) : Colors.grey[100]), borderRadius: BorderRadius.circular(14)),
      child: child,
    ),
  );

  Widget _buildContent(String type, bool dark) {
    switch (type) {
      case 'image': return _buildImage(widget.message['imageUrl']?.toString() ?? '', dark);
      case 'video': return _buildVideo(widget.message['videoUrl']?.toString() ?? widget.message['fileUrl']?.toString() ?? '', dark);
      case 'audio': return _buildAudio(widget.message, dark);
      case 'file': return _buildFile(widget.message, dark);
      case 'location': return _buildLocation(widget.message, dark);
      case 'system': return _buildSystem(widget.message);
      default: return _buildText(widget.message, dark);
    }
  }

  Widget _buildText(Map<String, dynamic> m, bool dark) => _shell(
    Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9), child: Text(m['text']?.toString() ?? '', style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87), fontSize: 14))), dark);

  Widget _buildImage(String url, bool dark) {
    if (url.isEmpty) return _buildText({'text': 'تعذر تحميل الصورة'}, dark);
    return GestureDetector(
      onTap: () => showDialog(context: context, barrierColor: Colors.black87, builder: (_) => Dialog(backgroundColor: Colors.transparent, child: InteractiveViewer(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)))),
      onLongPress: () => _showMessageOptions(widget.message),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: CachedNetworkImage(imageUrl: url, width: 230, height: 230, fit: BoxFit.cover, placeholder: (_, __) => const SizedBox(width: 230, height: 230, child: Center(child: CircularProgressIndicator(strokeWidth: 2))), errorWidget: (_, __, ___) => const SizedBox(width: 230, height: 230, child: Center(child: Text('تعذر تحميل الصورة'))))),
    );
  }

  Widget _buildVideo(String url, bool dark) {
    if (url.isEmpty) return _buildText({'text': 'تعذر تحميل الفيديو'}, dark);
    return GestureDetector(
      onTap: () => showDialog(context: context, builder: (_) => _VideoViewer(url: url)),
      onLongPress: () => _showMessageOptions(widget.message),
      child: Container(width: 230, height: 160, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)), child: Stack(children: [const Center(child: Text('▶', style: TextStyle(color: Colors.white, fontSize: 46))), Positioned(bottom: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: const Text('فيديو', style: TextStyle(color: Colors.white, fontSize: 10))))])),
    );
  }

  Widget _buildAudio(Map<String, dynamic> m, bool dark) {
    final url = m['audioUrl']?.toString() ?? '';
    final duration = _duration(m['duration'] ?? m['audioDuration']);
    return _shell(Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), child: Row(mainAxisSize: MainAxisSize.min, children: [GestureDetector(onTap: () => _toggleAudio(url), child: Text(_isPlaying ? '❚❚' : '▶', style: TextStyle(color: widget.isMe ? Colors.white : AppColors.primary, fontSize: 24))), const SizedBox(width: 10), SizedBox(width: 125, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 4, decoration: BoxDecoration(color: widget.isMe ? Colors.white38 : Colors.black12, borderRadius: BorderRadius.circular(3))), const SizedBox(height: 5), Text(_formatDuration(duration), style: TextStyle(color: widget.isMe ? Colors.white70 : Colors.black54, fontSize: 10))])), const SizedBox(width: 7), const Text('🎵', style: TextStyle(fontSize: 16))])), dark);
  }

  int _duration(dynamic value) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _toggleAudio(String url) async {
    if (url.isEmpty) return;
    try {
      if (_isPlaying) { await _audioPlayer?.pause(); if (mounted) setState(() => _isPlaying = false); return; }
      await _audioPlayer?.play(UrlSource(url));
      if (mounted) setState(() => _isPlaying = true);
      _audioPlayer?.onPlayerComplete.listen((_) { if (mounted) setState(() => _isPlaying = false); });
    } catch (e) { ToastService.showError('تعذر تشغيل التسجيل الصوتي'); debugPrint('Audio playback error: $e'); }
  }

  Widget _buildFile(Map<String, dynamic> m, bool dark) {
    final url = m['fileUrl']?.toString() ?? '';
    final name = m['fileName']?.toString().trim().isNotEmpty == true ? m['fileName'].toString() : 'ملف';
    final size = m['fileSize']?.toString() ?? '';
    return _shell(InkWell(onTap: () async { if (url.isEmpty) return; final uri = Uri.tryParse(url); if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); else ToastService.showError('تعذر فتح الملف'); }, child: Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('📎', style: TextStyle(fontSize: 25)), const SizedBox(width: 10), Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87), fontWeight: FontWeight.w600)), if (size.isNotEmpty) Text(size, style: TextStyle(color: widget.isMe ? Colors.white70 : Colors.black54, fontSize: 10))]))]))), dark);
  }

  Widget _buildLocation(Map<String, dynamic> m, bool dark) => _shell(InkWell(onTap: () async { final url = m['locationUrl']?.toString() ?? ''; final uri = Uri.tryParse(url); if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('📍', style: TextStyle(fontSize: 22)), const SizedBox(width: 8), Flexible(child: Text(m['locationAddress']?.toString().isNotEmpty == true ? m['locationAddress'].toString() : (m['text']?.toString() ?? 'الموقع'), style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87))))]))), dark);

  Widget _buildSystem(Map<String, dynamic> m) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)), child: Text(m['text']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.black54))));

  String _formatDuration(int seconds) => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => SafeArea(child: Wrap(children: [if (widget.onReply != null) ListTile(title: const Text('رد'), onTap: () { Navigator.pop(context); widget.onReply!.call(); }), if (widget.onDelete != null) ListTile(title: const Text('حذف'), onTap: () { Navigator.pop(context); widget.onDelete!.call(); }), ListTile(title: const Text('نسخ'), onTap: () { Navigator.pop(context); ToastService.showSuccess('تم نسخ النص'); })])));
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;
  const _VideoViewer({required this.url});
  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late final VideoPlayerController _controller;
  @override
  void initState() { super.initState(); _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) { if (mounted) setState(() {}); }); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Dialog(backgroundColor: Colors.black, insetPadding: const EdgeInsets.all(12), child: _controller.value.isInitialized ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: Stack(alignment: Alignment.center, children: [VideoPlayer(_controller), IconButton(icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 48), onPressed: () { setState(() { _controller.value.isPlaying ? _controller.pause() : _controller.play(); }); })])) : const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
}
