from pathlib import Path
import re

AUTH = Path('lib/presentation/screens/auth/auth_screen.dart')
SPLASH = Path('lib/presentation/screens/splash_screen.dart')

auth = AUTH.read_text(encoding='utf-8')
splash = SPLASH.read_text(encoding='utf-8')

# Requested icon geometry.
auth = auth.replace('containerSize: 48,\n                      iconSize: 34,\n                      padding: 6,', 'containerSize: 40,\n                      iconSize: 34,\n                      padding: 3,')
auth = auth.replace('containerSize: 40,\n                      iconSize: 24,\n                      padding: 7,', 'containerSize: 32,\n                      iconSize: 24,\n                      padding: 4,')

# Time-aware login greeting.
old_title = """isSignUp
                      ? 'إنشاء حساب جديد'
                      : (_isFirstTimeUser
                          ? 'أهلاً بك في منصة صحتك'
                          : 'مرحباً بعودتك'),"""
new_title = """isSignUp
                      ? 'إنشاء حساب جديد'
                      : _getGreetingTitle(),"""
if old_title in auth:
    auth = auth.replace(old_title, new_title, 1)

marker = '  void _showLoading() {'
if 'String _getGreetingTitle()' not in auth:
    methods = '''  String _getGreetingTitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح الخير، مرحباً بعودتك';
    if (hour >= 12 && hour < 18) return 'مساء الخير، مرحباً بعودتك';
    if (hour >= 18 && hour < 24) return 'مساء الخير، مرحباً بعودتك';
    return 'ليلة هادئة، مرحباً بعودتك';
  }

  String _getGreetingSubtitle() {
    return 'سجّل دخولك مجدداً إلى منصة صحتك';
  }

'''
    if marker not in auth:
        raise SystemExit('Auth loading marker not found')
    auth = auth.replace(marker, methods + marker, 1)

if '_getGreetingSubtitle()' not in auth:
    pattern = re.compile(r"(Text\(\s*isSignUp\s*\? 'إنشاء حساب جديد'\s*:\s*_getGreetingTitle\(\),.*?\n\s*\),\n\s*const SizedBox\(height: 8\),)", re.S)
    m = pattern.search(auth)
    if not m:
        raise SystemExit('Greeting title widget anchor not found')
    block = m.group(1)
    replacement = block.replace(
        'const SizedBox(height: 8),',
        "const SizedBox(height: 8),\n                if (!isSignUp)\n                  Text(\n                    _getGreetingSubtitle(),\n                    style: TextStyle(\n                      fontSize: 14,\n                      color: isDark ? Colors.white70 : Colors.grey[600],\n                      fontFamily: 'NotoSansArabicUI',\n                    ),\n                    textAlign: TextAlign.center,\n                  ),\n                const SizedBox(height: 12),",
        1,
    )
    auth = auth[:m.start(1)] + replacement + auth[m.end(1):]

# Google: signup creates the account, signs out, then returns to login;
# login signs into the existing account and goes to Home.
start = auth.find('  Future<void> _loginWithGoogle() async {')
end = auth.find('  Future<void> _login() async {')
if start < 0 or end <= start:
    raise SystemExit('Google function anchors not found')
