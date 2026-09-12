import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Owns the complete FCM token lifecycle for the signed-in user.
class FcmTokenService {
  FcmTokenService._();
  static final FcmTokenService instance = FcmTokenService._();
  StreamSubscription<String>? _refreshSubscription;
  StreamSubscription<User?>? _authSubscription;
  Future<void>? _syncInFlight;
  String? _lastSyncedToken;
  bool _started = false;
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> start() async {
    if (_started) {
      debugPrint('FCM TOKEN service already started');
      return;
    }
    _started = true;
    debugPrint('FCM TOKEN service starting user=${_auth.currentUser?.uid ?? '(signed-out)'}');
    _refreshSubscription = _messaging.onTokenRefresh.listen(
      (token) {
        debugPrint('FCM TOKEN refresh received length=${token.length}');
        unawaited(syncToken(token));
      },
      onError: (Object error, StackTrace stack) => debugPrint('❌ FCM token refresh stream: $error'),
    );
    _authSubscription = _auth.authStateChanges().listen((user) {
      debugPrint('FCM TOKEN auth change uid=${user?.uid ?? '(signed-out)'}');
      if (user != null) {
        unawaited(syncCurrentToken());
      } else {
        _lastSyncedToken = null;
      }
    });
    if (_auth.currentUser != null) unawaited(syncCurrentToken());
  }

  Future<void> syncCurrentToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('FCM TOKEN sync skipped: no signed-in user');
      return;
    }
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ FCM TOKEN getToken returned empty uid=${user.uid}');
        return;
      }
      debugPrint('FCM TOKEN obtained uid=${user.uid} length=${token.length}');
      await syncToken(token);
    } catch (e) {
      debugPrint('❌ FCM token read error uid=${user.uid}: $e');
    }
  }

  Future<void> syncToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ FCM TOKEN write skipped: no signed-in user');
      return;
    }
    if (token.isEmpty) return;
    if (_lastSyncedToken == token) {
      debugPrint('FCM TOKEN already synchronized uid=${user.uid}');
      return;
    }
    final previous = _syncInFlight;
    if (previous != null) {
      await previous;
      if (_lastSyncedToken == token) return;
    }
    final future = _writeToken(user.uid, token);
    _syncInFlight = future;
    try {
      await future;
      _lastSyncedToken = token;
      debugPrint('✅ FCM TOKEN synchronized to users/${user.uid}');
    } catch (e) {
      debugPrint('❌ FCM TOKEN Firestore write failed uid=${user.uid}: $e');
      rethrow;
    } finally {
      if (identical(_syncInFlight, future)) _syncInFlight = null;
    }
  }

  Future<void> _writeToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> dispose() async {
    await _refreshSubscription?.cancel();
    await _authSubscription?.cancel();
    _refreshSubscription = null;
    _authSubscription = null;
    _started = false;
    _lastSyncedToken = null;
  }
}
