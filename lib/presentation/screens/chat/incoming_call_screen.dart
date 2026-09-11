import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

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

class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
  final CallService _callService = CallService();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  StreamSubscription<CallModel?>? _callSubscription;
  Timer? _countdownTimer;
  Timer? _timeoutTimer;

  int _remainingSeconds = 30;
  bool _isProcessing = false;
  bool _isVibrating = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _startVibration();
    _listenToCall();
    _startTimeout();
  }

  Future<void> _startVibration() async {
    if (!await Vibrate.canVibrate) return;
    _isVibrating = true;
    for (var i = 0; i < 30; i++) {
      if (!_isVibrating || !mounted) break;
      Vibrate.feedback(FeedbackType.medium);
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  void _startTimeout() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isProcessing) return;
      if (_remainingSeconds <= 1) {
        _countdownTimer?.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });
    _timeoutTimer = Timer(const Duration(seconds: 30), () async {
      if (_isProcessing || !mounted) return;
      setState(() => _isProcessing = true);
      try {
        await _callService.missCall(widget.callId);
      } catch (e) {
        debugPrint('Missed call update failed: $e');
      }
      if (!mounted) return;
      _stopAlerting();
      Navigator.of(context).pop();
    });
  }

  void _listenToCall() {
    _callSubscription = _callService.streamCall(widget.callId).listen((call) {
      if (!mounted || call == null || _isProcessing) return;
      if (call.status == CallStatus.cancelled || call.status == CallStatus.rejected || call.status == CallStatus.missed || call.status == CallStatus.busy || call.status == CallStatus.ended) {
        _stopAlerting();
        if (call.status == CallStatus.busy) ToastService.showInfo('المستخدم مشغول بمكالمة أخرى');
        Navigator.of(context).pop();
      }
    }, onError: (error) {
      debugPrint('Incoming call stream error: $error');
    });
  }

  void _stopAlerting() {
    _isVibrating = false;
    unawaited(CallSoundCoordinator.instance.stopForCall(widget.callId));
    _countdownTimer?.cancel();
    _timeoutTimer?.cancel();
    _callSubscription?.cancel();
  }

  Future<void> _acceptCall() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _callService.acceptCall(widget.callId);
      widget.onCallAnswered(true);
      _stopAlerting();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => CallScreen(
          callId: widget.callId,
          chatId: widget.chatId,
          doctorName: widget.callerName,
          doctorId: widget.callerId,
          isVideo: widget.isVideo,
          isOutgoing: false,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
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

  Future<void> _toggleMute() async {
    final muted = !_isMuted;
    setState(() => _isMuted = muted);
    await CallSoundCoordinator.instance.setIncomingMuted(muted);
  }

  @override
  void dispose() {
    _stopAlerting();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = (widget.callerImage?.trim().isNotEmpty == true) ? widget.callerImage!.trim() : ImageKit.doctor1;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF08111F) : const Color(0xFF101B2D),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: isDark ? [const Color(0xFF08111F), const Color(0xFF14263A)] : [const Color(0xFF101B2D), const Color(0xFF19324A)])))),
            Column(
              children: [
                const SizedBox(height: 48),
                const Text('مكالمة واردة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
                  child: Container(width: 132, height: 132, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(.8), width: 3), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.28), blurRadius: 32, spreadRadius: 8)], image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover))),
                ),
                const SizedBox(height: 28),
                Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration(color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(widget.isVideo ? Icons.videocam_rounded : Icons.phone_rounded, color: Colors.white70, size: 17), const SizedBox(width: 8), Text(widget.isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة', style: const TextStyle(color: Colors.white70))])),
                const SizedBox(height: 10),
                Text('يرن... $_remainingSeconds ث', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                const Spacer(),
                if (_isProcessing) const Padding(padding: EdgeInsets.only(bottom: 14), child: CircularProgressIndicator(color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 34),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _buildCallButton(icon: _isMuted ? Icons.notifications_off_rounded : Icons.notifications_active_rounded, label: _isMuted ? 'تشغيل الرنين' : 'كتم الرنين', color: Colors.white, onTap: _isProcessing ? null : () { unawaited(_toggleMute()); }),
                    _buildCallButton(icon: Icons.call_end_rounded, label: 'رفض', color: Colors.red, size: 72, isMain: true, onTap: _isProcessing ? null : _rejectCall),
                    _buildCallButton(icon: widget.isVideo ? Icons.videocam_rounded : Icons.call_rounded, label: 'قبول', color: Colors.green, size: 72, isMain: true, onTap: _isProcessing ? null : _acceptCall),
                  ]),
                ),
              ],
            ),
            Positioned(top: 10, left: 8, child: IconButton(onPressed: _isProcessing ? null : _rejectCall, icon: const Icon(Icons.close_rounded, color: Colors.white70))),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({required IconData icon, required String label, required Color color, required VoidCallback? onTap, double size = 54, bool isMain = false}) => Column(mainAxisSize: MainAxisSize.min, children: [
    GestureDetector(onTap: onTap, child: Opacity(opacity: onTap == null ? .45 : 1, child: Container(width: size, height: size, decoration: BoxDecoration(color: isMain ? color : color.withOpacity(.12), shape: BoxShape.circle, border: isMain ? null : Border.all(color: color.withOpacity(.45)), boxShadow: isMain ? [BoxShadow(color: color.withOpacity(.35), blurRadius: 18, spreadRadius: 3)] : null), child: Icon(icon, color: isMain ? Colors.white : color, size: size * .43)))),
    const SizedBox(height: 6),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);
}
