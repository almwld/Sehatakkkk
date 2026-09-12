import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sehatak/core/constants/app_colors.dart';

class AdvancedAudioPlayer extends StatefulWidget {
  const AdvancedAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.isMe,
    this.isLocal = false,
    this.title,
  });

  final String audioUrl;
  final bool isMe;
  final bool isLocal;
  final String? title;

  @override
  State<AdvancedAudioPlayer> createState() => _AdvancedAudioPlayerState();
}

class _AdvancedAudioPlayerState extends State<AdvancedAudioPlayer> {
  late final AudioPlayer _player;
  final List<double> _speeds = const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double _speed = 1.0;
  double _volume = 1.0;
  bool _loading = true;
  bool _error = false;
  bool _loop = false;

  Color get _accent => widget.isMe ? Colors.white : AppColors.primary;
  Color get _muted => widget.isMe ? Colors.white70 : Colors.black54;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final value = widget.audioUrl.trim();
      if (value.isEmpty) throw StateError('empty audio url');
      if (widget.isLocal || value.startsWith('file://')) {
        final path = value.startsWith('file://') ? Uri.parse(value).toFilePath() : value;
        await _player.setFilePath(path);
      } else {
        await _player.setUrl(value);
      }
      await _player.setVolume(_volume);
      await _player.setSpeed(_speed);
      await _player.setLoopMode(LoopMode.off);
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('AdvancedAudioPlayer prepare error: $e');
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _seekBy(int seconds) async {
    final current = _player.position;
    final duration = _player.duration ?? Duration.zero;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    await _player.seek(target);
  }

  Future<void> _showSpeedPicker() async {
    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: _speeds.map((speed) => ListTile(
            leading: Icon(speed == _speed ? Icons.check_circle : Icons.speed),
            title: Text('${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}x'),
            selected: speed == _speed,
            onTap: () => Navigator.pop(context, speed),
          )).toList(),
        ),
      ),
    );
    if (selected == null) return;
    await _player.setSpeed(selected);
    if (mounted) setState(() => _speed = selected);
  }

  Future<void> _showVolumePicker() async {
    var value = _volume;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(children: [
              const Icon(Icons.volume_down),
              Expanded(child: Slider(value: value, min: 0, max: 1, onChanged: (v) { setSheetState(() => value = v); _player.setVolume(v); })),
              const Icon(Icons.volume_up),
            ]),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _volume = value);
  }

  Future<void> _download() async {
    final uri = Uri.tryParse(widget.audioUrl);
    if (uri == null || !uri.hasScheme) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _format(Duration value) {
    final total = value.inSeconds;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, color: _accent),
          const SizedBox(width: 8),
          Flexible(child: Text('تعذر تشغيل التسجيل', style: TextStyle(color: _accent))),
        ]),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 330),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.title != null) Row(children: [Icon(Icons.audiotrack, size: 17, color: _accent), const SizedBox(width: 6), Expanded(child: Text(widget.title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12)))]),
        if (widget.title != null) const SizedBox(height: 5),
        StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                final max = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
                final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
                return Column(children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(activeTrackColor: _accent, inactiveTrackColor: _accent.withOpacity(.25), thumbColor: _accent, overlayColor: _accent.withOpacity(.12), trackHeight: 3),
                    child: Slider(value: value, min: 0, max: max, onChanged: _loading ? null : (v) => _player.seek(Duration(milliseconds: v.round()))),
                  ),
                  Row(children: [Text(_format(position), style: TextStyle(color: _muted, fontSize: 10)), const Spacer(), Text(_format(duration), style: TextStyle(color: _muted, fontSize: 10))]),
                ]);
              },
            );
          },
        ),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(tooltip: 'إرجاع 10 ثوان', onPressed: _loading ? null : () => _seekBy(-10), icon: Icon(Icons.replay_10, color: _accent)),
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;
              final busy = _loading || state?.processingState == ProcessingState.loading || state?.processingState == ProcessingState.buffering;
              return Container(width: 48, height: 48, decoration: BoxDecoration(color: _accent.withOpacity(.16), shape: BoxShape.circle), child: IconButton(onPressed: busy ? null : () => playing ? _player.pause() : _player.play(), icon: busy ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _accent)) : Icon(playing ? Icons.pause : Icons.play_arrow, color: _accent, size: 28)));
            },
          ),
          IconButton(tooltip: 'تقديم 10 ثوان', onPressed: _loading ? null : () => _seekBy(10), icon: Icon(Icons.forward_10, color: _accent)),
          IconButton(tooltip: 'سرعة التشغيل', onPressed: _loading ? null : _showSpeedPicker, icon: Icon(Icons.speed, color: _accent)),
          IconButton(tooltip: 'مستوى الصوت', onPressed: _loading ? null : _showVolumePicker, icon: Icon(_volume == 0 ? Icons.volume_off : Icons.volume_up, color: _accent)),
        ]),
        Row(children: [
          TextButton.icon(onPressed: _loading ? null : () async { final next = !_loop; await _player.setLoopMode(next ? LoopMode.one : LoopMode.off); if (mounted) setState(() => _loop = next); }, icon: Icon(_loop ? Icons.repeat_one : Icons.repeat, size: 17, color: _loop ? _accent : _muted), label: Text(_loop ? 'تكرار' : 'حلقة', style: TextStyle(fontSize: 10, color: _loop ? _accent : _muted))),
          const Spacer(),
          TextButton.icon(onPressed: widget.isLocal ? null : _download, icon: Icon(Icons.download_outlined, size: 17, color: _accent), label: Text('تحميل', style: TextStyle(fontSize: 10, color: _accent))),
        ]),
      ]),
    );
  }
}
