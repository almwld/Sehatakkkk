import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CallScreen extends StatefulWidget {
  final String roomName;
  final String callerName;
  final String? callerPhoto;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.roomName,
    required this.callerName,
    this.callerPhoto,
    this.isVideo = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final LiveKitService _liveKit = LiveKitService();
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = true;
  int _callDuration = 0;
  bool _isConnecting = true;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // ✅ طلب إذن الكاميرا
    if (widget.isVideo) {
      final cameraStatus = await Permission.camera.request();
      setState(() {
        _hasCameraPermission = cameraStatus.isGranted;
      });
      if (!_hasCameraPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى منح إذن الكاميرا للمكالمات المرئية'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    // ✅ طلب إذن الميكروفون
    await Permission.microphone.request();
    
    _startCall();
  }

  void _startCall() async {
    try {
      await _liveKit.startCall(
        roomName: widget.roomName,
        callerName: widget.callerName,
        isVideo: widget.isVideo && _hasCameraPermission,
      );
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل الاتصال: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _callDuration++);
        if (_callDuration < 60) {
          _startTimer();
        }
      }
    });
  }

  void _toggleCamera() async {
    final newState = await _liveKit.toggleCamera();
    setState(() => _isCameraOn = newState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ خلفية المكالمة
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white54, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    widget.callerName,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConnecting ? 'جاري الاتصال...' : _formatDuration(_callDuration),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          // ✅ واجهة التحكم
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 🎤 كتم الصوت
                    _callButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? AppColors.error : Colors.white,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    // 📹 كتم الكاميرا
                    if (widget.isVideo)
                      _callButton(
                        icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                        color: _isCameraOn ? Colors.white : AppColors.error,
                        onTap: _toggleCamera,
                      ),
                    // 📞 إنهاء المكالمة
                    _callButton(
                      icon: Icons.call_end,
                      color: AppColors.error,
                      size: 60,
                      onTap: () {
                        _liveKit.endCall();
                        Navigator.pop(context);
                      },
                    ),
                    // 🔊 مكبر الصوت
                    _callButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: _isSpeakerOn ? AppColors.info : Colors.white,
                      onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    ),
                    if (widget.isVideo)
                      _callButton(
                        icon: Icons.switch_camera,
                        color: Colors.white,
                        onTap: () {},
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required Color color,
    double size = 50,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.4),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _liveKit.endCall();
    super.dispose();
  }
}
