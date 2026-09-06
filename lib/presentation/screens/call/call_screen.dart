// ============================================================
// 📞 شاشة المكالمات - النسخة النهائية
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;
  final String? callId;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
    this.callId,
    this.isOutgoing = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  final CallService _callService = CallService();
  final Connectivity _connectivity = Connectivity();

  Timer? _callTimer;
  bool _callLifecycleEnded = false;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isOnHold = false;
  int _callDuration = 0;
  bool _isConnecting = true;
  bool _isConnected = false;
  String _errorMessage = '';
  bool _hasMicrophonePermission = false;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkConnectivity();
    _checkPermissions();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _callService.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        _isConnecting = false;
        _errorMessage = '⚠️ لا يوجد اتصال بالإنترنت';
      });
      _showNoInternetDialog();
    } else {
      _isConnected = true;
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ لا يوجد إنترنت'),
        content: const Text('يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivity();
              _checkPermissions();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPermissions() async {
    // ✅ طلب إذن الميكروفون
    final micStatus = await Permission.microphone.request();
    setState(() => _hasMicrophonePermission = micStatus.isGranted);

    if (!_hasMicrophonePermission) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'يرجى منح إذن الميكروفون';
      });
      ToastService.showError('❌ يرجى منح إذن الميكروفون');
      return;
    }

    // ✅ طلب إذن الكاميرا (للمكالمات الفيديو)
    if (widget.isVideo) {
      final cameraStatus = await Permission.camera.request();
      setState(() => _hasCameraPermission = cameraStatus.isGranted);

      if (!_hasCameraPermission) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'يرجى منح إذن الكاميرا';
        });
        ToastService.showError('❌ يرجى منح إذن الكاميرا');
        return;
      }
    }

    _startCall();
  }

  void _startCall() async {
    try {
      if (!_isConnected) {
        setState(() {
          _isConnecting = false;
          _errorMessage = '⚠️ لا يوجد اتصال بالإنترنت';
        });
        return;
      }

      // ✅ بدء المكالمة
      if (widget.isOutgoing) {
        final call = await _callService.initiateCall(
          receiverId: widget.doctorId,
          receiverName: widget.doctorName,
          type: widget.isVideo ? CallType.video : CallType.audio,
          chatId: widget.chatId,
        );
        if (call == null) {
          throw Exception('فشل بدء المكالمة');
        }
      }

      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = true;
        });
        _startTimer();
        ToastService.showSuccess('📞 جاري الاتصال...');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'فشل الاتصال: $e';
        });
        ToastService.showError('❌ ${_errorMessage}');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  void _startTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _callTimer?.cancel();
        return;
      }
      setState(() => _callDuration++);
    });
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    ToastService.showInfo(_isMuted ? '🔇 تم كتم الصوت' : '🎤 تم إلغاء كتم الصوت');
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    ToastService.showInfo(_isSpeakerOn ? '🔊 تم تفعيل مكبر الصوت' : '🔇 تم إلغاء مكبر الصوت');
  }

  void _toggleHold() {
    setState(() => _isOnHold = !_isOnHold);
    ToastService.showInfo(_isOnHold ? '⏸️ تم وضع المكالمة في الانتظار' : '▶️ تم استئناف المكالمة');
  }

  void _endCall() async {
    if (_callLifecycleEnded) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _callLifecycleEnded = true;
    _callTimer?.cancel();

    try {
      final callId = widget.callId;
      if (callId != null && callId.trim().isNotEmpty) {
        if (_callDuration > 0) {
          await _callService.endCall(callId, durationSeconds: _callDuration);
        } else if (widget.isOutgoing) {
          await _callService.cancelCall(callId);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Call end error: $e');
    }

    ToastService.showInfo('📞 تم إنهاء المكالمة');
    if (mounted) Navigator.pop(context);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
            child: widget.isVideo && _hasCameraPermission
                ? const Center(
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white54,
                      size: 80,
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
                  backgroundImage: NetworkImage(ImageKit.doctor1),
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
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
                  _isConnecting ? 'جاري الاتصال...' : _formatDuration(_callDuration),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isConnected ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _isConnected ? 'متصل' : 'جاري الاتصال...',
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.orange,
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
                        onTap: _toggleMute,
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
                        onTap: _toggleSpeaker,
                        color: _isSpeakerOn ? AppColors.primary : Colors.grey[700]!,
                      ),
                      // ✅ تعليق المكالمة
                      _buildControlButton(
                        icon: _isOnHold ? Icons.play_arrow : Icons.pause,
                        label: _isOnHold ? 'استئناف' : 'انتظار',
                        onTap: _toggleHold,
                        color: _isOnHold ? Colors.orange : Colors.grey[700]!,
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

          // ✅ حالة الخطأ
          if (_errorMessage.isNotEmpty)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
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
}
