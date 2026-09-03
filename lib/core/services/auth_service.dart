import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // ✅ الحصول على المستخدم من Firestore
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getUserFromFirestore(user.uid);
  }

  Future<UserModel> _getUserFromFirestore(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromFirestore(userId, data);
  }

  // ✅ تسجيل الدخول
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع';
    }
  }

  // ✅ تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ✅ تحديث FCM Token
  Future<void> updateFCMToken(String token) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  // ✅ الحصول على ID Token
  Future<String> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final token = await user.getIdToken();
    return token ?? '';
  }

  // ✅ معالجة الأخطاء
  String _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
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
      default:
        return error.message ?? 'حدث خطأ';
    }
  }
}
