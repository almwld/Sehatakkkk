import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_models/user_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 🔐 تسجيل الدخول بالبريد
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 📱 تسجيل الدخول بالهاتف
  Future<User?> loginWithPhone(String phone, String password) async {
    try {
      // محاكاة تسجيل الدخول بالهاتف
      final result = await _auth.signInWithEmailAndPassword(
        email: '$phone@sehatak.com',
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 📝 إنشاء حساب مستخدم
  Future<User?> registerWithEmail(String name, String email, String password, String phone) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await result.user!.updateDisplayName(name);
      await result.user!.updatePhotoURL('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00796B&color=fff');
      await result.user!.reload();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 👨‍⚕️ تسجيل طبيب
  Future<User?> registerDoctor(
    String name,
    String email,
    String password,
    String phone,
    String specialty,
    String license,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await result.user!.updateDisplayName('د. $name');
      await result.user!.updatePhotoURL('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00796B&color=fff');
      await result.user!.reload();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 🍎 Google Sign-In
  Future<User?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 📱 إرسال OTP
  Future<void> sendOTP(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (cred) async {
          await _auth.signInWithCredential(cred);
        },
        verificationFailed: (e) {
          throw _handleAuthError(e);
        },
        codeSent: (verificationId, forceResendingToken) {
          // حفظ verificationId للاستخدام
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 🔑 التحقق من OTP
  Future<User?> verifyOTP(String verificationId, String code) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // 👤 تسجيل خروج
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ❌ معالجة الأخطاء
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'المستخدم غير موجود';
      case 'wrong-password': return 'كلمة المرور خاطئة';
      case 'email-already-in-use': return 'البريد مستخدم مسبقاً';
      case 'invalid-email': return 'بريد إلكتروني غير صحيح';
      case 'weak-password': return 'كلمة المرور ضعيفة';
      case 'network-request-failed': return 'لا يوجد اتصال بالإنترنت';
      case 'too-many-requests': return 'محاولات كثيرة، حاول لاحقاً';
      default: return 'حدث خطأ: ${e.message}';
    }
  }
}
