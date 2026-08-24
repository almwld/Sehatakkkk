import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class VoiceRecorder extends StatefulWidget {
  final String chatId;
  final Function(String) onRecordingComplete;

  const VoiceRecorder({
    super.key,
    required this.chatId,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isRecording = false;
  bool _isUploading = false;
  bool _isLocked = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _recordingPath;
  double _uploadProgress = 0.0;

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
    if (path != null && _recordingPath != null) {
      await _uploadAudio();
    }
  }

  Future<void> _uploadAudio() async {
    if (_recordingPath == null) return;

    setState(() => _isUploading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول');
        return;
      }

      final file = File(_recordingPath!);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = _storage
          .ref()
          .child('chats/${widget.chatId}/audio/$fileName');

      // ✅ رفع الملف مع مراقبة التقدم
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() => _uploadProgress = progress);
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // ✅ حفظ الرسالة الصوتية في Firestore
      await _saveVoiceMessage(downloadUrl);

      ToastService.showSuccess('✅ تم إرسال الرسالة الصوتية');
      widget.onRecordingComplete(downloadUrl);

    } catch (e) {
      ToastService.showError('❌ فشل رفع الصوت: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveVoiceMessage(String audioUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messageData = {
      'text': '🎤 رسالة صوتية',
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'audio',
      'audioUrl': audioUrl,
      'duration': _duration.inSeconds,
      'isRead': false,
    };

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': '🎤 رسالة صوتية',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
      child: _isUploading
          ? _buildUploadingUI(isDark)
          : _buildRecordingUI(isDark),
    );
  }

  Widget _buildUploadingUI(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_upload, size: 40, color: AppColors.primary),
        const SizedBox(height: 12),
        Text(
          'جاري رفع الصوت...',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: _uploadProgress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(_uploadProgress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingUI(bool isDark) {
    return Column(
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
            // ✅ زر إرسال (غير مفعل أثناء التسجيل)
            GestureDetector(
              onTap: _isRecording ? null : _stopRecording,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.grey[800] : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: _isRecording ? Colors.grey[600] : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
