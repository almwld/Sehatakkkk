import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../call/call_screen.dart';

class ChatNavigation {
  // ✅ فتح شاشة الدردشة
  static void openChat(
    BuildContext context, {
    required String doctorName,
    String? doctorId,
    String? chatId,
    bool isVideo = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId ?? 'chat_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: doctorName,
          doctorId: doctorId ?? '1',
          isVideo: isVideo,
        ),
      ),
    );
  }

  // ✅ فتح شاشة المكالمة
  static void openCall(
    BuildContext context, {
    required String doctorName,
    required String doctorId,
    required String chatId,
    bool isVideo = true,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: chatId,
          doctorName: doctorName,
          doctorId: doctorId,
          isVideo: isVideo,
        ),
      ),
    );
  }
}
