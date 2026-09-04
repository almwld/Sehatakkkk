import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Timer? _durationTimer;
  int _seconds = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToLiveKit();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _connectToLiveKit() async {
    try {
      await _liveKitService.connectRoom(
        roomName: widget.chatId,
        participantName: FirebaseAuth.instance.currentUser?.displayName ?? 'مستخدم',
      );
      if (mounted) {
        setState(() => _isConnected = true);
        _startDurationTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاتصال: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    if (_isConnected) {
      _callService.endCall(widget.callId, durationSeconds: _seconds);
      _liveKitService.endCall();
    }
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Spacer(),
                  Text(_formatDuration(_seconds), style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(radius: 60, backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, size: 60, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  Text('المستخدم', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_isConnected ? 'متصل' : 'جاري الاتصال...', style: TextStyle(color: _isConnected ? Colors.green : Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(icon: _isMuted ? Icons.mic_off : Icons.mic, label: _isMuted ? 'إلغاء الكتم' : 'كتم', onTap: () { setState(() => _isMuted = !_isMuted); _liveKitService.toggleMicrophone(); }),
                  _buildControlButton(icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down, label: _isSpeakerOn ? 'سماعة' : 'مكبر صوت', onTap: () { setState(() => _isSpeakerOn = !_isSpeakerOn); _liveKitService.setSpeakerphone(_isSpeakerOn); }),
                  if (widget.isVideo) _buildControlButton(icon: _isCameraOff ? Icons.videocam_off : Icons.videocam, label: _isCameraOff ? 'تشغيل' : 'إيقاف', onTap: () { setState(() => _isCameraOff = !_isCameraOff); _liveKitService.toggleCamera(); }),
                  _buildControlButton(icon: Icons.call_end, label: 'إنهاء', color: AppColors.error, onTap: () { _callService.endCall(widget.callId, durationSeconds: _seconds); _liveKitService.endCall(); Navigator.pop(context); }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(width: 48, height: 48, decoration: BoxDecoration(color: color ?? Colors.white24, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 24)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
