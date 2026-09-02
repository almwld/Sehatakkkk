// ============================================================
// 📞 CallService - نظام المكالمات مع LiveKit
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_model.dart';
import '../constants/api_config.dart';
import 'auth_service.dart';
import 'livekit_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LiveKitService _liveKitService = LiveKitService();

  bool _isIncomingCallScreenOpen = false;
  String? _currentCallId;

  // ============================================================
  // 🔑 الحصول على Firebase ID Token
  // ============================================================

  Future<String> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return await user.getIdToken();
  }

  // ============================================================
  // 📞 بدء مكالمة
  // ============================================================

  Future<void> startCall({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
    required BuildContext context,
  }) async {
    try {
      // ✅ التحقق من الصلاحيات
      final permissions = await _checkPermissions(isVideo);
      if (!permissions) {
        throw Exception('Permission denied for call');
      }

      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // ✅ الحصول على معلومات المستخدم
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      // ✅ إنشاء المكالمة
      final callData = {
        'callerId': userId,
        'callerName': callerName,
        'callerPhotoUrl': userData?['photoUrl'],
        'receiverId': receiverId,
        'receiverName': userData?['name'] ?? 'مستخدم',
        'chatId': chatId,
        'callType': isVideo ? 'video' : 'audio',
        'status': 'calling',
        'isAnswered': false,
        'startedAt': FieldValue.serverTimestamp(),
        'participants': [userId, receiverId],
        'liveKitRoomName': chatId,
        'isVideoCall': isVideo,
      };

      // ✅ حفظ في Firestore
      final callRef = await _firestore.collection('calls').add(callData);
      final callId = callRef.id;
      _currentCallId = callId;

      // ✅ تحديث معرف المكالمة
      await callRef.update({'id': callId});

      // ✅ فتح شاشة المكالمة
      _navigateToCallScreen(context, callId, chatId, isVideo, true);

    } catch (e) {
      throw Exception('Error starting call: $e');
    }
  }

  // ============================================================
  // 📥 قبول المكالمة
  // ============================================================

  Future<void> acceptCall({
    required String callId,
    required String chatId,
    required bool isVideo,
    required BuildContext context,
  }) async {
    try {
      // ✅ تحديث حالة المكالمة
      await _firestore.collection('calls').doc(callId).update({
        'status': 'connected',
        'isAnswered': true,
        'connectedAt': FieldValue.serverTimestamp(),
      });

      // ✅ فتح شاشة المكالمة
      _navigateToCallScreen(context, callId, chatId, isVideo, false);

    } catch (e) {
      throw Exception('Error accepting call: $e');
    }
  }

  // ============================================================
  // ❌ رفض المكالمة
  // ============================================================

  Future<void> rejectCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'rejected',
        'endedAt': FieldValue.serverTimestamp(),
        'isAnswered': false,
      });
      _currentCallId = null;
    } catch (e) {
      print('⚠️ Error rejecting call: $e');
    }
  }

  // ============================================================
  // ⏹️ إنهاء المكالمة
  // ============================================================

  Future<void> endCall(String callId) async {
    try {
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) return;

      final callData = callDoc.data()!;
      final startedAt = callData['startedAt'] as Timestamp?;
      int duration = 0;

      if (startedAt != null) {
        final now = DateTime.now();
        duration = now.difference(startedAt.toDate()).inSeconds;
      }

      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
        'durationSeconds': duration,
      });

      _currentCallId = null;
    } catch (e) {
      print('⚠️ Error ending call: $e');
    }
  }

  // ============================================================
  // 📋 الحصول على سجل المكالمات
  // ============================================================

  Future<List<CallModel>> getCallHistory() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('calls')
          .where('participants', arrayContains: userId)
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return CallModel.fromFirestore(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Error getting call history: $e');
    }
  }

  // ============================================================
  // 📡 الاستماع الفوري للمكالمات
  // ============================================================

  Stream<List<CallModel>> streamCalls() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

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
  // 🚀 فتح شاشة المكالمة
  // ============================================================

  void _navigateToCallScreen(
    BuildContext context,
    String callId,
    String chatId,
    bool isVideo,
    bool isOutgoing,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callId: callId,
          chatId: chatId,
          isVideo: isVideo,
          isOutgoing: isOutgoing,
        ),
      ),
    );
  }

  // ============================================================
  // 🔍 التحقق من الصلاحيات
  // ============================================================

  Future<bool> _checkPermissions(bool isVideo) async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      return false;
    }

    if (isVideo) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // 🧹 تنظيف
  // ============================================================

  String? get currentCallId => _currentCallId;
  bool get isInCall => _currentCallId != null;
}
