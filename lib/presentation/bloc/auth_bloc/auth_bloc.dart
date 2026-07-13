// ✅ إضافة هذا السطر في _onCheckAuthStatus
Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
  final prefs = await SharedPreferences.getInstance();
  final rememberMe = prefs.getBool('remember_me') ?? false;
  
  if (!rememberMe) {
    emit(Unauthenticated());
    return;
  }
  
  final user = _auth.currentUser;
  if (user != null) {
    final userModel = await _getUserFromFirestore(user.uid);
    emit(Authenticated(user: userModel));
  } else {
    emit(Unauthenticated());
  }
}
