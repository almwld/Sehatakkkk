// ============================================================
// 📞 incoming_call_screen.dart — Full Support
// - Glassmorphism expansion
// - Scale ×2 on swipe
// - Background isolate (app closed)
// - Lock screen (full-screen intent)
// - Wake lock
// ============================================================

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:sehatak/core/constants/app_images.dart';
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

  /// ⚠️ إذا فُتح من background isolate — قد لا يكون هناك Navigator
  final bool fromBackground;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.callerId,
    this.callerImage,
    required this.isVideo,
    required this.chatId,
    required this.onCallAnswered,
    this.fromBackground = false,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const Color _bgDark = Color(0xFF0A0F1C);
  static const Color _bgMid = Color(0xFF10352F);
  static const Color _teal = Color(0xFF0A8F83);
  static const Color _cyan = Color(0xFF00BCD4);
  static const Color _red = Color(0xFFE53935);
  static const Color _green = Color(0xFF4CAF50);

  late final AnimationController _pulseController;
  late final AnimationController _haloController;
  late final AnimationController _answerExpansionController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _haloAnimation;
  late final Animation<double> _answerExpansionAnimation;

  final CallService _callService = CallService();
  StreamSubscription<CallModel?>? _callSubscription;
  Timer? _vibrationTimer;

  bool _isProcessing = false;
  bool _isMuted = false;
  bool _isAlerting = true;
  bool _answerSwipeTriggered = false;
  double _answerSwipeDistance = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableWakeLock();
    _enableFullScreenUI();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _haloController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _haloAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeOut),
    );

    _answerExpansionController = AnimationController(
      duration: const Duration(milliseconds: 430),
      vsync: this,
    );
    _answerExpansionAnimation = CurvedAnimation(
      parent: _answerExpansionController,
      curve: Curves.easeInOutCubic,
    );

    unawaited(_startVibration());
    _listenToCall();
    unawaited(WakelockPlus.enable());
  }

  Future<void> _enableWakeLock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('Wakelock error: $e');
    }
  }

  void _enableFullScreenUI() {
    // Keep the Android status bar visible so message/call notifications remain accessible.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _startVibration() async {
    if (!await Vibrate.canVibrate) return;
    _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isAlerting && mounted) Vibrate.feedback(FeedbackType.medium);
    });
  }

  void _listenToCall() {
    _callSubscription = _callService.streamCall(widget.callId).listen(
      (call) {
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
      },
      onError: (Object error) {
        debugPrint('Incoming call stream error: $error');
      },
    );
  }

  void _stopAlerting() {
    _isAlerting = false;
    _vibrationTimer?.cancel();
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
    HapticFeedback.mediumImpact();
    setState(() {
      _answerSwipeTriggered = true;
      _isProcessing = true;
      _answerSwipeDistance = 0;
    });
    try {
      await _answerExpansionController.forward();
      if (mounted) await _acceptCall(prelocked: true);
    } catch (_) {
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
    if (_answerSwipeDistance >= 78) unawaited(_triggerSwipeAnswer());
  }

  void _handleAnswerSwipeEnd(DragEndDetails details) {
    if (_isProcessing || _answerSwipeTriggered) return;
    if (_answerSwipeDistance >= 58) {
      unawaited(_triggerSwipeAnswer());
    } else if (mounted) {
      setState(() => _answerSwipeDistance = 0);
    }
  }

  Future<void> _toggleMute() async {
    final muted = !_isMuted;
    setState(() => _isMuted = muted);
    await CallSoundCoordinator.instance.setIncomingMuted(muted);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _enableFullScreenUI();
      unawaited(WakelockPlus.enable());
    }
  }

  @override
  void dispose() {
    _stopAlerting();
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _haloController.dispose();
    _answerExpansionController.dispose();
    _restoreSystemUI();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 700;
    final imageUrl = widget.callerImage?.trim().isNotEmpty == true
        ? widget.callerImage!.trim()
        : ImageKit.doctor1;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) unawaited(_rejectCall());
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_bgDark, _bgMid, _bgDark],
                      stops: [0, .5, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: .85,
                      colors: [_teal.withOpacity(.20), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80,
              left: -80,
              child: _blurCircle(240, _teal.withOpacity(.22)),
            ),
            Positioned(
              bottom: -100,
              right: -80,
              child: _blurCircle(280, _cyan.withOpacity(.12)),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _statusLabel(),
                  SizedBox(height: isCompact ? 24 : 40),
                  _avatarSection(imageUrl, isCompact),
                  SizedBox(height: isCompact ? 18 : 26),
                  _callerInfo(isCompact),
                  const Spacer(),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 20 : 28,
                      12,
                      isCompact ? 20 : 28,
                      isCompact ? 24 : 40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildCallButton(
                          icon: _isMuted
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          label: _isMuted ? 'تشغيل الرنين' : 'كتم الرنين',
                          color: _cyan,
                          size: isCompact ? 58 : 65,
                          onTap: _isProcessing
                              ? null
                              : () => unawaited(_toggleMute()),
                        ),
                        _buildCallButton(
                          icon: Icons.call_end_rounded,
                          label: 'رفض',
                          color: _red,
                          size: isCompact ? 68 : 78,
                          isMain: true,
                          onTap: _isProcessing ? null : _rejectCall,
                        ),
                        _buildCallButton(
                          icon: widget.isVideo
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          label: 'قبول',
                          color: _green,
                          size: isCompact ? 68 : 78,
                          isMain: true,
                          pulse: true,
                          swipeDistance: _answerSwipeDistance,
                          onTap: _isProcessing ? null : _acceptCall,
                          onPanUpdate: _handleAnswerSwipeUpdate,
                          onPanEnd: _handleAnswerSwipeEnd,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: SafeArea(
                child: _iconButton(
                  icon: Icons.close_rounded,
                  onTap: _isProcessing ? null : _rejectCall,
                ),
              ),
            ),
            if (_answerSwipeTriggered)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _answerExpansionAnimation,
                    builder: (_, __) {
                      final v = _answerExpansionAnimation.value;
                      final size = MediaQuery.sizeOf(context);
                      final radius = size.longestSide * 1.15;
                      return Center(
                        child: Transform.scale(
                          scale: v * radius / 78,
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 20 * v,
                                sigmaY: 20 * v,
                              ),
                              child: Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(.25 * v),
                                      _green.withOpacity(.35 * v),
                                      _green.withOpacity(.15 * v),
                                    ],
                                    stops: const [0, .5, 1],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.45 * v),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _green.withOpacity(.4 * v),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(.2 * v),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Icon(
                                  widget.isVideo
                                      ? Icons.videocam_rounded
                                      : Icons.call_rounded,
                                  color: Colors.white.withOpacity(.95),
                                  size: 35,
                                ),
                              ),
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
    );
  }

  Widget _blurCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
          ],
        ),
      );

  Widget _statusLabel() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseDot(),
            SizedBox(width: 8),
            Text(
              'مكالمة واردة',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: .3,
              ),
            ),
          ],
        ),
      );

  Widget _avatarSection(String imageUrl, bool isCompact) {
    final avatarSize = isCompact ? 140.0 : 170.0;
    return SizedBox(
      width: avatarSize * 1.5,
      height: avatarSize * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _haloAnimation,
            builder: (_, __) {
              final v = _haloAnimation.value;
              return Container(
                width: avatarSize * (1 + v * .5),
                height: avatarSize * (1 + v * .5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _teal.withOpacity((1 - v) * .5),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _haloAnimation,
            builder: (_, __) {
              final v = (_haloAnimation.value + .5) % 1;
              return Container(
                width: avatarSize * (1 + v * .5),
                height: avatarSize * (1 + v * .5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _teal.withOpacity((1 - v) * .5),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            ),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(.35),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(.6),
                    blurRadius: 50,
                    spreadRadius: 8,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callerInfo(bool isCompact) => Column(
        children: [
          Text(
            widget.callerName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 26 : 30,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
              height: 1.15,
            ),
          ),
          SizedBox(height: isCompact ? 12 : 16),
          _glassBadge(
            icon: widget.isVideo
                ? Icons.videocam_rounded
                : Icons.call_rounded,
            text: widget.isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة',
          ),
        ],
      );

  Widget _glassBadge({required IconData icon, required String text}) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _iconButton({required IconData icon, VoidCallback? onTap}) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white.withOpacity(.85),
              size: 28,
            ),
          ),
        ),
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
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
  }) {
    final swipeProgress = (swipeDistance / 78).clamp(0.0, 1.0);
    final scaleFactor = 1 + swipeProgress;
    final effectiveSize = size * scaleFactor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, -swipeDistance * .4),
            width: effectiveSize,
            height: effectiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMain
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(.95), color],
                    )
                  : null,
              color: isMain ? null : color.withOpacity(.12),
              border: Border.all(
                color: isMain ? Colors.white.withOpacity(.15) : color,
                width: isMain ? 0 : 2,
              ),
              boxShadow: isMain || pulse
                  ? [
                      BoxShadow(
                        color: color.withOpacity(.45 + swipeProgress * .3),
                        blurRadius: 20 + swipeProgress * 30,
                        spreadRadius: 4 + swipeProgress * 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isMain ? Colors.white : color,
              size: isMain ? 34 + swipeProgress * 15 : 26,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: .2,
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withOpacity(.5 + _c.value * .5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      );
}
