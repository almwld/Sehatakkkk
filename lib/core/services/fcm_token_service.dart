import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Owns the complete FCM token lifecycle for the signed-in user.
///
/// The service is deliberately independent from app startup so FCM failures
/// never block `runApp()` and token refreshes are handled consistently.
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
    if (_started) return;
    _started = true;

    _refreshSubscription = _messaging.onTokenRefresh.listen(
      (token) => unawaited(syncToken(token)),
      onError: (Object error, StackTrace stack) {
        debugPrint('❌ FCM token refresh stream: $error');
      },
    );

    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        unawaited(syncCurrentToken());
      } else {
        _lastSyncedToken = null;
      }
    });

    if (_auth.currentUser != null) {
      unawaited(syncCurrentToken());
    }
  }

  Future<void> syncCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await syncToken(token);
    } catch (e) {
      debugPrint('❌ FCM token read error: $e');
    }
  }

  Future<void> syncToken(String token) async {
    final user = _auth.currentUser;
    if (user == null || token.isEmpty) return;
    if (_lastSyncedToken == token) return;

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
    } finally {
      if (identical(_syncInFlight, future)) _syncInFlight = null;
    }
  }

  Future<void> _writeToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      debugPrint('❌ FCM token Firestore sync: ${e.code} ${e.message}');
    } catch (e) {
      debugPrint('❌ FCM token Firestore sync: $e');
    }
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
