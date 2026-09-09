import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/chat/widgets/audio_waveform_bubble.dart';

class MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final Function(String)? onReaction;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
    this.onReaction,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final type = (widget.message['type'] ?? 'text').toString();
    final hasError = widget.message['hasError'] == true;
    final progress = (widget.message['uploadProgress'] as num?)?.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: widget.isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildContent(type, dark),
              if (progress != null && progress >= 0 && progress < 1)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 4,
                  child: LinearProgressIndicator(value: progress, minHeight: 2),
                ),
              if (hasError)
                PositionedDirectional(
                  start: -34,
                  bottom: 8,
                  child: IconButton(
                    tooltip: 'إعادة المحاولة',
                    onPressed: () => widget.message['onRetry']?.call(),
                    icon: const Icon(Icons.refresh, color: Colors.red, size: 22),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shell(Widget child, bool dark) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(widget.message),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isMe ? AppColors.primary : (dark ? const Color(0xFF1A2540) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  Widget _buildContent(String type, bool dark) {
    switch (type) {
      case 'image': return _buildImage(widget.message['imageUrl']?.toString() ?? '', dark);
      case 'video': return _buildVideo(widget.message['videoUrl']?.toString() ?? widget.message['fileUrl']?.toString() ?? '', dark);
      case 'audio':
        final url = widget.message['audioUrl']?.toString() ?? '';
        return _shell(
          AudioWaveformBubble(
            audioUrl: url,
            isMe: widget.isMe,
            isLocal: widget.message['isLocal'] == true || url.startsWith('file://'),
          ),
          dark,
        );
      case 'file': return _buildFile(widget.message, dark);
      case 'location': return _buildLocation(widget.message, dark);
      case 'system': return _buildSystem(widget.message);
      default: return _buildText(widget.message, dark);
    }
  }

  Widget _buildText(Map<String, dynamic> m, bool dark) {
    final reply = m['replyPreview']?.toString().trim() ?? '';
    final text = m['text']?.toString() ?? '';
    final status = _statusWidget(m);
    return _shell(
      Padding(
        padding: const EdgeInsets.fromLTRB(13, 9, 10, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reply.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsetsDirectional.fromSTEB(8, 5, 8, 5),
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.white.withOpacity(.14) : Colors.black.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(reply, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: widget.isMe ? Colors.white70 : Colors.black54)),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: Text(text, style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87), fontSize: 14))),
                const SizedBox(width: 6),
                status,
              ],
            ),
            _reactions(m, dark),
          ],
        ),
      ),
      dark,
    );
  }

  Widget _statusWidget(Map<String, dynamic> m) {
    if (!widget.isMe) return const SizedBox.shrink();
    if (m['isSending'] == true) return const Icon(Icons.schedule, size: 14, color: Colors.white70);
    if (m['isRead'] == true) return const Icon(Icons.done_all, size: 15, color: Colors.lightBlueAccent);
    if (m['isDelivered'] == true) return const Icon(Icons.done_all, size: 15, color: Colors.white70);
    return const Icon(Icons.check, size: 15, color: Colors.white70);
  }

  Widget _reactions(Map<String, dynamic> m, bool dark) {
    final raw = m['reactions'];
    if (raw is! Map || raw.isEmpty) return const SizedBox.shrink();
    final counts = <String, int>{};
    for (final value in raw.values) {
      final emoji = value.toString();
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 3, children: counts.entries.map((e) => Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: dark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(10)), child: Text('${e.key} ${e.value}', style: const TextStyle(fontSize: 10)))).toList()),
    );
  }

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
    return GestureDetector(onTap: () => showDialog(context: context, builder: (_) => _VideoViewer(url: url)), onLongPress: () => _showMessageOptions(widget.message), child: Container(width: 230, height: 160, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('▶', style: TextStyle(color: Colors.white, fontSize: 46)))));
  }

  Widget _buildFile(Map<String, dynamic> m, bool dark) {
    final url = m['fileUrl']?.toString() ?? '';
    final name = (m['fileName']?.toString().trim().isNotEmpty == true) ? m['fileName'].toString() : 'ملف';
    return _shell(InkWell(onTap: () async { final uri = Uri.tryParse(url); if (uri != null && await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); } }, child: Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('📎', style: TextStyle(fontSize: 25)), const SizedBox(width: 10), Flexible(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87), fontWeight: FontWeight.w600)))]))), dark);
  }

  Widget _buildLocation(Map<String, dynamic> m, bool dark) {
    final text = m['locationAddress']?.toString().trim().isNotEmpty == true ? m['locationAddress'].toString() : (m['text']?.toString() ?? 'الموقع');
    return _shell(InkWell(onTap: () async { final uri = Uri.tryParse(m['locationUrl']?.toString() ?? ''); if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('📍', style: TextStyle(fontSize: 22)), const SizedBox(width: 8), Flexible(child: Text(text, style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87))))]))), dark);
  }

  Widget _buildSystem(Map<String, dynamic> m) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)), child: Text(m['text']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.black54))));

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Wrap(children: [
        if (widget.onReaction != null)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['👍', '❤️', '😂', '😮', '🙏'].map((emoji) => IconButton(onPressed: () { Navigator.pop(context); widget.onReaction!.call(emoji); }, icon: Text(emoji, style: const TextStyle(fontSize: 24))).toList()))),
        if (widget.onReply != null) ListTile(leading: const Icon(Icons.reply), title: const Text('رد'), onTap: () { Navigator.pop(context); widget.onReply!.call(); }),
        if (widget.onDelete != null) ListTile(leading: const Icon(Icons.delete_outline), title: const Text('حذف'), onTap: () { Navigator.pop(context); widget.onDelete!.call(); }),
      ])),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;
  const _VideoViewer({required this.url});
  @override State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late final VideoPlayerController _controller;
  @override void initState() { super.initState(); _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) { if (mounted) setState(() {}); }); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Dialog(backgroundColor: Colors.black, child: SizedBox(height: 240, child: Center(child: CircularProgressIndicator())));
    return Dialog(backgroundColor: Colors.black, insetPadding: const EdgeInsets.all(12), child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: Stack(alignment: Alignment.center, children: [VideoPlayer(_controller), IconButton(icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 48), onPressed: () { setState(() { _controller.value.isPlaying ? _controller.pause() : _controller.play(); }); })])));
  }
}
