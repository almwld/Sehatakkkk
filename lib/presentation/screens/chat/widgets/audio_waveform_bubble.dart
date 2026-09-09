import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:sehatak/core/constants/app_colors.dart';

class AudioWaveformBubble extends StatefulWidget {
  const AudioWaveformBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
    this.isLocal = false,
  });

  final String audioUrl;
  final bool isMe;
  final bool isLocal;

  @override
  State<AudioWaveformBubble> createState() => _AudioWaveformBubbleState();
}

class _AudioWaveformBubbleState extends State<AudioWaveformBubble> {
  late final PlayerController _controller;
  bool _ready = false;
  bool _playing = false;
  double _rate = 1.0;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _controller = PlayerController();
    _prepare();
    _controller.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _controller.onCompletion.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  Future<void> _prepare() async {
    try {
      String path = widget.audioUrl;
      if (!widget.isLocal && !path.startsWith('file://')) {
        final file = await DefaultCacheManager().getSingleFile(path);
        path = file.path;
      } else if (path.startsWith('file://')) {
        path = Uri.parse(path).toFilePath();
      }
      if (!File(path).existsSync()) return;
      _localPath = path;
      await _controller.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 90,
      );
      await _controller.setFinishMode(finishMode: FinishMode.stop);
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('Audio waveform prepare error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_ready) return;
    if (_playing) {
      await _controller.pausePlayer();
    } else {
      await _controller.startPlayer();
    }
  }

  Future<void> _changeRate() async {
    final next = _rate == 1.0 ? 1.5 : (_rate == 1.5 ? 2.0 : 1.0);
    await _controller.setRate(next);
    if (mounted) setState(() => _rate = next);
  }

  @override
  Widget build(BuildContext context) {
    final wave = widget.isMe ? Colors.white54 : Colors.teal.shade200;
    final active = widget.isMe ? Colors.white : AppColors.primary;
    final icon = widget.isMe ? Colors.white : AppColors.primary;

    return Container(
      constraints: const BoxConstraints(minWidth: 230, maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _ready ? _toggle : null,
            icon: Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: icon,
              size: 34,
            ),
          ),
          Expanded(
            child: _ready
                ? AudioFileWaveforms(
                    size: const Size(145, 42),
                    playerController: _controller,
                    waveformType: WaveformType.fitWidth,
                    enableSeekGesture: true,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: wave,
                      liveWaveColor: active,
                      spacing: 3,
                      waveThickness: 2,
                      showSeekLine: true,
                      seekLineColor: active,
                    ),
                  )
                : const SizedBox(
                    height: 42,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
          ),
          TextButton(
            onPressed: _ready ? _changeRate : null,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '${_rate.toStringAsFixed(1)}x',
              style: TextStyle(
                color: icon,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
