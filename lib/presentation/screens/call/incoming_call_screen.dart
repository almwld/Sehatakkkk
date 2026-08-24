import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';

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
  late AnimationController _rotateController;
  bool _isMuted = false;
  bool _isVibrating = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // ✅ نبض الصورة
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✅ دوران الزر
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // ✅ تشغيل نغمة الرنين
    SoundManager().playCallRingtone();

    // ✅ تشغيل الاهتزاز
    _startVibration();
  }

  Future<void> _startVibration() async {
    try {
      if (await Vibrate.canVibrate ?? false) {
        _isVibrating = true;
        // ✅ اهتزاز متقطع
        for (int i = 0; i < 10; i++) {
          if (!_isVibrating) break;
          await Future.delayed(const Duration(seconds: 1));
          if (_isVibrating) {
            await Vibrate.vibrate(duration: 200);
          }
        }
      }
    } catch (e) {
      print('⚠️ Vibration error: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    SoundManager().stopAll();
    _isVibrating = false;
    _audioPlayer.dispose();
    super.dispose();
  }

  void _acceptCall() async {
    SoundManager().stopAll();
    _isVibrating = false;
    await _audioPlayer.stop();

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

  void _rejectCall() async {
    SoundManager().stopAll();
    _isVibrating = false;
    await _audioPlayer.stop();
    SoundManager().playCallEnd();

    // ✅ إشعار برفض المكالمة
    widget.onCallAnswered(false);

    Navigator.pop(context);
  }

  void _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) {
      SoundManager().stopAll();
      ToastService.showInfo('🔇 تم كتم الصوت');
    } else {
      SoundManager().playCallRingtone();
      ToastService.showInfo('🔊 تم إلغاء الكتم');
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

  void _sendQuickReply() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'رد سريع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _quickReplyButton('سأتصل بك لاحقاً'),
            _quickReplyButton('مشغول حالياً'),
            _quickReplyButton('أنا في موعد طبي'),
            _quickReplyButton('سأرد عليك قريباً'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _quickReplyButton(String message) {
    return ListTile(
      title: Text(message),
      onTap: () {
        Navigator.pop(context);
        _rejectCall();
        ToastService.showSuccess('✅ تم إرسال الرد: $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
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
                            image: CachedNetworkImageProvider(
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
                const SizedBox(height: 20),

                // ✅ زر رد سريع
                GestureDetector(
                  onTap: _sendQuickReply,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply_outlined,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'رد سريع',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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

            // ✅ زر الإبلاغ عن مكالمة مزعجة
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    ToastService.showInfo('📞 تم الإبلاغ عن مكالمة مزعجة');
                  },
                  child: Text(
                    'الإبلاغ عن مكالمة مزعجة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ),
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
