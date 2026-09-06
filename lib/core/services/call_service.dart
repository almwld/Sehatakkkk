// ============================================================
// 📞 خدمة المكالمات - النسخة النهائية
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/call_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, ended, missed, rejected, busy, cancelled }

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInCall = false;
  String? _currentCallId;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;

  String? get currentUserId => _auth.currentUser?.uid;

  String _getUserIdOrThrow() {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    return userId;
  }

  // ============================================================
  // 📋 جلب سجل المكالمات (Stream)
  // ============================================================

  Stream<List<CallModel>> streamCallHistory({int limit = 50}) {
    final userId = _getUserIdOrThrow();
    return _firestore
        .collection('calls')
        .where('participants', arrayContains: userId)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ============================================================
  // 📋 الاستماع لمكالمة محددة
  // ============================================================

  Stream<CallModel?> streamCall(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) => doc.exists ? CallModel.fromFirestore(doc.id, doc.data()!) : null);
  }

  // ============================================================
  // 📞 بدء مكالمة
  // ============================================================

  Future<CallModel?> initiateCall({
    required String receiverId,
    required String receiverName,
    String? receiverPhotoUrl,
    required CallType type,
    required String chatId,
    String? idempotencyKey,
  }) async {
    final userId = _getUserIdOrThrow();
    final user = _auth.currentUser!;

    final callId = idempotencyKey ?? _firestore.collection('calls').doc().id;
    final callRef = _firestore.collection('calls').doc(callId);

    final existing = await callRef.get();
    if (existing.exists) {
      return CallModel.fromFirestore(callId, existing.data()!);
    }

    final roomName = chatId;

    final callData = {
      'id': callId,
      'chatId': chatId,
      'callerId': userId,
      'callerName': user.displayName ?? 'مستخدم',
      'callerPhotoUrl': user.photoURL,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhotoUrl': receiverPhotoUrl,
      'callType': type.name,
      'status': CallStatus.calling.name,
      'startedAt': FieldValue.serverTimestamp(),
      'isAnswered': false,
      'participants': [userId, receiverId],
      'liveKitRoomName': roomName,
      'isVideoCall': type == CallType.video,
    };

    await callRef.set(callData);
    _isInCall = true;
    _currentCallId = callId;

    return CallModel.fromFirestore(callId, callData);
  }

  // ============================================================
  // ✅ قبول المكالمة
  // ============================================================

  Future<void> acceptCall(String callId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) {
        throw Exception('لا يمكن قبول المكالمة في حالتها الحالية');
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.connected.name,
        'isAnswered': true,
        'connectedAt': FieldValue.serverTimestamp(),
      });

      _isInCall = true;
      _currentCallId = callId;
    });
  }

  // ============================================================
  // ❌ رفض المكالمة
  // ============================================================

  Future<void> rejectCall(String callId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) {
        throw Exception('لا يمكن رفض المكالمة في حالتها الحالية');
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.rejected.name,
        'endedAt': FieldValue.serverTimestamp(),
      });

      _isInCall = false;
      _currentCallId = null;
    });
  }

  // ============================================================
  // ❌ إلغاء المكالمة (من المتصل)
  // ============================================================

  Future<void> cancelCall(String callId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) {
        throw Exception('لا يمكن إلغاء المكالمة في حالتها الحالية');
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.cancelled.name,
        'endedAt': FieldValue.serverTimestamp(),
      });

      _isInCall = false;
      _currentCallId = null;
    });
  }

  // ============================================================
  // 🔚 إنهاء المكالمة
  // ============================================================

  Future<void> endCall(String callId, {int? durationSeconds}) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      if (status != CallStatus.connected.name) {
        throw Exception('لا يمكن إنهاء المكالمة في حالتها الحالية');
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.ended.name,
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': durationSeconds,
      });

      _isInCall = false;
      _currentCallId = null;
    });
  }

  // ============================================================
  // ⏰ تفويت المكالمة
  // ============================================================

  Future<void> missCall(String callId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) {
        return;
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.missed.name,
        'endedAt': FieldValue.serverTimestamp(),
      });

      _isInCall = false;
      _currentCallId = null;
    });
  }

  // ============================================================
  // 📞 معالجة المكالمة الواردة (لـ FCM)
  // ============================================================

  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    print('📞 Incoming call from: ${message.data}');
    
    final callId = message.data['callId'] ?? message.data['id'];
    final callerName = message.data['callerName'] ?? 'طبيب';
    final callerId = message.data['callerId'] ?? 'unknown';
    final chatId = message.data['chatId'] ?? 'call_$callId';
    final isVideo = message.data['isVideo'] == 'true';

    if (callId == null || callId.isEmpty) {
      print('⚠️ No callId in message');
      ToastService.showError('❌ لا يمكن معالجة المكالمة');
      return;
    }

    ToastService.showInfo('📞 مكالمة واردة من $callerName');

    // ✅ التنقل إلى شاشة المكالمة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: chatId,
          doctorName: callerName,
          doctorId: callerId,
          isVideo: isVideo,
          callId: callId,
          isOutgoing: false,
        ),
      ),
    );
  }

  // ============================================================
  // 🧹 تنظيف الموارد
  // ============================================================

  void dispose() {
    _isInCall = false;
    _currentCallId = null;
  }
}
