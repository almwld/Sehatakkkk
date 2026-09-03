// ============================================================
// 📞 CallService - خدمة المكالمات الكاملة
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/call_model.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInCall = false;
  String? _currentCallId;
  Timer? _callTimer;
  int _callDuration = 0;

  final StreamController<CallModel> _callController =
      StreamController<CallModel>.broadcast();
  Stream<CallModel> get callStream => _callController.stream;

  bool get isInCall => _isInCall;
  int get callDuration => _callDuration;

  // ============================================================
  // 📞 بدء مكالمة
  // ============================================================

  Future<CallModel> startCall({
    required String receiverId,
    required String receiverName,
    required String chatId,
    required bool isVideo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final callId = _firestore.collection('calls').doc().id;
    final now = DateTime.now();

    final call = CallModel(
      id: callId,
      chatId: chatId,
      callerId: user.uid,
      callerName: user.displayName ?? 'مستخدم',
      receiverId: receiverId,
      receiverName: receiverName,
      callType: isVideo ? CallType.video : CallType.audio,
      status: CallStatus.calling,
      startedAt: now,
      participants: [user.uid, receiverId],
      isVideoCall: isVideo,
    );

    await _firestore.collection('calls').doc(callId).set(call.toFirestore());

    _currentCallId = callId;
    _isInCall = true;
    _callController.add(call);

    return call;
  }

  // ============================================================
  // ✅ قبول مكالمة
  // ============================================================

  Future<void> acceptCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'connected',
        'connectedAt': FieldValue.serverTimestamp(),
        'isAnswered': true,
      });
      _startTimer();
    } catch (e) {
      print('❌ Error accepting call: $e');
    }
  }

  // ============================================================
  // ❌ رفض مكالمة
  // ============================================================

  Future<void> rejectCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'rejected',
        'endedAt': FieldValue.serverTimestamp(),
      });
      _endCallInternal();
    } catch (e) {
      print('❌ Error rejecting call: $e');
    }
  }

  // ============================================================
  // ⏹️ إنهاء مكالمة
  // ============================================================

  Future<void> endCall(String callId) async {
    try {
      final duration = _callDuration;
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': duration,
      });
      _endCallInternal();
    } catch (e) {
      print('❌ Error ending call: $e');
    }
  }

  // ============================================================
  // 📋 جلب سجل المكالمات
  // ============================================================

  Stream<List<CallModel>> getCallHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('calls')
        .where('participants', arrayContains: userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CallModel.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }

  // ============================================================
  // 📡 الاستماع لمكالمة محددة
  // ============================================================

  Stream<CallModel> streamCall(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw Exception('Call not found');
          }
          return CallModel.fromFirestore(doc.id, doc.data()!);
        });
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration++;
    });
  }

  void _endCallInternal() {
    _callTimer?.cancel();
    _callTimer = null;
    _callDuration = 0;
    _isInCall = false;
    _currentCallId = null;
  }

  void dispose() {
    _callTimer?.cancel();
    _callController.close();
  }
}

// ============================================================
// 📊 نماذج المكالمات
// ============================================================

enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, ended, missed, rejected }
