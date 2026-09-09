// ============================================================
// 📞 شاشة المكالمات - النسخة المتكاملة
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/models/call_model.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;
  final String? doctorImage;
  final String? callId; // ✅ يمكن تمرير callId موجود

  const CallScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = false,
    this.doctorImage,
    this.callId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  // ============================================================
  // 🔥 Firebase & LiveKit Services
  // ============================================================

  final CallService _callService = CallService();
  final LiveKitService _liveKitService = LiveKitService();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 🎮 حالة المكالمة
  // ============================================================

  String? _callId;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true;
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isOnHold = false;
  int _callDuration = 0;
  Timer? _timer;
  Timer? _connectingTimer;
  String _status = 'جاري الاتصال...';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ============================================================
  // 🔄 دورة الحياة
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ✅ أنيميشن النبض
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✅ بدء المكالمة
    _startCall();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectingTimer?.cancel();
    _pulseController.dispose();

    // ✅ إنهاء المكالمة إذا كانت متصلة
    if (_isConnected && _callId != null) {
      _callService.endCall(_callId!, durationSeconds: _callDuration);
      _liveKitService.endCall();
    }

    super.dispose();
  }

  // ============================================================
  // 📞 بدء المكالمة
  // ============================================================

  Future<void> _startCall() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('يجب تسجيل الدخول');
      }

      // ✅ إنشاء المكالمة في Firestore
      if (widget.callId != null) {
        _callId = widget.callId;
      } else {
        _callId = await _callService.initiateCall(
          callerId: userId,
          receiverId: widget.doctorId,
          chatId: widget.chatId,
          type: widget.isVideo ? CallType.video : CallType.audio,
        );
      }

      if (_callId == null) {
        throw Exception('فشل إنشاء المكالمة');
      }

      // ✅ إرسال رسالة نظام في الدردشة
      await _chatService.sendSystemMessage(
        chatId: widget.chatId,
        text: '📞 بدأ مكالمة ${widget.isVideo ? 'فيديو' : 'صوتية'} مع ${widget.doctorName}',
        metadata: {
          'callId': _callId,
          'type': widget.isVideo ? 'video' : 'audio',
          'status': 'calling',
        },
      );

      // ✅ الاتصال بـ LiveKit
      await _liveKitService.connectRoom(
        roomName: widget.chatId,
        participantName: _auth.currentUser?.displayName ?? 'مستخدم',
      );

      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _status = 'متصل';
      });

      // ✅ بدء مؤقت المكالمة
      _startCallTimer();

      ToastService.showSuccess('✅ تم الاتصال بـ ${widget.doctorName}');

    } catch (e) {
      ToastService.showError('❌ فشل بدء المكالمة: $e');
      Navigator.pop(context);
    }
  }

  // ============================================================
  // ⏱️ مؤقت المكالمة
  // ============================================================

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isConnected && !_isOnHold) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  String _formatDuration() {
    final minutes = (_callDuration / 60).floor();
    final seconds = _callDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // 🛠️ دوال التحكم
  // ============================================================

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _liveKitService.toggleMicrophone();
    ToastService.showInfo(_isMuted ? '🔇 تم كتم الصوت' : '🎤 تم إلغاء كتم الصوت');
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _liveKitService.setSpeakerphone(_isSpeakerOn);
    ToastService.showInfo(_isSpeakerOn ? '🔊 تم تفعيل مكبر الصوت' : '🔇 تم إلغاء مكبر الصوت');
  }

  void _toggleCamera() {
    if (!widget.isVideo) return;
    setState(() => _isCameraOn = !_isCameraOn);
    _liveKitService.toggleCamera();
    ToastService.showInfo(_isCameraOn ? '📷 تم تشغيل الكاميرا' : '📷 تم إيقاف الكاميرا');
  }

  void _toggleHold() {
    setState(() => _isOnHold = !_isOnHold);
    ToastService.showInfo(_isOnHold ? '⏸️ تم تعليق المكالمة' : '▶️ تم استئناف المكالمة');
  }

  void _switchCamera() {
    if (!widget.isVideo) return;
    _liveKitService.switchCamera();
    ToastService.showInfo('📷 تم تبديل الكاميرا');
  }

  // ============================================================
  // 📞 إنهاء المكالمة
  // ============================================================

  Future<void> _endCall() async {
    _timer?.cancel();
    _connectingTimer?.cancel();
    _pulseController.stop();

    // ✅ تحديث حالة المكالمة
    if (_callId != null) {
      await _callService.endCall(_callId!, durationSeconds: _callDuration);
    }

    // ✅ إرسال رسالة نظام
    await _chatService.sendSystemMessage(
      chatId: widget.chatId,
      text: '📞 انتهت المكالمة (${_formatDuration()})',
      metadata: {
        'callId': _callId,
        'duration': _callDuration,
        'status': 'ended',
      },
    );

    // ✅ إنهاء LiveKit
    _liveKitService.endCall();

    ToastService.showInfo('📞 تم إنهاء المكالمة');
    Navigator.pop(context);
  }

  // ============================================================
  // 🏗️ واجهة المستخدم
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCallBackground(),
          _buildCallInfo(),
          _buildControlButtons(),
          _buildBackButton(),
          if (_isConnecting) _buildConnectingStatus(),
        ],
      ),
    );
  }

  Widget _buildCallBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.grey[800]!,
            Colors.grey[700]!,
          ],
        ),
      ),
      child: widget.isVideo && _isConnected
          ? _buildVideoView()
          : const Center(
              child: Icon(
                Icons.phone,
                color: Colors.white54,
                size: 80,
              ),
            ),
    );
  }

  Widget _buildVideoView() {
    return Stack(
      children: [
        // ✅ فيديو الطرف الآخر (ملء الشاشة)
        Container(
          color: Colors.grey[900],
          child: const Center(
            child: Text(
              'فيديو الطرف الآخر',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
        // ✅ فيديو المستخدم (نافذة صغيرة)
        Positioned(
          bottom: 120,
          right: 16,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white30),
            ),
            child: const Center(
              child: Text(
                'أنت',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAvatar(),
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
            if (_isConnected) ...[
              Text(
                _formatDuration(),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
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
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
            if (_isOnHold)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  '⏸️ معلق',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isConnecting ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isConnecting ? Colors.green : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isConnecting ? Colors.green.withOpacity(0.3) : Colors.transparent,
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: widget.doctorImage != null && widget.doctorImage!.isNotEmpty
                  ? NetworkImage(widget.doctorImage!)
                  : null,
              child: widget.doctorImage == null || widget.doctorImage!.isEmpty
                  ? Text(
                      widget.doctorName.isNotEmpty ? widget.doctorName[0] : 'ط',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectingStatus() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _status,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: _endCall,
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // ✅ الصف الأول
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'غير مكتوم' : 'كتم',
                  onTap: _toggleMute,
                  color: _isMuted ? Colors.red : Colors.grey[700]!,
                ),
                _buildControlButton(
                  icon: _isOnHold ? Icons.play_arrow : Icons.pause,
                  label: _isOnHold ? 'استئناف' : 'تعليق',
                  onTap: _toggleHold,
                  color: _isOnHold ? Colors.green : Colors.grey[700]!,
                ),
                _buildControlButton(
                  icon: _isSpeakerOn ? Icons.speaker : Icons.speaker_off,
                  label: _isSpeakerOn ? 'مكبر' : 'سماعة',
                  onTap: _toggleSpeaker,
                  color: _isSpeakerOn ? AppColors.primary : Colors.grey[700]!,
                ),
                if (widget.isVideo)
                  _buildControlButton(
                    icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                    label: _isCameraOn ? 'كاميرا' : 'إيقاف',
                    onTap: _toggleCamera,
                    color: _isCameraOn ? AppColors.primary : Colors.grey[700]!,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ الصف الثاني - أزرار إضافية
            if (widget.isVideo)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.switch_camera,
                    label: 'تبديل',
                    onTap: _switchCamera,
                    color: Colors.grey[700]!,
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // ✅ زر إنهاء المكالمة
            GestureDetector(
              onTap: _endCall,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35,
                ),
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
    required Color color,
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
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
