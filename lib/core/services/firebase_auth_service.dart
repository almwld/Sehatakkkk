import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sehatak/core/models/user_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  Future<User?> loginWithEmail(String email, String password) async { try { return (await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim())).user; } on FirebaseAuthException catch (e) { throw _handleAuthError(e); } }
  Future<User?> loginWithPhone(String phone, String password) async { try { return (await _auth.signInWithEmailAndPassword(email: '$phone@sehatak.com', password: password.trim())).user; } on FirebaseAuthException catch (e) { throw _handleAuthError(e); } }
  Future<User?> registerWithEmail(String name, String email, String password, String phone) async { try { final result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim()); await result.user?.updateDisplayName(name); return result.user; } on FirebaseAuthException catch (e) { throw _handleAuthError(e); } }
  Future<User?> registerDoctor(String name, String email, String password, String phone, String specialty, String license) async { try { final result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim()); await result.user?.updateDisplayName('د. $name'); return result.user; } on FirebaseAuthException catch (e) { throw _handleAuthError(e); } }
  Future<User?> loginWithGoogle() async { try { final googleUser = await _googleSignIn.signIn(); if (googleUser == null) return null; final auth = await googleUser.authentication; return (await _auth.signInWithCredential(GoogleAuthProvider.credential(accessToken: auth.accessToken, idToken: auth.idToken))).user; } on FirebaseAuthException catch (e) { throw _handleAuthError(e); } }
  Future<void> sendOTP(String phone) async { await _auth.verifyPhoneNumber(phoneNumber: phone, verificationCompleted: (credential) async { await _auth.signInWithCredential(credential); }, verificationFailed: (e) { throw _handleAuthError(e); }, codeSent: (_, __) {}, codeAutoRetrievalTimeout: (_) {}); }
  Future<User?> verifyOTP(String verificationId, String code) async { try { return (await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code))).user; } on FirebaseAuthException catch (e) { throw _handleAuthError(e); } }
  Future<UserModel?> getCurrentUserModel() async { final user = _auth.currentUser; if (user == null) return null; final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get(); final data = snapshot.data(); if (data == null) return null; return UserModel.fromFirestore(data, snapshot.id); }
  Future<void> logout() async { await _googleSignIn.signOut(); await _auth.signOut(); }
  String _handleAuthError(FirebaseAuthException e) { switch (e.code) { case 'user-not-found': return 'المستخدم غير موجود'; case 'wrong-password': return 'كلمة المرور خاطئة'; case 'email-already-in-use': return 'البريد مستخدم مسبقاً'; case 'invalid-email': return 'بريد إلكتروني غير صحيح'; case 'weak-password': return 'كلمة المرور ضعيفة'; case 'network-request-failed': return 'لا يوجد اتصال بالإنترنت'; case 'too-many-requests': return 'محاولات كثيرة، حاول لاحقاً'; default: return 'حدث خطأ: ${e.message}'; } }
}
