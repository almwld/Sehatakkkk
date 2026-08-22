import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _hasError = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadUserSafely();
  }

  // ✅ تحميل المستخدم بشكل آمن مع معالجة الأخطاء
  Future<void> loadUserSafely() async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _user = currentUser;
        await _loadUserData(currentUser.uid);
      } else {
        // ✅ محاولة الاستماع لتغيرات المصادقة
        FirebaseAuth.instance.authStateChanges().listen((user) {
          if (user != null) {
            _user = user;
            _loadUserData(user.uid);
          } else {
            _user = null;
            _userData = null;
            _isLoading = false;
            notifyListeners();
          }
        });
        _isLoading = false;
      }
    } catch (e) {
      print('❌ UserProvider error: $e');
      _hasError = true;
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _userData = doc.data();
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
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