new_google = '''  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    _showLoading();

    try {
      final google = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await google.signIn();
      if (googleUser == null) {
        _hideLoading();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user == null) throw Exception('تعذر الحصول على حساب Google');

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final existing = await userRef.get();

      if (widget.isSignUp) {
        if (existing.exists) {
          await FirebaseAuth.instance.signOut();
          await google.signOut();
          _hideLoading();
          if (mounted) {
            setState(() => _isLoading = false);
            ToastService.showError('حساب Google هذا مسجل مسبقاً. سجّل الدخول من صفحة الدخول.');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen(isSignUp: false)),
            );
          }
          return;
        }

        await userRef.set({
          'uid': user.uid,
          'name': user.displayName ?? googleUser.displayName ?? 'مستخدم',
          'email': user.email ?? googleUser.email,
          'phone': user.phoneNumber ?? '',
          'role': 'user',
          'specialty': null,
          'licenseNumber': '',
          'experience': '',
          'isVerified': false,
          'verificationStatus': 'notSubmitted',
          'rating': 0.0,
          'reviewCount': 0,
          'isAvailable': true,
          'photoUrl': user.photoURL ?? googleUser.photoUrl ?? '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await FirebaseAuth.instance.signOut();
        await google.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', false);
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_uid');

        _hideLoading();
        if (mounted) {
          setState(() => _isLoading = false);
          ToastService.showSuccess('تم إنشاء حساب Google بنجاح. اضغط Google في صفحة الدخول للمتابعة.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen(isSignUp: false)),
          );
        }
        return;
      }

      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? googleUser.displayName ?? 'مستخدم',
        'email': user.email ?? googleUser.email,
        'photoUrl': user.photoURL ?? googleUser.photoUrl ?? '',
        'provider': 'google',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final role = existing.data()?['role']?.toString() ?? 'user';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', true);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_uid', user.uid);

      _hideLoading();
      if (mounted) setState(() => _isLoading = false);
      await _showSuccessAnimation();
      if (!mounted) return;

      if (role == 'admin' || role == 'superAdmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PlatformDashboard()),
        );
      } else {
        _navigateToHome();
      }
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      if (mounted) setState(() => _isLoading = false);
      var message = 'حدث خطأ أثناء تسجيل الدخول عبر Google';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'هذا البريد مرتبط بطريقة تسجيل دخول أخرى. استخدم طريقة التسجيل الأصلية.';
      } else if (e.code == 'invalid-credential') {
        message = 'بيانات اعتماد Google غير صالحة';
      } else if (e.code == 'network-request-failed') {
        message = 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
      }
      ToastService.showError(message);
    } catch (e) {
      _hideLoading();
      if (mounted) setState(() => _isLoading = false);
      ToastService.showError('تعذر إكمال عملية Google: $e');
    }
  }

'''
auth = auth[:start] + new_google + auth[end:]

old_login = '''      await prefs.setBool('remember_me', _rememberMe);

      if (_rememberMe) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString(
          'remember_email',
          _emailController.text.trim(),
        );
      } else {
        await prefs.setBool('is_logged_in', false);
      }'''
new_login = '''      await prefs.setBool('remember_me', _rememberMe);

      if (_rememberMe) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_uid', FirebaseAuth.instance.currentUser?.uid ?? '');
        await prefs.setString('remember_email', _emailController.text.trim());
      } else {
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_uid');
        await prefs.remove('remember_email');
      }'''
if old_login in auth:
    auth = auth.replace(old_login, new_login, 1)
else:
    raise SystemExit('Remember-me anchor not found')

old_bio = '''    if (authenticated) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await _showSuccessAnimation();

        if (mounted) {
          _navigateToHome();
        }
      } else {
        _showMessage('يرجى تسجيل الدخول أولاً', true);
      }'''
new_bio = '''    if (authenticated) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', true);
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_uid', user.uid);
        await _showSuccessAnimation();

        if (mounted) {
          _navigateToHome();
        }
      } else {
        ToastService.showError('لا توجد جلسة حساب محفوظة. سجّل الدخول مرة واحدة ثم استخدم البصمة.');
      }'''
if old_bio in auth:
    auth = auth.replace(old_bio, new_bio, 1)

AUTH.write_text(auth, encoding='utf-8')

old_status = "      final bool isUserLoggedIn = user != null && isLoggedInPrefs && user.uid == savedUid;"
new_status = "      final rememberMe = prefs.getBool('remember_me') ?? false;\n      final bool isUserLoggedIn = user != null && rememberMe && isLoggedInPrefs && user.uid == savedUid;"
if old_status in splash:
    splash = splash.replace(old_status, new_status, 1)
else:
    raise SystemExit('Splash status anchor not found')

old_persist = '''      if (user != null) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_uid', user.uid);
      } else {
        await prefs.setBool('is_logged_in', false);
      }'''
new_persist = '''      if (user != null && rememberMe) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_uid', user.uid);
      } else if (user != null && !rememberMe) {
        await FirebaseAuth.instance.signOut();
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_uid');
      } else {
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_uid');
      }'''
if old_persist in splash:
    splash = splash.replace(old_persist, new_persist, 1)
else:
    raise SystemExit('Splash persistence anchor not found')

old_delay = '''      // ✅ الانتظار 9 ثواني كاملة لعرض شاشة البداية
      await Future.delayed(const Duration(seconds: 9));

      if (mounted) {
        _navigateToNext();
      }'''
new_delay = '''      // الجلسة المحفوظة تتجاوز Splash وAuth مباشرة إلى Home.
      if (_isLoggedIn) {
        if (mounted) _navigateToNext();
        return;
      }

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) _navigateToNext();'''
if old_delay in splash:
    splash = splash.replace(old_delay, new_delay, 1)
else:
    raise SystemExit('Splash delay anchor not found')

SPLASH.write_text(splash, encoding='utf-8')
print('Auth production migration completed.')
