import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/call_model.dart';
import '../constants/api_config.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'livekit_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final LiveKitService _liveKitService = LiveKitService();

  bool _isIncomingCallScreenOpen = false;
  String? _currentCallId;

  // ✅ الحصول على Firebase ID Token
  Future<String> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return await user.getIdToken();
  }

  // ✅ بدء مكالمة
  Future<void> startCall({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
    required BuildContext context,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

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

      final callRef = await _firestore.collection('calls').add(callData);
      final callId = callRef.id;
      _currentCallId = callId;
      await callRef.update({'id': callId});

    } catch (e) {
      throw Exception('Error starting call: $e');
    }
  }

  // ✅ معالجة مكالمة واردة
  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    print('📞 Incoming call from: ${message.data['callerName']}');
    print('📞 Call data: ${message.data}');
  }

  // ✅ إنهاء المكالمة
  Future<void> endCall(String callId) async {
    try {
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) return;

      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
      _currentCallId = null;
    } catch (e) {
      print('Error ending call: $e');
    }
  }

  String? get currentCallId => _currentCallId;
  bool get isInCall => _currentCallId != null;
}
