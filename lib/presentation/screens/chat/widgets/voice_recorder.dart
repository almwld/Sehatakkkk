import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VoiceRecorder extends StatefulWidget {
  final Function(String) onRecordComplete;

  const VoiceRecorder({super.key, required this.onRecordComplete});

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  double _amplitude = 0.0;
  Duration _duration = Duration.zero;
  String _recordingPath = '';

  // ✅ محاكاة التسجيل (في الواقع سيتم استخدام record package)
  void _startRecording() {
    setState(() {
      _isRecording = true;
      _duration = Duration.zero;
    });

    // محاكاة التسجيل
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingPath = 'assets/audio/recording.mp3';
          widget.onRecordComplete(_recordingPath);
        });
      }
    });
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
  }

  void _playRecording() {
    setState(() => _isPlaying = true);
    // محاكاة التشغيل
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // ✅ زر التسجيل
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ✅ مؤشر الصوت
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isRecording)
                  Row(
                    children: [
                      ...List.generate(8, (index) {
                        final height = 10 + (index % 5) * 4;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 4,
                          height: _amplitude > 0 ? height : 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        'تسجيل...',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else if (_recordingPath.isNotEmpty)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _playRecording,
                        child: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Container(
                            width: _isPlaying ? 60 : 0,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _duration.inSeconds.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'اضغط للتسجيل',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),

          // ✅ زر إلغاء
          if (_recordingPath.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {
                setState(() {
                  _recordingPath = '';
                  _duration = Duration.zero;
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
