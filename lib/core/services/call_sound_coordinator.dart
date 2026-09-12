import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../presentation/screens/chat/incoming_call_screen.dart';
import '../models/call_model.dart';
import 'active_call_registry.dart';
import 'sound_manager.dart';

/// Owns foreground call alert audio and incoming-call routing.
/// It never joins LiveKit. Firestore remains the call lifecycle source of truth.
/// Only one local call is allowed at a time; additional incoming calls are
/// immediately marked busy and never open another incoming-call UI.
class CallSoundCoordinator {
  CallSoundCoordinator._();
  static final CallSoundCoordinator instance = CallSoundCoordinator._();

  static const Duration _maxCallAge = Duration(seconds: 90);

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callsSubscription;
  final SoundManager _sounds = SoundManager();
  String? _activeCallId;
  String? _incomingUiCallId;
  bool _incomingMuted = false;

  void start() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen((_) => _restartCallsListener());
    _restartCallsListener();
  }

  void _restartCallsListener() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
    _activeCallId = null;
    _incomingUiCallId = null;
    _incomingMuted = false;
    unawaited(_sounds.stopCallAudio());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _callsSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .listen(_onCallsChanged, onError: (Object error, StackTrace stack) {
      debugPrint('CallSoundCoordinator listener error: $error');
      _activeCallId = null;
      _incomingUiCallId = null;
      unawaited(_sounds.stopCallAudio());
    });
  }

  /// Presents an incoming call immediately from any FCM/local-notification
  /// entry point. The Firestore listener remains authoritative and prevents
  /// duplicates through [_incomingUiCallId].
  Future<void> presentIncomingCallById(String callId) async {
    final normalized = callId.trim();
    if (normalized.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final registryId = ActiveCallRegistry.instance.activeCallId;
    if (registryId != null && registryId != normalized) {
      debugPrint('CALL FCM PRESENT BUSY active=$registryId incoming=$normalized');
      try {
        final ref = FirebaseFirestore.instance.collection('calls').doc(normalized);
        final snap = await ref.get();
        final status = snap.data()?['status']?.toString();
        if (status == CallStatus.calling.name || status == CallStatus.ringing.name) {
          await ref.update({
            'status': CallStatus.busy.name,
            'endedAt': FieldValue.serverTimestamp(),
            'busyReason': 'receiver_in_call',
          });
        }
      } catch (e) {
        debugPrint('CALL FCM PRESENT busy update failed: $e');
      }
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance.collection('calls').doc(normalized).get();
      if (!snap.exists) return;
      final data = snap.data() ?? <String, dynamic>{};
      final receiverId = data['receiverId']?.toString() ?? '';
      final callerId = data['callerId']?.toString() ?? '';
      final status = data['status']?.toString() ?? '';
      if (receiverId != user.uid || callerId.isEmpty || callerId == user.uid) return;
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) return;

      _activeCallId = normalized;
      _incomingMuted = false;
      await _sounds.playCallRingtone().catchError((_) {});
      _showIncomingCall(data, normalized);
    } catch (e) {
      debugPrint('CALL FCM PRESENT error id=$normalized error=$e');
    }
  }

  void _onCallsChanged(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      unawaited(_sounds.stopCallAudio());
      return;
    }

    QueryDocumentSnapshot<Map<String, dynamic>>? connected;
    QueryDocumentSnapshot<Map<String, dynamic>>? newestActive;
    DateTime? newestActiveAt;
    QueryDocumentSnapshot<Map<String, dynamic>>? newestIncoming;
    DateTime? newestIncomingAt;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString();
      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name &&
          status != CallStatus.connected.name) continue;

      final startedAt = data['startedAt'];
      if (startedAt is! Timestamp) continue;
      final started = startedAt.toDate();
      final age = DateTime.now().difference(started);
      if (status != CallStatus.connected.name && (age.isNegative || age > _maxCallAge)) continue;

      final callerId = data['callerId']?.toString() ?? '';
      final receiverId = data['receiverId']?.toString() ?? '';
      final isIncoming = receiverId == user.uid && callerId != user.uid;
      final isOutgoing = callerId == user.uid && receiverId != user.uid;
      if (!isIncoming && !isOutgoing) continue;

      if (status == CallStatus.connected.name) {
        connected ??= doc;
        continue;
      }
      if (isIncoming && (newestIncomingAt == null || started.isAfter(newestIncomingAt))) {
        newestIncoming = doc;
        newestIncomingAt = started;
      }
      if (newestActiveAt == null || started.isAfter(newestActiveAt)) {
        newestActive = doc;
        newestActiveAt = started;
      }
    }

    if (connected != null) {
      final connectedId = connected.id;
      if (ActiveCallRegistry.instance.activeCallId != connectedId) ActiveCallRegistry.instance.register(connectedId);
      _activeCallId = connectedId;
      _incomingUiCallId = null;
      _incomingMuted = false;
      unawaited(_sounds.stopCallAudio());
      if (newestIncoming != null && newestIncoming.id != connectedId) unawaited(_markIncomingBusy(newestIncoming.id));
      return;
    }

    if (newestActive == null) {
      _activeCallId = null;
      _incomingUiCallId = null;
      _incomingMuted = false;
      unawaited(_sounds.stopCallAudio());
      return;
    }

    final data = newestActive.data();
    final callId = newestActive.id;
    final callerId = data['callerId']?.toString() ?? '';
    final receiverId = data['receiverId']?.toString() ?? '';
    final isIncoming = receiverId == user.uid && callerId != user.uid;
    final isNewCall = _activeCallId != callId;
    if (isNewCall) {
      _activeCallId = callId;
      _incomingMuted = false;
    }

    if (isIncoming) {
      final registryId = ActiveCallRegistry.instance.activeCallId;
      if (registryId != null && registryId != callId) {
        debugPrint('CALL BUSY no IncomingCallScreen active=$registryId incoming=$callId');
        unawaited(_markIncomingBusy(callId));
        unawaited(_sounds.stopCallAudio());
        return;
      }
      if (_incomingMuted) {
        unawaited(_sounds.stopCallAudio());
      } else {
        unawaited(_sounds.playCallRingtone().catchError((_) {}));
      }
      if (isNewCall) _showIncomingCall(data, callId);
    } else {
      unawaited(_sounds.playRingback().catchError((_) {}));
    }
  }

  Future<void> _markIncomingBusy(String callId) async {
    try {
      final ref = FirebaseFirestore.instance.collection('calls').doc(callId);
      final snap = await ref.get();
      if (!snap.exists) return;
      final status = snap.data()?['status']?.toString();
      if (status != CallStatus.calling.name && status != CallStatus.ringing.name) return;
      await ref.update({'status': CallStatus.busy.name, 'endedAt': FieldValue.serverTimestamp(), 'busyReason': 'receiver_in_call'});
      debugPrint('CALL BUSY marked id=$callId reason=receiver_in_call');
    } catch (e) {
      debugPrint('CALL BUSY update failed id=$callId error=$e');
    } finally {
      if (_activeCallId == callId) _activeCallId = null;
      await _sounds.stopCallAudio();
    }
  }

  void _showIncomingCall(Map<String, dynamic> data, String callId) {
    final nav = navigatorKey.currentState;
    if (nav == null || _incomingUiCallId == callId) return;

    final chatId = data['chatId']?.toString() ?? '';
    if (chatId.isEmpty) return;

    _incomingUiCallId = callId;
    unawaited(showGeneralDialog<void>(
      context: nav.context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'مكالمة واردة',
      barrierColor: Colors.black.withOpacity(.72),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => IncomingCallScreen(
        callId: callId,
        callerName: data['callerName']?.toString() ?? 'مستخدم',
        callerId: data['callerId']?.toString() ?? '',
        callerImage: data['callerPhotoUrl']?.toString(),
        isVideo: data['isVideoCall'] == true || data['callType']?.toString() == 'video',
        chatId: chatId,
        onCallAnswered: (_) {},
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: ScaleTransition(scale: Tween<double>(begin: .96, end: 1).animate(curved), child: child));
      },
    ).whenComplete(() {
      if (_incomingUiCallId == callId) _incomingUiCallId = null;
    }));
  }

  Future<void> setIncomingMuted(bool muted) async {
    _incomingMuted = muted;
    if (muted) {
      await _sounds.stopCallAudio();
    } else if (_activeCallId != null && !ActiveCallRegistry.instance.hasActiveCall) {
      await _sounds.playCallRingtone();
    }
  }

  Future<void> stopForCall(String? callId) async {
    if (callId == null || _activeCallId == null || callId == _activeCallId) {
      _activeCallId = null;
      _incomingMuted = false;
      await _sounds.stopCallAudio();
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _callsSubscription?.cancel();
    _authSubscription = null;
    _callsSubscription = null;
    _activeCallId = null;
    _incomingUiCallId = null;
    _incomingMuted = false;
    ActiveCallRegistry.instance.reset();
    await _sounds.stopAll();
  }
}
