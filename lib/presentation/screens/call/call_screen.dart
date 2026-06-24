import 'package:flutter/material.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  final LiveKitService _liveKit = LiveKitService();
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCall();
  }

  @override
  void dispose() {
    _liveKit.endCall();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startCall() async {
    try {
      // ⚠️ يجب استبدال url و token من الخادم الخاص بك
      const url = 'wss://your-livekit-server.com';
      const token = 'your-token-here';
      
      await _liveKit.startCall(
        url: url,
        token: token,
        callerName: widget.doctorName,
        isVideo: widget.isVideo,
      );
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل بدء المكالمة: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📹 فيديو الطرف الآخر
          Container(
            color: Colors.black87,
            child: const Center(
              child: Text(
                'جاري الاتصال...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          // 🖼️ فيديو المستخدم (مصغر)
          if (widget.isVideo)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
            ),
          // 📞 واجهة التحكم
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // ⏱️ مدة المكالمة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // 🎛️ أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 🎤 كتم الصوت
                    _callButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? AppColors.error : Colors.white,
                      onTap: () => setState(() {
                        _isMuted = !_isMuted;
                        if (_isMuted) {
                          _liveKit.enableMicrophone();
                        }
                      }),
                    ),
                    // 📹 كتم الكاميرا
                    if (widget.isVideo)
                      _callButton(
                        icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                        color: _isCameraOn ? Colors.white : AppColors.error,
                        onTap: () => setState(() {
                          _isCameraOn = !_isCameraOn;
                          if (_isCameraOn) {
                            _liveKit.enableCamera();
                          }
                        }),
                      ),
                    // 📞 إنهاء المكالمة
                    _callButton(
                      icon: Icons.call_end,
                      color: AppColors.error,
                      size: 60,
                      onTap: () => Navigator.pop(context),
                    ),
                    // 🔊 مكبر الصوت
                    _callButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: _isSpeakerOn ? AppColors.info : Colors.white,
                      onTap: () => setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      }),
                    ),
                    // 📷 تبديل الكاميرا
                    if (widget.isVideo)
                      _callButton(
                        icon: Icons.switch_camera,
                        color: Colors.white,
                        onTap: () {
                          // تبديل الكاميرا الأمامية/الخلفية
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          // 🏷️ اسم الطبيب
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'جاري الاتصال...',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
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
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
