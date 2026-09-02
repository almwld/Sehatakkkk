// ============================================================
// 🔐 AuthService - نظام المصادقة
// ============================================================

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get userStream => _userController.stream;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // ============================================================
  // 🚀 التهيئة
  // ============================================================

  Future<void> init() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        final userModel = await _getUserFromFirestore(user.uid);
        _userController.add(userModel);
        await _saveUserToLocal(userModel);
      } else {
        _userController.add(null);
        await _clearLocalUser();
      }
    });
  }

  // ============================================================
  // 📝 التسجيل بالبريد الإلكتروني وكلمة المرور
  // ============================================================

  Future<UserModel> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;

      final userModel = UserModel(
        id: user.uid,
        email: email,
        phone: phone,
        name: name,
        isPatient: true,
        isDoctor: false,
        createdAt: DateTime.now(),
        isVerified: false,
      );

      await _firestoreService.setUser(user.uid, userModel.toFirestore());
      _userController.add(userModel);
      await _saveUserToLocal(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // 🔑 تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  // ============================================================

  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;
      final userModel = await _getUserFromFirestore(user.uid);
      _userController.add(userModel);
      await _saveUserToLocal(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // 🔑 تسجيل الدخول عبر Google
  // ============================================================

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('تم إلغاء تسجيل الدخول عبر Google');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userDoc = await _firestoreService.getUser(user.uid);
      UserModel userModel;

      if (!userDoc.exists) {
        userModel = UserModel(
          id: user.uid,
          email: user.email,
          name: user.displayName ?? 'مستخدم',
          photoUrl: user.photoURL,
          isPatient: true,
          isDoctor: false,
          createdAt: DateTime.now(),
          isVerified: false,
        );
        await _firestoreService.setUser(user.uid, userModel.toFirestore());
      } else {
        userModel = UserModel.fromFirestore(user.uid, userDoc.data()!);
      }

      _userController.add(userModel);
      await _saveUserToLocal(userModel);
      return userModel;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // 📤 تسجيل الخروج
  // ============================================================

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _userController.add(null);
      await _clearLocalUser();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // 🔄 إعادة تعيين كلمة المرور
  // ============================================================

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // ✏️ تحديث بيانات المستخدم
  // ============================================================

  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      await _firestoreService.updateUser(userModel.id, userModel.toFirestore());
      _userController.add(userModel);
      await _saveUserToLocal(userModel);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ============================================================
  // 📱 تحديث FCM Token
  // ============================================================

  Future<void> updateFCMToken(String token) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;
      await _firestoreService.updateUser(userId, {'fcmToken': token});
    } catch (e) {
      print('⚠️ Error updating FCM token: $e');
    }
  }

  // ============================================================
  // 🔑 الحصول على Firebase ID Token
  // ============================================================

  Future<String> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return await user.getIdToken();
  }

  // ============================================================
  // 📥 الحصول على بيانات المستخدم
  // ============================================================

  Future<UserModel> _getUserFromFirestore(String userId) async {
    final doc = await _firestoreService.getUser(userId);
    if (!doc.exists) {
      throw Exception('User not found in Firestore');
    }
    return UserModel.fromFirestore(userId, doc.data()!);
  }

  // ============================================================
  // 💾 التخزين المحلي
  // ============================================================

  Future<void> _saveUserToLocal(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('user_data', user.toFirestore().toString());
      await prefs.setString('user_id', user.id);
    }
  }

  Future<void> _clearLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_id');
  }

  Future<UserModel?> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) return null;
    try {
      return await _getUserFromFirestore(userId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 🛠️ معالجة الأخطاء
  // ============================================================

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }

  void dispose() {
    _userController.close();
  }
}
