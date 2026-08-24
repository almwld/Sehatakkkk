import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VoiceRecorder extends StatefulWidget {
  final Function(String) onRecordingComplete;

  const VoiceRecorder({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isLocked = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _recordingPath;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ✅ مؤشر الصوت
  final List<double> _amplitudes = List.generate(30, (_) => 0.0);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
          ),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _duration = Duration.zero;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _duration += const Duration(seconds: 1));
          _updateAmplitudes();
        });
      }
    } catch (e) {
      ToastService.showError('❌ فشل بدء التسجيل: $e');
    }
  }

  void _updateAmplitudes() {
    // محاكاة مؤشر الصوت
    for (int i = 0; i < _amplitudes.length; i++) {
      _amplitudes[i] = (0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 100).clamp(0.0, 1.0);
    }
    setState(() {});
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      widget.onRecordingComplete(path);
    }
  }

  void _cancelRecording() {
    _timer?.cancel();
    setState(() => _isRecording = false);
    _recorder.stop();
  }

  void _toggleLock() {
    setState(() => _isLocked = !_isLocked);
    if (_isLocked) {
      ToastService.showInfo('🔒 تم قفل التسجيل');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111b21) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ مؤشر الصوت
          Container(
            height: 40,
            child: Row(
              children: List.generate(_amplitudes.length, (index) {
                final height = _amplitudes[index] * 30;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: height.clamp(2.0, 30.0),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? (index % 2 == 0 ? AppColors.primary : Colors.grey)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ الوقت
          Center(
            child: Text(
              _isRecording ? _formatDuration(_duration) : '00:00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ✅ زر الإلغاء
              GestureDetector(
                onTap: _cancelRecording,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              // ✅ زر القفل
              GestureDetector(
                onTap: _toggleLock,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isLocked ? AppColors.primary : Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isLocked ? Icons.lock : Icons.lock_open,
                    color: Colors.white,
                  ),
                ),
              ),
              // ✅ زر التسجيل الرئيسي
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: _pulseAnimation.value * 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              // ✅ زر إرسال
              GestureDetector(
                onTap: _isRecording ? _stopRecording : null,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.green : Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
