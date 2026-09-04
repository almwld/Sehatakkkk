import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/call_model.dart';
import '../../../core/services/call_service.dart';
import '../call/call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String chatId;
  final String callerId;
  final String callerName;
  final bool isVideo;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.chatId,
    required this.callerId,
    required this.callerName,
    required this.isVideo,
  });

  @override
  State<IncomingCallScreen> createState() =>
      _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallService _callService = CallService();

  Timer? _countdownTimer;
  Timer? _timeoutTimer;

  StreamSubscription<CallModel?>? _callSubscription;

  int _remainingSeconds = 30;

  bool _isProcessing = false;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();

    _listenToCallStatus();
    _startTimers();
  }

  void _startTimers() {
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });

    _timeoutTimer = Timer(
      const Duration(seconds: 30),
      () async {
        if (_isAnswered || _isProcessing || !mounted) {
          return;
        }

        _isProcessing = true;

        try {
          await _callService.missCall(widget.callId);
        } catch (e) {
          debugPrint('⚠️ Failed to mark call as missed: $e');
        }

        if (!mounted) return;

        _cancelTimers();
        Navigator.of(context).pop();
      },
    );
  }

  void _listenToCallStatus() {
    _callSubscription =
        _callService.streamCall(widget.callId).listen(
      (call) {
        if (call == null || !mounted || _isAnswered) {
          return;
        }

        switch (call.status) {
          case CallStatus.cancelled:
          case CallStatus.missed:
          case CallStatus.rejected:
          case CallStatus.ended:
            _cancelTimers();

            if (mounted) {
              Navigator.of(context).pop();
            }
            break;

          default:
            break;
        }
      },
      onError: (error) {
        debugPrint(
          '⚠️ Incoming call stream error: $error',
        );
      },
    );
  }

  Future<void> _acceptCall() async {
    if (_isProcessing || _isAnswered) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _callService.acceptCall(widget.callId);

      if (!mounted) return;

      setState(() {
        _isAnswered = true;
      });

      _cancelTimers();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callId: widget.callId,
            chatId: widget.chatId,
            doctorName: widget.callerName,
            doctorId: widget.callerId,
            isVideo: widget.isVideo,
            isOutgoing: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ تعذر قبول المكالمة: $e'),
        ),
      );
    }
  }

  Future<void> _rejectCall() async {
    if (_isProcessing || _isAnswered) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _callService.rejectCall(widget.callId);
    } catch (e) {
      debugPrint(
        '⚠️ Failed to reject call: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      _isAnswered = true;
    });

    _cancelTimers();
    Navigator.of(context).pop();
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    _callSubscription?.cancel();
    _callSubscription = null;
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
                widget.isVideo
                    ? Icons.videocam
                    : Icons.person,
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
              widget.isVideo
                  ? '📹 مكالمة فيديو واردة'
                  : '📞 مكالمة صوتية واردة',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'يرن... ($_remainingSeconds ث)',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            const Spacer(),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 30,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.call_end,
                    color: AppColors.error,
                    label: 'رفض',
                    onTap: _isProcessing
                        ? null
                        : _rejectCall,
                  ),
                  _buildActionButton(
                    icon: widget.isVideo
                        ? Icons.videocam
                        : Icons.call,
                    color: AppColors.success,
                    label: 'رد',
                    onTap: _isProcessing
                        ? null
                        : _acceptCall,
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
    required VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1,
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
