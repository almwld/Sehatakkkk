import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/call_sound_coordinator.dart';
import 'package:sehatak/core/services/toast_service.dart';
import '../call/call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerName;
  final String callerId;
  final String? callerImage;
  final bool isVideo;
  final String chatId;
  final Function(bool) onCallAnswered;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.callerId,
    this.callerImage,
    required this.isVideo,
    required this.chatId,
    required this.onCallAnswered,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  static const teal = Color(0xFF0A8F83);
  static const cyan = Color(0xFF00BCD4);
  static const red = Color(0xFFE53935);
  static const green = Color(0xFF4CAF50);

  final CallService _callService = CallService();
  StreamSubscription<CallModel?>? _callSubscription;
  Timer? _vibrationTimer;

  bool _isProcessing = false;
  bool _isAlerting = true;

  @override
  void initState() {
    super.initState();
    unawaited(_startVibration());
    _listenToCall();
  }

  Future<void> _startVibration() async {
    if (!await Vibrate.canVibrate) return;
    _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isAlerting && mounted) Vibrate.feedback(FeedbackType.medium);
    });
  }

  void _listenToCall() {
    _callSubscription = _callService.streamCall(widget.callId).listen((call) {
      if (!mounted || call == null || _isProcessing) return;
      final terminal = call.status == CallStatus.connected ||
          call.status == CallStatus.cancelled ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.missed ||
          call.status == CallStatus.busy ||
          call.status == CallStatus.ended;
      if (!terminal) return;
      _stopAlerting();
      if (call.status == CallStatus.busy) {
        ToastService.showInfo('المستخدم مشغول بمكالمة أخرى');
      }
      if (call.status != CallStatus.connected && mounted) {
        Navigator.of(context).pop();
      }
    }, onError: (Object error) {
      debugPrint('Incoming call stream error: $error');
    });
  }

  void _stopAlerting() {
    _isAlerting = false;
    _vibrationTimer?.cancel();
    unawaited(CallSoundCoordinator.instance.stopForCall(widget.callId));
    _callSubscription?.cancel();
    _callSubscription = null;
  }

  Future<void> _acceptCall() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _callService.acceptCall(widget.callId);
      widget.onCallAnswered(true);
      _stopAlerting();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callId: widget.callId,
            chatId: widget.chatId,
            doctorName: widget.callerName,
            doctorId: widget.callerId,
            doctorImage: widget.callerImage,
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
      ToastService.showError('تعذر قبول المكالمة: $e');
    }
  }

  Future<void> _rejectCall() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _callService.rejectCall(widget.callId);
      widget.onCallAnswered(false);
    } catch (e) {
      debugPrint('Reject call update failed: $e');
    } finally {
      _stopAlerting();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _stopAlerting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.callerImage?.trim().isNotEmpty == true
        ? widget.callerImage!.trim()
        : null;
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE0F2F1),
              backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
              child: imageUrl == null
                  ? Icon(
                      widget.isVideo ? Icons.videocam : Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    )
                  : null,
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
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.call_end,
                    color: AppColors.error,
                    label: 'رفض',
                    onTap: _isProcessing ? null : _rejectCall,
                  ),
                  _buildActionButton(
                    icon: widget.isVideo ? Icons.videocam : Icons.call,
                    color: AppColors.success,
                    label: 'رد',
                    onTap: _isProcessing ? null : _acceptCall,
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
              child: Icon(icon, color: Colors.white, size: 30),
            ),
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
