import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_models/user_model.dart';

abstract class AuthEvent extends Equatable { const AuthEvent(); }
class AppStarted extends AuthEvent { @override List<Object?> get props => []; }
class LoginWithEmail extends AuthEvent {
  final String email, password;
  const LoginWithEmail({required this.email, required this.password});
  @override List<Object?> get props => [email, password];
}
class LoginWithGoogle extends AuthEvent { @override List<Object?> get props => []; }
class LoginWithBiometric extends AuthEvent { @override List<Object?> get props => []; }
class RegisterWithEmail extends AuthEvent {
  final String name, email, phone, password;
  const RegisterWithEmail({required this.name, required this.email, required this.phone, required this.password});
  @override List<Object?> get props => [name, email, phone, password];
}
class Logout extends AuthEvent { @override List<Object?> get props => []; }

abstract class AuthState extends Equatable { const AuthState(); }
class AuthInitial extends AuthState { @override List<Object?> get props => []; }
class AuthLoading extends AuthState { @override List<Object?> get props => []; }
class Authenticated extends AuthState { final UserModel user; const Authenticated(this.user); @override List<Object?> get props => [user]; }
class Unauthenticated extends AuthState { @override List<Object?> get props => []; }
class AuthError extends AuthState { final String message; const AuthError(this.message); @override List<Object?> get props => [message]; }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginWithEmail>(_onLogin);
    on<LoginWithGoogle>(_onGoogleLogin);
    on<LoginWithBiometric>(_onBiometricLogin);
    on<RegisterWithEmail>(_onRegister);
    on<Logout>(_onLogout);
  }

  void _onAppStarted(AppStarted e, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(Authenticated(UserModel(id: user.uid, email: user.email, fullName: user.displayName)));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginWithEmail e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: e.email.trim(), password: e.password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', e.email.trim());
      await prefs.setString('saved_password', e.password);
      final u = _auth.currentUser!;
      emit(Authenticated(UserModel(id: u.uid, email: u.email)));
    } on FirebaseAuthException catch (ex) { emit(AuthError(_msg(ex.code))); }
  }

  Future<void> _onGoogleLogin(LoginWithGoogle e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { emit(Unauthenticated()); return; }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCred = await _auth.signInWithCredential(credential);
      if (userCred.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCred.user!.uid).set({
          'id': userCred.user!.uid, 'email': userCred.user!.email,
          'fullName': userCred.user!.displayName ?? '', 'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      final u = userCred.user!;
      emit(Authenticated(UserModel(id: u.uid, email: u.email, fullName: u.displayName, avatar: u.photoURL)));
    } catch (ex) {
      emit(AuthError('فشل تسجيل Google. تأكد من اتصال الإنترنت'));
    }
  }

  Future<void> _onBiometricLogin(LoginWithBiometric e, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    if (email != null && password != null) {
      add(LoginWithEmail(email: email, password: password));
    } else {
      emit(AuthError('لا توجد بيانات محفوظة. سجل دخول أولاً'));
    }
  }

  Future<void> _onRegister(RegisterWithEmail e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: e.email.trim(), password: e.password);
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'id': cred.user!.uid, 'email': e.email, 'phone': e.phone,
        'fullName': e.name, 'role': 'patient', 'createdAt': FieldValue.serverTimestamp(),
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', e.email.trim());
      await prefs.setString('saved_password', e.password);
      emit(Authenticated(UserModel(id: cred.user!.uid, email: e.email, fullName: e.name, phone: e.phone)));
    } on FirebaseAuthException catch (ex) { emit(AuthError(_msg(ex.code))); }
  }

  Future<void> _onLogout(Logout e, Emitter<AuthState> emit) async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    emit(Unauthenticated());
  }

  String _msg(String code) {
    switch (code) {
      case 'user-not-found': return 'المستخدم غير موجود - أنشئ حساباً أولاً';
      case 'wrong-password': return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use': return 'البريد الإلكتروني مسجل مسبقاً';
      case 'weak-password': return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
      case 'invalid-email': return 'بريد إلكتروني غير صالح';
      default: return code;
    }
  }
}
