import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/toast_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('استعادة كلمة المرور', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    ToastService.showWarning('أدخل بريدك الإلكتروني أولاً');
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    ToastService.showSuccess('تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني');
                    if (mounted) Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    ToastService.showError(e.message ?? 'تعذر إرسال رابط إعادة التعيين');
                  } catch (_) {
                    ToastService.showError('تعذر إرسال رابط إعادة التعيين');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إرسال'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
