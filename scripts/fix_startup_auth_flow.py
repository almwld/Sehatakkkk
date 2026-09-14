from pathlib import Path


def replace_once(path: str, old: str, new: str) -> bool:
    p = Path(path)
    text = p.read_text(encoding='utf-8')
    if old not in text:
        return False
    p.write_text(text.replace(old, new, 1), encoding='utf-8')
    return True

# إصلاح نقطة التعارض الأساسية: لا ننتقل إلى Home من مستمع authStateChanges.
# GoRouter/Splash/Auth هو المسؤول عن الانتقال، بينما المستمع يزامن الخدمات فقط.
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
main.write_text(text, encoding='utf-8')

# توحيد انتقال تسجيل الدخول وتصفح الضيف مع GoRouter حتى لا يحدث تكديس
# بين Navigator وGoRouter أو إعادة بناء شاشة Auth بعد تسجيل الدخول.
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
    context.go('/');
  }
"""
if old_guest in text:
    text = text.replace(old_guest, new_guest, 1)

auth.write_text(text, encoding='utf-8')

print('Startup/auth flow repair applied.')
