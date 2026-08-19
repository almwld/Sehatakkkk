import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callerId;
  final String? callerImage;
  final bool isVideo;
  final String chatId;
  final Function(bool) onCallAnswered;

  const IncomingCallScreen({
    super.key,
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isMuted = false;
  bool _isVibrating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✅ تشغيل الرنين
    SoundManager().playCallRingtone();

    // ✅ تشغيل الاهتزاز
    _startVibration();
  }

  Future<void> _startVibration() async {
    if (await Vibrate.canVibrate) {
      _isVibrating = true;
      Vibrate.feedback(FeedbackType.medium);
      Future.delayed(const Duration(seconds: 1), () {
        if (_isVibrating && mounted) {
          Vibrate.feedback(FeedbackType.medium);
        }
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (_isVibrating && mounted) {
          Vibrate.feedback(FeedbackType.medium);
        }
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (_isVibrating && mounted) {
          Vibrate.feedback(FeedbackType.medium);
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    SoundManager().stopAll();
    _isVibrating = false;
    super.dispose();
  }

  void _acceptCall() async {
    SoundManager().stopAll();
    _isVibrating = false;

    // ✅ إشعار بقبول المكالمة
    widget.onCallAnswered(true);

    // ✅ الانتقال إلى شاشة المكالمة
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: widget.chatId,
          doctorName: widget.callerName,
          doctorId: widget.callerId,
          isVideo: widget.isVideo,
        ),
      ),
    );
  }

  void _rejectCall() {
    SoundManager().stopAll();
    _isVibrating = false;
    SoundManager().playCallEnd();

    // ✅ إشعار برفض المكالمة
    widget.onCallAnswered(false);

    Navigator.pop(context);
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) {
      SoundManager().stopAll();
    } else {
      SoundManager().playCallRingtone();
    }
  }

  void _switchToVideo() {
    // ✅ تحويل إلى مكالمة فيديو
    widget.onCallAnswered(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: widget.chatId,
          doctorName: widget.callerName,
          doctorId: widget.callerId,
          isVideo: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ خلفية متدرجة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF0B1121), const Color(0xFF1A1A2E)]
                      : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
                ),
              ),
            ),

            // ✅ المحتوى الرئيسي
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ صورة المتصل (مع نبض)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.callerImage ?? ImageKit.doctor1,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // ✅ اسم المتصل
                Text(
                  widget.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // ✅ نوع المكالمة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isVideo ? Icons.videocam : Icons.phone,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ✅ حالة المكالمة
                const Text(
                  'جاري الاتصال...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),

                // ✅ أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ✅ زر كتم الصوت
                    _buildCallButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: _isMuted ? 'إلغاء الكتم' : 'كتم',
                      color: _isMuted ? Colors.orange : Colors.white,
                      onTap: _toggleMute,
                    ),

                    // ✅ زر رفض
                    _buildCallButton(
                      icon: Icons.call_end,
                      label: 'رفض',
                      color: Colors.red,
                      size: 70,
                      onTap: _rejectCall,
                      isMain: true,
                    ),

                    // ✅ زر قبول
                    _buildCallButton(
                      icon: Icons.call,
                      label: 'قبول',
                      color: Colors.green,
                      size: 70,
                      onTap: _acceptCall,
                      isMain: true,
                    ),

                    // ✅ زر تحويل إلى فيديو (إذا كانت صوتية)
                    if (!widget.isVideo)
                      _buildCallButton(
                        icon: Icons.videocam,
                        label: 'فيديو',
                        color: Colors.blue,
                        onTap: _switchToVideo,
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),

            // ✅ زر العودة (في الأعلى)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _rejectCall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required Color color,
    double size = 55,
    VoidCallback? onTap,
    bool isMain = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isMain ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: isMain ? null : Border.all(color: color.withOpacity(0.5), width: 2),
              boxShadow: isMain
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isMain ? Colors.white : color,
              size: size * 0.45,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isMain ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
