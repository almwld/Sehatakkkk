// ============================================================
// 📞 شاشة المكالمات
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'dart:async';

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
    this.isVideo = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true;
  int _callDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    ToastService.showInfo('📞 جاري الاتصال بـ ${widget.doctorName}...');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
  }

  String _formatDuration() {
    final minutes = (_callDuration / 60).floor();
    final seconds = _callDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ خلفية المكالمة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                ],
              ),
            ),
            child: widget.isVideo
                ? Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                          size: 80,
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.phone,
                      color: Colors.white54,
                      size: 80,
                    ),
                  ),
          ),
          // ✅ معلومات المكالمة
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    widget.doctorName.isNotEmpty ? widget.doctorName[0] : 'ط',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'متصل',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ✅ أزرار التحكم
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ كتم الصوت
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'غير مكتوم' : 'كتم',
                        onTap: () => setState(() => _isMuted = !_isMuted),
                        color: _isMuted ? Colors.red : Colors.grey[700]!,
                      ),
                      // ✅ إنهاء المكالمة
                      _buildControlButton(
                        icon: Icons.call_end,
                        label: 'إنهاء',
                        onTap: _endCall,
                        color: Colors.red,
                        isEnd: true,
                      ),
                      // ✅ مكبر الصوت
                      _buildControlButton(
                        icon: _isSpeakerOn ? Icons.speaker : Icons.speaker_off,
                        label: _isSpeakerOn ? 'مكبر' : 'سماعة',
                        onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                        color: _isSpeakerOn ? AppColors.primary : Colors.grey[700]!,
                      ),
                      // ✅ كاميرا (فيديو فقط)
                      if (widget.isVideo)
                        _buildControlButton(
                          icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          label: _isCameraOn ? 'كاميرا' : 'إيقاف',
                          onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                          color: _isCameraOn ? AppColors.primary : Colors.grey[700]!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ✅ زر الرجوع
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: _endCall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isEnd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isEnd ? 28 : 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _endCall() {
    _timer?.cancel();
    ToastService.showInfo('📞 تم إنهاء المكالمة');
    Navigator.pop(context);
  }
}
