import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String chatId;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.chatId,
    this.isVideo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isVideo ? 'مكالمة فيديو' : 'مكالمة صوتية',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVideo
                  ? Icons.videocam_rounded
                  : Icons.call_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'سيتم عرض جلسة LiveKit هنا.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'المحادثة: $chatId',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
