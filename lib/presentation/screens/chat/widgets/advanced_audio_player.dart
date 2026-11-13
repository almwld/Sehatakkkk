import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Memo-style compact voice note player.
/// The complete bubble is 68px high with a 40px play control, a 28px waveform,
/// a thin progress track and a compact duration/speed footer.
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
  static const _speeds = <double>[1.0, 1.5, 2.0];
  double _speed = 1.0;
  bool _loading = true;
  bool _error = false;

  Color get _accent => widget.isMe
      ? Colors.white
      : (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF53BDB0)
          : const Color(0xFF0D8274));
  Color get _muted => _accent.withOpacity(.28);
  Color get _playFill => widget.isMe ? Colors.white : _accent;
  Color get _playIcon => widget.isMe ? const Color(0xFF0D8274) : Colors.white;

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
        final path = value.startsWith('file://')
            ? Uri.parse(value).toFilePath()
            : value;
        await _player.setFilePath(path);
      } else {
        await _player.setUrl(value);
      }
      await _player.setSpeed(_speed);
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      debugPrint('AdvancedAudioPlayer prepare error: $error');
      if (mounted) setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_loading || _error) return;
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      await _player.play();
    } else if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _cycleSpeed() async {
    final index = _speeds.indexOf(_speed);
    final next = _speeds[(index + 1) % _speeds.length];
    await _player.setSpeed(next);
    if (mounted) setState(() => _speed = next);
  }

  String _format(Duration value) {
    final total = value.inSeconds;
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return SizedBox(
        height: 68,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: _accent, size: 17),
              const SizedBox(width: 6),
              Text('تعذر تشغيل التسجيل',
                  style: TextStyle(color: _accent, fontSize: 11)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final busy = _loading ||
                    state?.processingState == ProcessingState.loading ||
                    state?.processingState == ProcessingState.buffering;
                final playing = state?.playing == true;
                return Material(
                  color: _playFill,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: busy ? null : _togglePlay,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: busy
                            ? SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _playIcon,
                                ),
                              )
                            : Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: _playIcon,
                                size: 25,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final maxMs = duration.inMilliseconds;
                      final progress = maxMs > 0
                          ? (position.inMilliseconds / maxMs).clamp(0.0, 1.0)
                          : 0.0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 28,
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: _loading || maxMs <= 0
                                    ? null
                                    : (details) => _seek(
                                          details.localPosition.dx,
                                          constraints.maxWidth,
                                          duration,
                                        ),
                                onHorizontalDragUpdate:
                                    _loading || maxMs <= 0
                                        ? null
                                        : (details) => _seek(
                                              details.localPosition.dx,
                                              constraints.maxWidth,
                                              duration,
                                            ),
                                child: CustomPaint(
                                  painter: _MemoVoiceWaveformPainter(
                                    progress: progress,
                                    active: _accent,
                                    inactive: _muted,
                                    seed: widget.audioUrl.hashCode,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                _format(position),
                                style: TextStyle(
                                  color: _accent.withOpacity(.88),
                                  fontSize: 9,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: _loading ? null : _cycleSpeed,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  child: Text(
                                    '${_speed.toStringAsFixed(_speed == 1 ? 0 : 1)}×',
                                    style: TextStyle(
                                      color: _accent.withOpacity(.9),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _format(duration),
                                style: TextStyle(
                                  color: _accent.withOpacity(.88),
                                  fontSize: 9,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _seek(double dx, double width, Duration duration) {
    if (width <= 0) return;
    final fraction = (dx / width).clamp(0.0, 1.0);
    _player.seek(Duration(
      milliseconds: (duration.inMilliseconds * fraction).round(),
    ));
  }
}

class _MemoVoiceWaveformPainter extends CustomPainter {
  const _MemoVoiceWaveformPainter({
    required this.progress,
    required this.active,
    required this.inactive,
    required this.seed,
  });

  final double progress;
  final Color active;
  final Color inactive;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    const bars =  fortyEight;
    final step = size.width / bars;
    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < bars; i++) {
      final mix = ((seed.abs() + i * 53) % 31) / 31.0;
      final height = size.height * (.18 + mix * .72);
      final x = (i + .5) * step;
      paint.color = i / bars <= progress ? active : inactive;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
    // Memo's slim progress indicator sits under the waveform.
    final trackY = size.height - 1;
    paint
      ..strokeWidth = 2.6
      ..color = inactive;
    canvas.drawLine(Offset(0, trackY), Offset(size.width, trackY), paint);
    paint.color = active;
    canvas.drawLine(
      Offset(0, trackY),
      Offset(size.width * progress.clamp(0.0, 1.0), trackY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MemoVoiceWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.active != active ||
      oldDelegate.inactive != inactive ||
      oldDelegate.seed != seed;
}

const int fortyEight = 48;
