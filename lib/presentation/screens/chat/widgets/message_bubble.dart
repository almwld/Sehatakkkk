import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/chat/widgets/audio_waveform_bubble.dart';

class MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final Function(String)? onReaction;
  final Function(String)? onCallAgain;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
    this.onReaction,
    this.onCallAgain,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isLocal(String path) {
    return widget.message['isLocal'] == true ||
        widget.message['isUploading'] == true ||
        path.startsWith('file://') ||
        (path.isNotEmpty && !path.startsWith('http') && File(path).existsSync());
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final type = (widget.message['type'] ?? 'text').toString();
    final error = widget.message['hasError'] == true;
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
                  bottom: 3,
                  child: LinearProgressIndicator(value: progress, minHeight: 2),
                ),
              if (error)
                PositionedDirectional(
                  start: -38,
                  bottom: 5,
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
      onLongPress: _options,
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
    final m = widget.message;
    switch (type) {
      case 'image':
        return _buildImage(m['imageUrl']?.toString() ?? m['fileUrl']?.toString() ?? m['text']?.toString() ?? '');
      case 'video':
        return _buildVideo(m['videoUrl']?.toString() ?? m['fileUrl']?.toString() ?? m['text']?.toString() ?? '');
      case 'audio':
        final url = m['audioUrl']?.toString() ?? m['fileUrl']?.toString() ?? m['text']?.toString() ?? '';
        return _shell(AudioWaveformBubble(audioUrl: url, isMe: widget.isMe, isLocal: _isLocal(url)), dark);
      case 'file':
        return _buildFile(m, dark);
      case 'call':
        return _buildCall(m, dark);
      case 'location':
        return _buildLocation(m, dark);
      case 'system':
        return _buildSystem(m);
      default:
        return _buildText(m, dark);
    }
  }

  Widget _buildText(Map<String, dynamic> m, bool dark) {
    return _shell(
      Padding(
        padding: const EdgeInsets.fromLTRB(13, 9, 10, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((m['replyPreview']?.toString().trim() ?? '').isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.white.withOpacity(.14) : Colors.black.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  m['replyPreview'].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: widget.isMe ? Colors.white70 : Colors.black54),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    m['text']?.toString() ?? '',
                    style: TextStyle(color: widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 6),
                _status(m),
              ],
            ),
            _reactions(m, dark),
          ],
        ),
      ),
      dark,
    );
  }

  Widget _status(Map<String, dynamic> m) {
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
      child: Wrap(
        spacing: 3,
        children: counts.entries.map((entry) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: dark ? Colors.white12 : Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${entry.key} ${entry.value}', style: const TextStyle(fontSize: 10)),
        )).toList(),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return const SizedBox(width: 230, height: 100, child: Center(child: Text('تعذر تحميل الصورة')));
    final local = _isLocal(path);
    final cleanPath = path.replaceFirst('file://', '');
    final image = local
        ? Image.file(File(cleanPath), fit: BoxFit.contain)
        : CachedNetworkImage(imageUrl: path, fit: BoxFit.contain);
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) => Dialog(backgroundColor: Colors.transparent, child: InteractiveViewer(child: image)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: local
            ? Image.file(File(cleanPath), width: 230, height: 230, fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: path,
                width: 230,
                height: 230,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(width: 230, height: 230, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                errorWidget: (_, __, ___) => const SizedBox(width: 230, height: 230, child: Center(child: Icon(Icons.broken_image))),
              ),
      ),
    );
  }

  Widget _buildVideo(String path) {
    if (path.isEmpty) return const SizedBox(width: 230, height: 100, child: Center(child: Text('تعذر تحميل الفيديو')));
    return GestureDetector(
      onTap: () => showDialog<void>(context: context, builder: (_) => _VideoViewer(url: path, isLocal: _isLocal(path))),
      child: Container(
        width: 230,
        height: 160,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
      ),
    );
  }

  Widget _buildFile(Map<String, dynamic> m, bool dark) {
    final url = m['fileUrl']?.toString() ?? m['text']?.toString() ?? '';
    final name = (m['fileName']?.toString().trim().isNotEmpty == true) ? m['fileName'].toString() : 'ملف';
    final tc = widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87);
    return _shell(
      InkWell(
        onTap: () async {
          if (url.isEmpty) return;
          final target = _isLocal(url) ? Uri.file(url.replaceFirst('file://', '')) : Uri.tryParse(url);
          if (target != null && await canLaunchUrl(target)) {
            await launchUrl(target, mode: LaunchMode.externalApplication);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file, color: tc, size: 30),
              const SizedBox(width: 10),
              Flexible(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: tc, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Icon(Icons.download_for_offline, color: tc),
            ],
          ),
        ),
      ),
      dark,
    );
  }

  Widget _buildCall(Map<String, dynamic> m, bool dark) {
    final meta = m['metadata'] is Map ? Map<String, dynamic>.from(m['metadata']) : <String, dynamic>{};
    final kind = (meta['callType'] ?? 'missed').toString();
    final video = meta['isVideo'] == true;
    final duration = (meta['duration'] ?? '').toString();
    final missed = kind == 'missed';
    final incoming = kind == 'incoming';
    final icon = missed ? Icons.call_missed : incoming ? Icons.call_received : Icons.call_made;
    final title = missed ? 'مكالمة ${video ? 'فيديو' : 'صوتية'} فائتة' : incoming ? 'مكالمة ${video ? 'فيديو' : 'صوتية'} واردة' : 'مكالمة ${video ? 'فيديو' : 'صوتية'} صادرة';
    final tc = widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87);
    final ic = missed ? Colors.redAccent : incoming ? Colors.green : Colors.blue;
    return _shell(
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(backgroundColor: ic.withOpacity(.18), child: Icon(icon, color: ic, size: 20)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: tc, fontWeight: FontWeight.bold, fontSize: 13)),
              if (duration.isNotEmpty) Text(duration, style: TextStyle(color: tc.withOpacity(.7), fontSize: 11)),
            ]),
            const SizedBox(width: 12),
            InkWell(onTap: () => widget.onCallAgain?.call(video ? 'video' : 'audio'), child: Icon(video ? Icons.videocam : Icons.call, color: tc, size: 20)),
          ],
        ),
      ),
      dark,
    );
  }

  Widget _buildLocation(Map<String, dynamic> m, bool dark) {
    final text = m['locationAddress']?.toString() ?? m['text']?.toString() ?? 'الموقع';
    final url = m['locationUrl']?.toString() ?? '';
    final tc = widget.isMe ? Colors.white : (dark ? Colors.white : Colors.black87);
    return _shell(
      InkWell(
        onTap: () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, color: Colors.redAccent), const SizedBox(width: 7), Flexible(child: Text(text, style: TextStyle(color: tc)))]),
        ),
      ),
      dark,
    );
  }

  Widget _buildSystem(Map<String, dynamic> m) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Center(child: Text(m['text']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.black54))),
  );

  void _options() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            if (widget.onReaction != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['👍', '❤️', '😂', '😮', '🙏'].map((emoji) => IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onReaction?.call(emoji);
                    },
                    icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                  )).toList(),
                ),
              ),
            if (widget.onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('رد'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReply?.call();
                },
              ),
            if (widget.onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('حذف'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String url;
  final bool isLocal;
  const _VideoViewer({required this.url, required this.isLocal});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    final path = widget.url.replaceFirst('file://', '');
    controller = widget.isLocal ? VideoPlayerController.file(File(path)) : VideoPlayerController.networkUrl(Uri.parse(path));
    controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Dialog(backgroundColor: Colors.black, child: SizedBox(height: 240, child: Center(child: CircularProgressIndicator())));
    }
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            IconButton(
              icon: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 52),
              onPressed: () => setState(() => controller.value.isPlaying ? controller.pause() : controller.play()),
            ),
          ],
        ),
      ),
    );
  }
}

class JustAudioMessagePlayer extends StatefulWidget {
  final String url;
  final bool local;
  const JustAudioMessagePlayer({super.key, required this.url, this.local = false});

  @override
  State<JustAudioMessagePlayer> createState() => _JustAudioMessagePlayerState();
}

class _JustAudioMessagePlayerState extends State<JustAudioMessagePlayer> {
  final player = AudioPlayer();
  bool ready = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        return IconButton(
          icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
          onPressed: () async {
            if (!ready) {
              if (widget.local) {
                await player.setFilePath(widget.url.replaceFirst('file://', ''));
              } else {
                await player.setUrl(widget.url);
              }
              ready = true;
            }
            if (playing) {
              await player.pause();
            } else {
              await player.play();
            }
          },
        );
      },
    );
  }
}
