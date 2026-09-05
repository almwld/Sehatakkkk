import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;

  bool _isLoading = false;
  bool _hasError = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  UserProvider();

  /// يتم استدعاؤها فقط بعد جاهزية Firebase.
  Future<void> loadUserSafely() async {
    try {
      if (Firebase.apps.isEmpty) {
        return;
      }

      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        _user = currentUser;
        await _loadUserData(currentUser.uid);
      } else {
        _user = null;
        _userData = null;
        _isLoading = false;
        notifyListeners();

        FirebaseAuth.instance.authStateChanges().listen(
          (user) {
            if (user != null) {
              _user = user;
              _loadUserData(user.uid);
            } else {
              _user = null;
              _userData = null;
              _isLoading = false;
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint(
              '❌ Auth state error: $error',
            );
          },
        );
      }
    } catch (e) {
      debugPrint(
        '❌ UserProvider error: $e',
      );

      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      if (Firebase.apps.isEmpty) {
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        _userData = doc.data();
      }
    } catch (e) {
      debugPrint(
        '❌ Error loading user data: $e',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    await loadUserSafely();
  }

  void clearUser() {
    _user = null;
    _userData = null;
    _isLoading = false;
    notifyListeners();
  }
}
