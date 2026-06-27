import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../call/call_screen.dart';

class ChatNavigation {
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
          receiverId: doctorId ?? '1',
          receiverName: doctorName,
          receiverPhoto: null,
          isVideoCall: isVideo,
        ),
      ),
    );
  }

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
          roomName: chatId,
          callerName: doctorName,
          callerPhoto: null,
          isVideo: isVideo,
        ),
      ),
    );
  }
}
