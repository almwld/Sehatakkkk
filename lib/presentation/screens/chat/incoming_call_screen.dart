import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

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
  static const _teal = Color(0xFF0A8F83);
  static const _cyan = Color(0xFF00BCD4);
  static const _red = Color(0xFFE53935);
  static const _green = Color(0xFF4CAF50);

  final CallService _callService = CallService();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _answerExpansionController;
  late final Animation<double> _answerExpansionAnimation;
  StreamSubscription<CallModel?>? _callSubscription;
  Timer? _countdownTimer;
  Timer? _timeoutTimer;
  Timer? _vibrationTimer;

  int _remainingSeconds = 30;
  bool _isProcessing = false;
  bool _isMuted = false;
  bool _isAlerting = true;
  bool _answerSwipeTriggered = false;
  double _answerSwipeDistance = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _answerExpansionController = AnimationController(
      duration: const Duration(milliseconds: 430),
      vsync: this,
    );
    _answerExpansionAnimation = CurvedAnimation(
      parent: _answerExpansionController,
      curve: Curves.easeInOutCubic,
    );
    _startVibration();
    _listenToCall();
    _startTimeout();
  }

  Future<void> _startVibration() async {
    if (!await Vibrate.canVibrate) return;
    _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isAlerting || !mounted) return;
      Vibrate.feedback(FeedbackType.medium);
    });
  }

  void _startTimeout() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isProcessing || !_isAlerting) return;
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
      _stopAlerting();
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _listenToCall() {
    _callSubscription = _callService.streamCall(widget.callId).listen((call) {
      if (!mounted || call == null || _isProcessing) return;
      if (call.status == CallStatus.connected ||
          call.status == CallStatus.cancelled ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.missed ||
          call.status == CallStatus.busy ||
          call.status == CallStatus.ended) {
        _stopAlerting();
        if (call.status == CallStatus.busy) {
          ToastService.showInfo('المستخدم مشغول بمكالمة أخرى');
        }
        if (call.status != CallStatus.connected && mounted) {
          Navigator.of(context).pop();
        }
      }
    }, onError: (error) {
      debugPrint('Incoming call stream error: $error');
    });
  }

  void _stopAlerting() {
    _isAlerting = false;
    _vibrationTimer?.cancel();
    _countdownTimer?.cancel();
    _timeoutTimer?.cancel();
    unawaited(CallSoundCoordinator.instance.stopForCall(widget.callId));
    _callSubscription?.cancel();
    _callSubscription = null;
  }

  Future<void> _acceptCall({bool prelocked = false}) async {
    if (_isProcessing && !prelocked) return;
    if (!prelocked) setState(() => _isProcessing = true);
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
        _answerSwipeTriggered = false;
        _answerSwipeDistance = 0;
      });
      await _answerExpansionController.reverse();
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

  Future<void> _triggerSwipeAnswer() async {
    if (_isProcessing || _answerSwipeTriggered) return;
    setState(() {
      _answerSwipeTriggered = true;
      _isProcessing = true;
      _answerSwipeDistance = 0;
    });
    try {
      await _answerExpansionController.forward();
      if (!mounted) return;
      await _acceptCall(prelocked: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _answerSwipeTriggered = false;
        _answerSwipeDistance = 0;
      });
      await _answerExpansionController.reverse();
    }
  }

  void _handleAnswerSwipeUpdate(DragUpdateDetails details) {
    if (_isProcessing || _answerSwipeTriggered) return;
    final upward = -details.delta.dy;
    if (upward <= 0) return;
    setState(() {
      _answerSwipeDistance = (_answerSwipeDistance + upward).clamp(0, 110);
    });
    if (_answerSwipeDistance >= 78) {
      unawaited(_triggerSwipeAnswer());
    }
  }

  void _handleAnswerSwipeEnd(DragEndDetails details) {
    if (_isProcessing || _answerSwipeTriggered) return;
    if (_answerSwipeDistance >= 58) {
      unawaited(_triggerSwipeAnswer());
      return;
    }
    if (mounted) setState(() => _answerSwipeDistance = 0);
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
    _answerExpansionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.callerImage?.trim().isNotEmpty == true
        ? widget.callerImage!.trim()
        : ImageKit.doctor1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0F1C), Color(0xFF10352F), Color(0xFF0A0F1C)],
              stops: [0, .5, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: .8,
                      colors: [_teal.withOpacity(.18), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 18),
                  const Text('مكالمة واردة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(.3), width: 4),
                        boxShadow: [
                          BoxShadow(color: _teal.withOpacity(.5), blurRadius: 50, spreadRadius: 15),
                        ],
                        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.callerName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: .5),
                  ),
                  const SizedBox(height: 14),
                  _glassBadge(
                    icon: widget.isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                    text: widget.isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white70, size: 17),
                      const SizedBox(width: 6),
                      Text('$_remainingSeconds ثانية', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCallButton(
                          icon: _isMuted ? Icons.notifications_off_rounded : Icons.notifications_active_rounded,
                          label: _isMuted ? 'تشغيل الرنين' : 'كتم الرنين',
                          color: _cyan,
                          onTap: _isProcessing ? null : () => unawaited(_toggleMute()),
                        ),
                        _buildCallButton(
                          icon: Icons.call_end_rounded,
                          label: 'رفض',
                          color: _red,
                          size: 75,
                          isMain: true,
                          onTap: _isProcessing ? null : _rejectCall,
                        ),
                        _buildCallButton(
                          icon: widget.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                          label: 'قبول',
                          color: _green,
                          size: 75,
                          isMain: true,
                          pulse: true,
                          swipeDistance: _answerSwipeDistance,
                          expansionAnimation: _answerExpansionAnimation,
                          onTap: _isProcessing ? null : _acceptCall,
                          onPanUpdate: _handleAnswerSwipeUpdate,
                          onPanEnd: _handleAnswerSwipeEnd,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  onPressed: _isProcessing ? null : _rejectCall,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ),
              if (_answerSwipeTriggered)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _answerExpansionAnimation,
                      builder: (_, __) {
                        final size = MediaQuery.sizeOf(context);
                        final radius = size.longestSide * 1.15;
                        return Center(
                          child: Transform.scale(
                            scale: _answerExpansionAnimation.value * radius / 75,
                            child: Container(
                              width: 75,
                              height: 75,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _green,
                              ),
                              child: Icon(
                                widget.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassBadge({required IconData icon, required String text}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(.20)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    double size = 65,
    bool isMain = false,
    bool pulse = false,
    double swipeDistance = 0,
    Animation<double>? expansionAnimation,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
  }) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              transform: Matrix4.identity()..translate(0.0, -swipeDistance * .12),
              width: size + swipeDistance * .12,
              height: size + swipeDistance * .12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMain ? color : color.withOpacity(.15),
                border: Border.all(color: color, width: isMain ? 0 : 2),
                boxShadow: (isMain || pulse)
                    ? [BoxShadow(color: color.withOpacity(.40), blurRadius: 20 + swipeDistance * .12, spreadRadius: 5 + swipeDistance * .05)]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: isMain ? Colors.white : color, size: size * .45),
                  if (onPanUpdate != null && swipeDistance > 8 && expansionAnimation == null)
                    Positioned(top: 5, child: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      );
}
