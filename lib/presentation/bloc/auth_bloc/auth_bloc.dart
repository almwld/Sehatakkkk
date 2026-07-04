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

// ============================================================
// 📦 States
// ============================================================
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class OtpSent extends AuthState {
  final String verificationId;
  OtpSent(this.verificationId);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ============================================================
// 🧠 BLoC
// ============================================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricService _biometricService = BiometricService();

  String? _verificationId;

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
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userModel = await _getUserFromFirestore(user.uid);
      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(Unauthenticated());
      }
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
      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(AuthError('بيانات المستخدم غير موجودة'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('حدث خطأ غير متوقع'));
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
      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(AuthError('بيانات المستخدم غير موجودة'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('حدث خطأ غير متوقع'));
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
      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(AuthError('بيانات المستخدم غير موجودة'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('حدث خطأ في تسجيل الدخول بـ Google'));
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
        emit(AuthError('فشل التحقق من البصمة'));
        return;
      }

      final user = _auth.currentUser;
      if (user != null) {
        final userModel = await _getUserFromFirestore(user.uid);
        if (userModel != null) {
          emit(Authenticated(userModel));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('حدث خطأ في البصمة'));
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

      emit(Authenticated(userModel));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('حدث خطأ غير متوقع أثناء إنشاء الحساب'));
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

      emit(Authenticated(userModel));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('حدث خطأ غير متوقع أثناء إنشاء حساب الطبيب'));
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
            if (userModel != null) {
              emit(Authenticated(userModel));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(_getAuthErrorMessage(e)));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          emit(OtpSent(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('حدث خطأ في إرسال رمز التحقق'));
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
      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(AuthError('بيانات المستخدم غير موجودة'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getAuthErrorMessage(e)));
    } catch (e) {
      emit(AuthError('رمز التحقق غير صحيح'));
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
      emit(AuthError('حدث خطأ أثناء تسجيل الخروج'));
    }
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================
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
    } else {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت';
      default:
        return 'حدث خطأ: ${e.message ?? e.code}';
    }
  }
}
