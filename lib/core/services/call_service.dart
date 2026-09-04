import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/call_model.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  Future<CallModel?> initiateCall({
    required String receiverId,
    required String receiverName,
    String? receiverPhotoUrl,
    required CallType type,
    required String chatId,
    String? idempotencyKey,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول قبل إجراء المكالمة');
    }

    final callerId = user.uid;
    final normalizedReceiverId = receiverId.trim();
    final normalizedChatId = chatId.trim();

    if (normalizedReceiverId.isEmpty) {
      throw Exception('معرف المستلم غير صالح');
    }

    if (normalizedChatId.isEmpty) {
      throw Exception('معرف المحادثة غير صالح');
    }

    if (normalizedReceiverId == callerId) {
      throw Exception('لا يمكن الاتصال بنفس المستخدم');
    }

    final callId = idempotencyKey?.trim().isNotEmpty == true
        ? idempotencyKey!.trim()
        : _calls.doc().id;

    final callRef = _calls.doc(callId);

    final existing = await callRef.get();

    if (existing.exists && existing.data() != null) {
      final existingCall = CallModel.fromFirestore(
        existing.id,
        existing.data()!,
      );

      if (existingCall.callerId != callerId) {
        throw Exception('معرف المكالمة مستخدم مسبقًا');
      }

      return existingCall;
    }

    final roomName = normalizedChatId;

    final data = <String, dynamic>{
      'id': callId,
      'chatId': normalizedChatId,
      'callerId': callerId,
      'callerName': user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'مستخدم',
      'callerPhotoUrl': user.photoURL,
      'receiverId': normalizedReceiverId,
      'receiverName': receiverName.trim().isNotEmpty
          ? receiverName.trim()
          : 'مستخدم',
      'receiverPhotoUrl': receiverPhotoUrl,
      'callType': type.name,
      'status': CallStatus.calling.name,
      'startedAt': FieldValue.serverTimestamp(),
      'isAnswered': false,
      'participants': [callerId, normalizedReceiverId],
      'liveKitRoomName': roomName,
      'isVideoCall': type == CallType.video,
    };

    await callRef.set(data);

    final snapshot = await callRef.get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('تعذر إنشاء المكالمة');
    }

    return CallModel.fromFirestore(
      snapshot.id,
      snapshot.data()!,
    );
  }

  Future<void> acceptCall(String callId) async {
    final uid = _getUserIdOrThrow();
    final ref = _calls.doc(callId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);

      if (!doc.exists || doc.data() == null) {
        throw Exception('المكالمة غير موجودة');
      }

      final data = doc.data()!;
      final receiverId = data['receiverId']?.toString();

      if (receiverId != uid) {
        throw Exception('غير مصرح بقبول هذه المكالمة');
      }

      final status = data['status']?.toString();

      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name) {
        throw Exception('لا يمكن قبول المكالمة في حالتها الحالية');
      }

      transaction.update(ref, {
        'status': CallStatus.connected.name,
        'isAnswered': true,
        'connectedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectCall(String callId) async {
    final uid = _getUserIdOrThrow();
    final ref = _calls.doc(callId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);

      if (!doc.exists || doc.data() == null) {
        throw Exception('المكالمة غير موجودة');
      }

      final data = doc.data()!;
      final receiverId = data['receiverId']?.toString();

      if (receiverId != uid) {
        throw Exception('غير مصرح برفض هذه المكالمة');
      }

      final status = data['status']?.toString();

      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name) {
        throw Exception('لا يمكن رفض المكالمة في حالتها الحالية');
      }

      transaction.update(ref, {
        'status': CallStatus.rejected.name,
        'endedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelCall(String callId) async {
    final uid = _getUserIdOrThrow();
    final ref = _calls.doc(callId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);

      if (!doc.exists || doc.data() == null) {
        throw Exception('المكالمة غير موجودة');
      }

      final data = doc.data()!;
      final callerId = data['callerId']?.toString();

      if (callerId != uid) {
        throw Exception('غير مصرح بإلغاء هذه المكالمة');
      }

      final status = data['status']?.toString();

      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name) {
        throw Exception('لا يمكن إلغاء المكالمة في حالتها الحالية');
      }

      transaction.update(ref, {
        'status': CallStatus.cancelled.name,
        'endedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> endCall(
    String callId, {
    int? durationSeconds,
  }) async {
    final uid = _getUserIdOrThrow();
    final ref = _calls.doc(callId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);

      if (!doc.exists || doc.data() == null) {
        throw Exception('المكالمة غير موجودة');
      }

      final data = doc.data()!;
      final participants = List<String>.from(
        data['participants'] ?? const <String>[],
      );

      if (!participants.contains(uid)) {
        throw Exception('غير مصرح بإنهاء هذه المكالمة');
      }

      final status = data['status']?.toString();

      if (status != CallStatus.connected.name) {
        throw Exception('لا يمكن إنهاء المكالمة في حالتها الحالية');
      }

      transaction.update(ref, {
        'status': CallStatus.ended.name,
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': durationSeconds,
      });
    });
  }

  Future<void> missCall(String callId) async {
    final uid = _getUserIdOrThrow();
    final ref = _calls.doc(callId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);

      if (!doc.exists || doc.data() == null) {
        return;
      }

      final data = doc.data()!;

      if (data['receiverId']?.toString() != uid) {
        throw Exception('غير مصرح بتفويت هذه المكالمة');
      }

      final status = data['status']?.toString();

      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name) {
        return;
      }

      transaction.update(ref, {
        'status': CallStatus.missed.name,
        'endedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<CallModel?> streamCall(String callId) {
    return _calls.doc(callId).snapshots().map(
          (doc) => doc.exists && doc.data() != null
              ? CallModel.fromFirestore(doc.id, doc.data()!)
              : null,
        );
  }

  Stream<List<CallModel>> streamIncomingCalls() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value(const <CallModel>[]);
    }

    return _calls
        .where('receiverId', isEqualTo: uid)
        .where(
          'status',
          whereIn: [
            CallStatus.calling.name,
            CallStatus.ringing.name,
          ],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CallModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<CallModel>> streamCallHistory() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value(const <CallModel>[]);
    }

    return _calls
        .where('participants', arrayContains: uid)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CallModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  String _getUserIdOrThrow() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('يجب تسجيل الدخول');
    }

    return uid;
  }
}
