import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithPhone>(_onLoginWithPhone);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<RegisterDoctor>(_onRegisterDoctor);
    on<SendOTP>(_onSendOTP);
    on<VerifyOTP>(_onVerifyOTP);
    on<Logout>(_onLogout);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithEmail(event.email, event.password);
      if (user != null) {
        // ✅ تحديث آخر تسجيل دخول
        await _updateUserLastLogin(user.uid);
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithPhone(LoginWithPhone event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithPhone(event.phone, event.password);
      if (user != null) {
        await _updateUserLastLogin(user.uid);
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الدخول بالهاتف'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithGoogle();
      if (user != null) {
        // ✅ حفظ بيانات المستخدم إذا كانت جديدة
        await _saveUserIfNotExists(user);
        await _updateUserLastLogin(user.uid);
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الدخول بـ Google'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterWithEmail(RegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.registerWithEmail(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      if (user != null) {
        // ✅ حفظ بيانات المستخدم في Firestore
        await _saveUserToFirestore(user, event.name, event.phone);
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل إنشاء الحساب'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterDoctor(RegisterDoctor event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.registerDoctor(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        license: event.license,
        specialty: event.specialty,
      );
      if (user != null) {
        // ✅ حفظ بيانات الطبيب في Firestore
        await _saveDoctorToFirestore(user, event);
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل إنشاء حساب الطبيب'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendOTP(SendOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.sendOTP(event.phone);
      emit(OtpSent(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(VerifyOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.verifyOTP(event.verificationId, event.code);
      if (user != null) {
        await _updateUserLastLogin(user.uid);
        emit(Authenticated(user));
      } else {
        emit(AuthError('رمز التحقق غير صحيح'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ✅ حفظ بيانات المستخدم في Firestore
  Future<void> _saveUserToFirestore(User user, String name, String phone) async {
    try {
      final patientId = 'SH-${DateTime.now().year}-${user.uid.substring(0, 4).toUpperCase()}';
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'phone': phone,
        'photoUrl': user.photoURL ?? '',
        'patientId': patientId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'role': 'patient',
      });
    } catch (e) {
      print('❌ فشل حفظ بيانات المستخدم: $e');
    }
  }

  // ✅ حفظ بيانات الطبيب في Firestore
  Future<void> _saveDoctorToFirestore(User user, RegisterDoctor event) async {
    try {
      await _firestore.collection('doctors').doc(user.uid).set({
        'uid': user.uid,
        'name': event.name,
        'email': user.email ?? '',
        'phone': event.phone,
        'license': event.license,
        'specialty': event.specialty,
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'role': 'doctor',
        'available': true,
        'online': true,
        'rating': 0,
        'reviews': 0,
      });
    } catch (e) {
      print('❌ فشل حفظ بيانات الطبيب: $e');
    }
  }

  // ✅ حفظ بيانات مستخدم Google
  Future<void> _saveUserIfNotExists(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final patientId = 'SH-${DateTime.now().year}-${user.uid.substring(0, 4).toUpperCase()}';
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'مستخدم',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'photoUrl': user.photoURL ?? '',
          'patientId': patientId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'role': 'patient',
        });
      }
    } catch (e) {
      print('❌ فشل حفظ بيانات المستخدم: $e');
    }
  }

  // ✅ تحديث وقت آخر تسجيل دخول
  Future<void> _updateUserLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ فشل تحديث وقت آخر تسجيل دخول: $e');
    }
  }
}
