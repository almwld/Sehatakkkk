import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallService _callService = CallService();
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();

    // ✅ بدء Timer للمكالمة الفائتة (30 ثانية)
    Future.delayed(const Duration(seconds: 30), () {
      if (!_isAnswered && mounted) {
        widget.onTimeout();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // ✅ صورة المتصل
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
            // ✅ اسم المتصل
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // ✅ نوع المكالمة
            Text(
              widget.isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة صوتية واردة',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // ✅ حالة الرنين
            const Text(
              'يرن...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            // ✅ أزرار الرد والرفض
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ❌ رفض
                  _buildActionButton(
                    icon: Icons.call_end,
                    color: AppColors.error,
                    label: 'رفض',
                    onTap: () {
                      setState(() => _isAnswered = true);
                      widget.onReject();
                      Navigator.pop(context);
                    },
                  ),
                  // ✅ قبول
                  _buildActionButton(
                    icon: widget.isVideo ? Icons.videocam : Icons.call,
                    color: AppColors.success,
                    label: 'رد',
                    onTap: () {
                      setState(() => _isAnswered = true);
                      widget.onAccept();

                      // ✅ فتح شاشة المكالمة
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
