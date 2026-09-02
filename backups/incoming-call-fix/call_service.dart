import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sehatak/presentation/screens/call/incoming_call_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/config/livekit_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CallService {
  static final CallService _instance = CallService._internal();

  factory CallService() => _instance;

  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: LiveKitConfig.apiBaseUrl,
  );

  Future<Map<String, String>> _headers() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('Firebase ID Token غير متوفر');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // بدء المكالمة عبر Backend
  Future<void> startCall({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول');
      return;
    }

    if (chatId.trim().isEmpty) {
      ToastService.showError('❌ معرف المحادثة غير صالح');
      return;
    }

    if (receiverId.trim().isEmpty) {
      ToastService.showError('❌ معرف المستلم غير صالح');
      return;
    }

    if (receiverId.trim() == user.uid) {
      ToastService.showError('❌ لا يمكن الاتصال بالمستخدم نفسه');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/api/chats/${Uri.encodeComponent(chatId)}/call',
        ),
        headers: await _headers(),
        body: jsonEncode({
          'receiverId': receiverId.trim(),
          'callerName': callerName.trim(),
          'isVideo': isVideo,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          body['message']?.toString() ?? 'فشل بدء المكالمة',
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: callerName,
            doctorId: user.uid,
            isVideo: isVideo,
          ),
        ),
      );
    } catch (e) {
      print('❌ Start call error: $e');
      ToastService.showError('❌ فشل بدء المكالمة: $e');
    }
  }

  // معالجة المكالمة الواردة من FCM
  void handleIncomingCall(
    BuildContext context,
    RemoteMessage message,
  ) {
    handleIncomingCallData(context, message.data);
  }

  // معالجة بيانات المكالمة الواردة
  void handleIncomingCallData(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final callerName =
        data['callerName']?.toString() ?? 'مستخدم';

    final isVideo =
        data['isVideo']?.toString().toLowerCase() == 'true';

    final chatId =
        data['chatId']?.toString() ?? '';

    final callerId =
        data['callerId']?.toString() ?? '';

    final currentUser = _auth.currentUser;

    if (currentUser?.uid == callerId) {
      return;
    }

    if (chatId.isEmpty || callerId.isEmpty) {
      print('⚠️ Incoming call missing chatId or callerId');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: callerName,
          callerId: callerId,
          isVideo: isVideo,
          chatId: chatId,
          onCallAnswered: (accepted) {
            _logCallResponse(chatId, accepted);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // تسجيل الرد على المكالمة
  Future<void> _logCallResponse(
    String chatId,
    bool accepted,
  ) async {
    try {
      await _firestore.collection('calls').doc(chatId).update({
        'status': accepted ? 'answered' : 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Log call response error: $e');
    }
  }

  // تسجيل المكالمة المنتهية
  Future<void> endCall(
    String chatId,
    int duration,
  ) async {
    try {
      await _firestore.collection('calls').doc(chatId).update({
        'status': 'ended',
        'duration': duration,
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ End call error: $e');
    }
  }

  // الحصول على سجل المكالمات
  Stream<List<Map<String, dynamic>>> getCallHistory(
    String userId,
  ) {
    return _firestore
        .collection('calls')
        .where(
          'participants',
          arrayContains: userId,
        )
        .orderBy(
          'startedAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // التحقق من مكالمة نشطة
  Future<bool> isCallActive(String chatId) async {
    try {
      final doc =
          await _firestore.collection('calls').doc(chatId).get();

      if (!doc.exists) {
        return false;
      }

      final status =
          doc.data()?['status'] as String?;

      return status == 'calling' ||
          status == 'answered';
    } catch (e) {
      return false;
    }
  }

  // إلغاء المكالمة
  Future<void> cancelCall(String chatId) async {
    try {
      await _firestore.collection('calls').doc(chatId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Cancel call error: $e');
    }
  }

  // حذف سجل المكالمة
  Future<void> deleteCallHistory(String callId) async {
    try {
      await _firestore
          .collection('calls')
          .doc(callId)
          .delete();
    } catch (e) {
      print('❌ Delete call history error: $e');
    }
  }

  // الاحتفاظ بالـ FCM instance لاستخدامه لاحقًا
  FirebaseMessaging get messaging => _fcm;
}
