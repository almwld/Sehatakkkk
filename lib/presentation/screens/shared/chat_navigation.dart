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
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(),
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
