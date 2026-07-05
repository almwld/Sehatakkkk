import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sehatak/core/services/biometric_service.dart';
import 'package:sehatak/data/models/user_models/user_model.dart';

// ============================================================
// 📦 Events
// ============================================================
abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  LoginWithEmail({required this.email, required this.password});
}

class LoginWithPhone extends AuthEvent {
  final String phone;
  final String password;
  LoginWithPhone({required this.phone, required this.password});
}

class LoginWithGoogle extends AuthEvent {
  LoginWithGoogle();
}

class LoginWithBiometric extends AuthEvent {
  LoginWithBiometric();
}

class RegisterWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  RegisterWithEmail({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class RegisterDoctor extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  RegisterDoctor({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class SendOtp extends AuthEvent {
  final String phone;
  SendOtp({required this.phone});
}

class VerifyOtp extends AuthEvent {
  final String verificationId;
  final String otp;
  VerifyOtp({required this.verificationId, required this.otp});
}

class Logout extends AuthEvent {
  Logout();
}

class ResetPassword extends AuthEvent {
  final String email;
  ResetPassword({required this.email});
}

// ============================================================
// 📦 States
// ============================================================
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel? user;
  Authenticated({this.user});
}

class Unauthenticated extends AuthState {}

class OtpSent extends AuthState {
  final String verificationId;
  OtpSent(this.verificationId);
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

// ============================================================
// 🧠 BLoC
// ============================================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricService _biometricService = BiometricService();

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithPhone>(_onLoginWithPhone);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithBiometric>(_onLoginWithBiometric);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<RegisterDoctor>(_onRegisterDoctor);
    on<SendOtp>(_onSendOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<Logout>(_onLogout);
    on<ResetPassword>(_onResetPassword);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userModel = await _getUserFromFirestore(user.uid);
      emit(Authenticated(user: userModel));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      final userModel = await _getUserFromFirestore(credential.user!.uid);
      emit(Authenticated(user: userModel));
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في تسجيل الدخول'));
    }
  }

  Future<void> _onLoginWithPhone(
    LoginWithPhone event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: event.phone.trim() + '@sehatak.com',
        password: event.password.trim(),
      );
      final userModel = await _getUserFromFirestore(credential.user!.uid);
      emit(Authenticated(user: userModel));
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في تسجيل الدخول'));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(Unauthenticated());
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      await _saveOrUpdateUser(user);
      final userModel = await _getUserFromFirestore(user.uid);
      emit(Authenticated(user: userModel));
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في تسجيل الدخول بـ Google'));
    }
  }

  Future<void> _onLoginWithBiometric(
    LoginWithBiometric event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authenticated = await _biometricService.authenticate(
        reason: 'تسجيل الدخول باستخدام البصمة',
      );
      if (!authenticated) {
        emit(AuthError(message: 'فشل التحقق من البصمة'));
        return;
      }
      final user = _auth.currentUser;
      if (user != null) {
        final userModel = await _getUserFromFirestore(user.uid);
        emit(Authenticated(user: userModel));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في البصمة'));
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      final user = credential.user!;
      await user.updateDisplayName(event.name.trim());
      final userModel = UserModel(
        uid: user.uid,
        name: event.name.trim(),
        email: event.email.trim(),
        phone: event.phone.trim(),
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      emit(Authenticated(user: userModel));
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في إنشاء الحساب'));
    }
  }

  Future<void> _onRegisterDoctor(
    RegisterDoctor event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      final user = credential.user!;
      await user.updateDisplayName(event.name.trim());
      final userModel = UserModel(
        uid: user.uid,
        name: event.name.trim(),
        email: event.email.trim(),
        phone: event.phone.trim(),
        role: 'doctor',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      emit(Authenticated(user: userModel));
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في إنشاء حساب الطبيب'));
    }
  }

  Future<void> _onSendOtp(
    SendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: event.phone.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          final user = _auth.currentUser;
          if (user != null) {
            final userModel = await _getUserFromFirestore(user.uid);
            emit(Authenticated(user: userModel));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(message: e.message ?? 'فشل إرسال الرمز'));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(OtpSent(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في إرسال الرمز'));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otp.trim(),
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final userModel = await _getUserFromFirestore(user.uid);
      emit(Authenticated(user: userModel));
    } catch (e) {
      emit(AuthError(message: 'رمز التحقق غير صحيح'));
    }
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في تسجيل الخروج'));
    }
  }

  Future<void> _onResetPassword(
    ResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: event.email.trim());
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'حدث خطأ في إرسال رابط الاستعادة'));
    }
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveOrUpdateUser(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final userModel = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        photoUrl: user.photoURL,
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
    }
  }
}
