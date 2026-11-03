import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/toast_service.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _t(String value) => AppStrings.of(context).translate(value);
  @override
  void dispose() { _emailController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_t('استعادة كلمة المرور'), style: const TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(_t('أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور'), style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextField(controller: _emailController, decoration: InputDecoration(hintText: _t('البريد الإلكتروني'), prefixIcon: const Icon(Icons.email), border: const OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
            onPressed: () async {
              final email = _emailController.text.trim();
              if (email.isEmpty) { ToastService.showWarning(_t('أدخل بريدك الإلكتروني أولاً')); return; }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                ToastService.showSuccess(_t('تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني'));
                if (mounted) Navigator.pop(context);
              } on FirebaseAuthException catch (e) {
                ToastService.showError(e.message ?? _t('تعذر إرسال رابط إعادة التعيين'));
              } catch (_) { ToastService.showError(_t('تعذر إرسال رابط إعادة التعيين')); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: Text(_t('إرسال')),
          )),
        ]),
      ),
    );
  }
}
