from pathlib import Path


def replace_once(path: str, old: str, new: str) -> bool:
    p = Path(path)
    text = p.read_text(encoding='utf-8')
    if old not in text:
        return False
    p.write_text(text.replace(old, new, 1), encoding='utf-8')
    return True


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


# لا نُنشئ مسار تنقل ثانياً من authStateChanges؛ GoRouter/Splash/Auth مسؤول عن التنقل.
main = Path('lib/main.dart')
text = main.read_text(encoding='utf-8')
old_listener = """      if (user != null) {
        unawaited(_fcmTokenService.syncCurrentToken());
        unawaited(_navigateAfterSignInFast(user));
      }
"""
new_listener = """      if (user != null) {
        // مزامنة FCM فقط؛ لا نُنشئ مسار تنقل ثانياً أثناء تسجيل الدخول.
        unawaited(_fcmTokenService.syncCurrentToken());
      }
"""
if old_listener in text:
    text = text.replace(old_listener, new_listener, 1)

# لا نفتح SQLite مباشرة عند كل Resume؛ خدمة الوسائط تبدأ نفسها بعد أن تصبح الواجهة جاهزة.
text = text.replace(
    "      unawaited(ChatMediaTransferService.instance.processPending());\n",
    "      // معالجة وسائط الدردشة مؤجلة إلى تهيئة الخدمة الخلفية بعد استقرار الواجهة.\n",
    1,
)
main.write_text(text, encoding='utf-8')

# توحيد انتقال تسجيل الدخول وتصفح الضيف مع GoRouter.
auth = Path('lib/presentation/screens/auth/auth_screen.dart')
text = auth.read_text(encoding='utf-8')
if "package:go_router/go_router.dart" not in text:
    marker = "import 'package:flutter/material.dart';"
    if marker in text:
        text = text.replace(marker, marker + "\nimport 'package:go_router/go_router.dart';", 1)

old_home = """  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }
"""
new_home = """  void _navigateToHome() {
    if (!mounted) return;
    context.go('/');
  }
"""
if old_home in text:
    text = text.replace(old_home, new_home, 1)

old_guest = """  void _guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }
"""
new_guest = """  void _guestLogin() {
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/');
  }
"""
if old_guest in text:
    text = text.replace(old_guest, new_guest, 1)

# إصلاح شاشة التحميل: لا نستخدم Dialog مودال يمكن أن يبقى فوق GoRouter ويمنع الضغط والتنقل.
text, _ = replace_function(
    text,
    '  void _showLoading()',
    """  void _showLoading() {
    if (!mounted) return;
    setState(() => _isLoading = true);
  }""",
)
text, _ = replace_function(
    text,
    '  void _hideLoading()',
    """  void _hideLoading() {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }""",
)

# نجاح الدخول يبقى مرئياً لفترة قصيرة فقط ثم يغلق تلقائياً، فلا يمكن أن يحتجز التنقل.
text, _ = replace_function(
    text,
    '  Future<void> _showSuccessAnimation() async',
    """  Future<void> _showSuccessAnimation() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Material(
          color: Colors.transparent,
          child: Icon(Icons.check_circle, color: Colors.green, size: 80),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }""",
)

# Firebase Auth لا يجوز أن يترك زر الدخول في حالة انتظار لا نهائية عند انقطاع الشبكة.
old_sign_in = """      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );"""
new_sign_in = """      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).timeout(const Duration(seconds: 20));"""
if old_sign_in in text:
    text = text.replace(old_sign_in, new_sign_in, 1)

auth.write_text(text, encoding='utf-8')

print('Startup/auth flow repair applied.')
