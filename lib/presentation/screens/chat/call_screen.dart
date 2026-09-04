import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/call_service.dart';
import '../../../core/services/livekit_service.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String chatId;
  final bool isVideo;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.isVideo,
    required this.isOutgoing,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  final LiveKitService _liveKitService = LiveKitService();
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;
  String _duration = '00:00';

  @override
  void initState() {
    super.initState();
    _startTimer();
    _connectToLiveKit();
  }

  void _startTimer() {
    // ✅ بدء Timer لحساب مدة المكالمة
    int seconds = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
        final mins = (seconds / 60).floor();
        final secs = seconds % 60;
        _duration = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      });
    });
  }

  void _connectToLiveKit() async {
    try {
      final token = await _liveKitService.getToken(
        roomName: 'call_${widget.chatId}',
        participantIdentity: FirebaseAuth.instance.currentUser?.uid ?? '',
        participantName: FirebaseAuth.instance.currentUser?.displayName ?? 'مستخدم',
      );
      if (token != null) {
        await _liveKitService.connect(token);
      }
    } catch (e) {
      print('❌ LiveKit connection error: $e');
    }
  }

  @override
  void dispose() {
    _callService.endCall(widget.callId);
    _liveKitService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ شريط الحالة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    _duration,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // ✅ صورة المتصل (في حال عدم وجود فيديو)
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'المستخدم',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // ✅ أزرار التحكم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 🎤 كتم الميكروفون
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'إلغاء الكتم' : 'كتم',
                    onTap: () {
                      setState(() => _isMuted = !_isMuted);
                      _liveKitService.toggleMicrophone();
                    },
                  ),
                  // 🔊 مكبر الصوت
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: _isSpeakerOn ? 'سماعة' : 'مكبر صوت',
                    onTap: () {
                      setState(() => _isSpeakerOn = !_isSpeakerOn);
                    },
                  ),
                  // 📹 كاميرا (فيديو فقط)
                  if (widget.isVideo)
                    _buildControlButton(
                      icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      label: _isCameraOff ? 'تشغيل' : 'إيقاف',
                      onTap: () {
                        setState(() => _isCameraOff = !_isCameraOff);
                        _liveKitService.toggleCamera();
                      },
                    ),
                  // ❌ إنهاء المكالمة
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'إنهاء',
                    color: AppColors.error,
                    onTap: () {
                      _callService.endCall(widget.callId);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color ?? Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
