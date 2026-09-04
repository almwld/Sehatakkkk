import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/call_model.dart';

enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, ended, missed, rejected, busy, cancelled }

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

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

    final roomName = 'call_${chatId}_${DateTime.now().millisecondsSinceEpoch}';

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
      'roomName': roomName,
    };

    await callRef.set(callData);
    return CallModel.fromFirestore(callId, callData);
  }

  // ============================================================
  // ✅ قبول المكالمة (مع State Machine)
  // ============================================================
  Future<void> acceptCall(String callId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      
      // ✅ فقط CALLING أو RINGING يمكن قبولها
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) {
        throw Exception('لا يمكن قبول المكالمة في حالتها الحالية');
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.connected.name,
        'isAnswered': true,
        'connectedAt': FieldValue.serverTimestamp(),
      });
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
    });
  }

  // ============================================================
  // ⏰ تفويت المكالمة (مهلة)
  // ============================================================
  Future<void> missCall(String callId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(_firestore.collection('calls').doc(callId));
      if (!doc.exists) return;

      final status = doc.data()?['status'] as String?;
      
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) {
        return; // لا تفويت إذا لم تكن في حالة الرنين
      }

      transaction.update(_firestore.collection('calls').doc(callId), {
        'status': CallStatus.missed.name,
        'endedAt': FieldValue.serverTimestamp(),
      });
    });
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
  // 📞 معالجة مكالمة واردة (من FCM)
  // ============================================================
  void handleIncomingCall(BuildContext context, Map<String, dynamic> data) {
    final callId = data['callId'];
    final chatId = data['chatId'];
    final callerId = data['callerId'];
    final callerName = data['callerName'] ?? 'متصل';
    final isVideo = data['isVideo'] == 'true';

    if (callId == null || chatId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => IncomingCallScreen(
          callId: callId,
          chatId: chatId,
          callerId: callerId,
          callerName: callerName,
          isVideo: isVideo,
          onAccept: () => acceptCall(callId),
          onReject: () => rejectCall(callId),
          onTimeout: () => missCall(callId),
          onCancel: () => cancelCall(callId),
        ),
      ),
    );
  }

  // ============================================================
  // 🔐 مساعدة: استخراج userId
  // ============================================================
  String _getUserIdOrThrow() {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    return userId;
  }
}
