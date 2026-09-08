import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sound_manager.dart';

/// Keeps foreground call sounds synchronized with the canonical calls state.
///
/// This is intentionally independent from the call UI so audio starts as soon
/// as the call document enters `calling`/`ringing` and stops on every terminal
/// or connected state.
class CallSoundCoordinator {
  CallSoundCoordinator._();
  static final CallSoundCoordinator instance = CallSoundCoordinator._();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callsSubscription;
  final SoundManager _sounds = SoundManager();
  String? _activeCallId;

  void start() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen((_) {
      _restartCallsListener();
    });
    _restartCallsListener();
  }

  void _restartCallsListener() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
    _activeCallId = null;
    unawaited(_sounds.stopAll());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _callsSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .listen(_onCallsChanged, onError: (Object error, StackTrace stack) {
      // A transient Firestore outage must never crash the app or leave a
      // ringtone playing forever.
      _activeCallId = null;
      unawaited(_sounds.stopAll());
    });
  }

  void _onCallsChanged(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QueryDocumentSnapshot<Map<String, dynamic>>? active;
    DateTime? newest;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString();
      if (status != 'calling' && status != 'ringing') continue;

      final startedAt = data['startedAt'];
      DateTime? started;
      if (startedAt is Timestamp) started = startedAt.toDate();
      if (active == null || (started != null && (newest == null || started.isAfter(newest!)))) {
        active = doc;
        newest = started;
      }
    }

    if (active == null) {
      if (_activeCallId != null) {
        _activeCallId = null;
        unawaited(_sounds.stopAll());
      }
      return;
    }

    final data = active.data();
    final callId = active.id;
    final callerId = data['callerId']?.toString() ?? '';
    final receiverId = data['receiverId']?.toString() ?? '';
    final isIncoming = receiverId == user.uid && callerId != user.uid;
    final isOutgoing = callerId == user.uid;

    if (!isIncoming && !isOutgoing) return;
    if (_activeCallId == callId) return;

    _activeCallId = callId;
    unawaited(
      (isIncoming ? _sounds.playCallRingtone() : _sounds.playRingback())
          .catchError((_) {}),
    );
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _callsSubscription?.cancel();
    _authSubscription = null;
    _callsSubscription = null;
    _activeCallId = null;
    await _sounds.stopAll();
  }
}
