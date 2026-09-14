from pathlib import Path


def replace_function(text: str, signature: str, replacement: str) -> tuple[str, bool]:
    start = text.find(signature)
    if start < 0:
        return text, False
    brace = text.find('{', start)
    if brace < 0:
        return text, False
    depth = 0
    in_single = False
    in_double = False
    escaped = False
    for index in range(brace, len(text)):
        char = text[index]
        if escaped:
            escaped = False
            continue
        if char == '\\':
            escaped = True
            continue
        if char == "'" and not in_double:
            in_single = not in_single
            continue
        if char == '"' and not in_single:
            in_double = not in_double
            continue
        if in_single or in_double:
            continue
        if char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
            if depth == 0:
                return text[:start] + replacement + text[index + 1:], True
    return text, False


def main() -> None:
    main_path = Path('lib/main.dart')
    main_text = main_path.read_text(encoding='utf-8')
    old_listener = """      if (user != null) {
        unawaited(_fcmTokenService.syncCurrentToken());
        unawaited(_navigateAfterSignInFast(user));
      }
"""
    new_listener = """      if (user != null) {
        // مزامنة FCM فقط؛ GoRouter هو المسؤول الوحيد عن التنقل.
        unawaited(_fcmTokenService.syncCurrentToken());
      }
"""
    main_text = main_text.replace(old_listener, new_listener, 1)
    main_text, _ = replace_function(main_text, '  Future<void> _navigateAfterSignInFast(User user) async', '')
    main_path.write_text(main_text, encoding='utf-8')

    auth_path = Path('lib/presentation/screens/auth/auth_screen.dart')
    auth_text = auth_path.read_text(encoding='utf-8')
    if not auth_text.startswith("import 'dart:async';"):
        auth_text = "import 'dart:async';\n" + auth_text

    auth_text, changed = replace_function(auth_text, '  Future<void> _login() async', """  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور', true);
      return;
    }

    _showLoading();
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          )
          .timeout(const Duration(seconds: 20));

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-null');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);
      if (_rememberMe) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_uid', user.uid);
        await prefs.setString('remember_email', _emailController.text.trim());
      } else {
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_uid');
        await prefs.remove('remember_email');
      }

      // لا نقرأ users/{uid} هنا ولا نستخدم Navigator/context.go.
      // authStateChanges() سيجعل GoRouter ينتقل إلى Home تلقائياً.
      _hideLoading();
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      String message = 'حدث خطأ في تسجيل الدخول';
      if (e.code == 'user-not-found') {
        message = 'المستخدم غير موجود';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صحيح';
      } else if (e.code == 'network-request-failed') {
        message = 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
      }
      _showMessage(message, true);
    } on TimeoutException {
      _hideLoading();
      _showMessage('انتهت مهلة تسجيل الدخول. تحقق من اتصال الإنترنت وحاول مرة أخرى.', true);
    } catch (_) {
      _hideLoading();
      _showMessage('حدث خطأ غير متوقع أثناء تسجيل الدخول', true);
    }
  }""")
    if not changed:
        raise SystemExit('auth _login function not found; refusing to write partial repair')
    auth_path.write_text(auth_text, encoding='utf-8')


if __name__ == '__main__':
    main()
