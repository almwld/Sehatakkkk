import re
from pathlib import Path

file_path = "lib/presentation/screens/auth/auth_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# ✅ البحث عن دالة _loginWithGoogle واستبدالها
start = content.find('Future<void> _loginWithGoogle() async {')
end = content.find('Future<void> _login() async {')

if start != -1 and end != -1:
    # ✅ استخراج الدالة الحالية
    old_func = content[start:end]
    
    # ✅ كتابة الدالة الجديدة
    new_func = '''Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    _showLoading();

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        _hideLoading();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw Exception('تعذر الحصول على بيانات حساب Google');
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // ✅ إنشاء مستخدم جديد في Firestore
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
        
        // ✅ تحديث data المحلية بعد الإنشاء
        final newUserDoc = await userRef.get();
        final role = newUserDoc.data()?['role']?.toString() ?? 'user';
        
        _hideLoading();
        await _showSuccessAnimation();

        if (!mounted) return;

        if (role == 'admin' || role == 'superAdmin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PlatformDashboard(),
            ),
          );
        } else {
          _navigateToHome();
        }
        return;
      } else {
        // ✅ تحديث بيانات المستخدم الحالي
        await userRef.set({
          'name': user.displayName ?? googleUser.displayName ?? 'مستخدم',
          'email': user.email ?? googleUser.email,
          'photoUrl': user.photoURL ?? googleUser.photoUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        final role = userDoc.data()?['role']?.toString() ?? 'user';
        
        _hideLoading();
        await _showSuccessAnimation();

        if (!mounted) return;

        if (role == 'admin' || role == 'superAdmin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PlatformDashboard(),
            ),
          );
        } else {
          _navigateToHome();
        }
        return;
      }
    } on FirebaseAuthException catch (e) {
      _hideLoading();

      String message = 'حدث خطأ أثناء تسجيل الدخول عبر Google';

      if (e.code == 'account-exists-with-different-credential') {
        message =
            'هذا البريد مرتبط بطريقة تسجيل دخول أخرى. استخدم طريقة التسجيل الأصلية.';
      } else if (e.code == 'invalid-credential') {
        message = 'بيانات اعتماد Google غير صالحة';
      } else if (e.code == 'network-request-failed') {
        message = 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
      }

      _showMessage(message, true);
    } catch (e) {
      _hideLoading();
      print('❌ Google Sign-In error: $e');
      _showMessage('تعذر تسجيل الدخول عبر Google', true);
    }
  }'''
    
    # ✅ استبدال الدالة
    content = content.replace(old_func, new_func)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ auth_screen.dart - تم إصلاح _loginWithGoogle()")
else:
    print("⚠️ لم يتم العثور على الدالة _loginWithGoogle()")

