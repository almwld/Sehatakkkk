import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CallService {
  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    final callerName = message.data['callerName'] ?? 'مستخدم';
    final callType = message.data['callType'] ?? 'صوتي';

    ToastService.showInfo('📞 مكالمة واردة من $callerName ($callType)');

    // عرض نافذة المكالمة
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('📞 مكالمة واردة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 30, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              callerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'مكالمة $callType',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('رفض'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastService.showSuccess('✅ تم قبول المكالمة');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );
  }

  void startCall(String userId, String userName, {bool isVideo = false}) {
    ToastService.showInfo('📞 جاري الاتصال بـ $userName...');
  }

  void endCall() {
    ToastService.showInfo('📞 تم إنهاء المكالمة');
  }
}
