import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/call_service.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String chatId;
  final String callerId;
  final String callerName;
  final bool isVideo;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTimeout;
  final VoidCallback onCancel;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.callerId,
    required this.callerName,
    required this.isVideo,
    required this.onAccept,
    required this.onReject,
    required this.onTimeout,
    required this.onCancel,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallService _callService = CallService();
  Timer? _countdownTimer;
  Timer? _timeoutTimer;
  int _remainingSeconds = 30;
  bool _isAnswered = false;
  StreamSubscription<CallModel?>? _callSubscription;

  @override
  void initState() {
    super.initState();
    _startTimers();
    _listenToCallStatus();
  }

  void _startTimers() {
    // ✅ Countdown Timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds <= 0) {
          timer.cancel();
        }
      }
    });

    // ✅ Timeout Timer (30 ثانية)
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_isAnswered && mounted) {
        widget.onTimeout();
        Navigator.pop(context);
      }
    });
  }

  void _listenToCallStatus() {
    _callSubscription = _callService.streamCall(widget.callId).listen((call) {
      if (call == null) return;
      
      // ✅ إذا تغيرت حالة المكالمة إلى cancelled/missed/rejected/ended
      if (call.status == CallStatus.cancelled ||
          call.status == CallStatus.missed ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.ended) {
        if (mounted && !_isAnswered) {
          _cancelTimers();
          Navigator.pop(context);
        }
      }
    });
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _timeoutTimer?.cancel();
    _callSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.person,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة صوتية واردة',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'يرن... (${_remainingSeconds}s)',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.call_end,
                    color: AppColors.error,
                    label: 'رفض',
                    onTap: () {
                      setState(() => _isAnswered = true);
                      widget.onReject();
                      _cancelTimers();
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: widget.isVideo ? Icons.videocam : Icons.call,
                    color: AppColors.success,
                    label: 'رد',
                    onTap: () {
                      setState(() => _isAnswered = true);
                      widget.onAccept();
                      _cancelTimers();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallScreen(
                            callId: widget.callId,
                            chatId: widget.chatId,
                            isVideo: widget.isVideo,
                            isOutgoing: false,
                          ),
                        ),
                      );
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
