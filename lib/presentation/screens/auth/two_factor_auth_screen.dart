import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});
  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'المصادقة الثنائية'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 40),
          Icon(_enabled ? Icons.shield : Icons.shield_outlined, size: 80, color: _enabled ? AppColors.success : Colors.grey),
          const SizedBox(height: 24),
          Text(_enabled ? 'المصادقة الثنائية مفعلة' : 'المصادقة الثنائية غير مفعلة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('حماية إضافية لحسابك', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 40),
          SwitchListTile(title: 'تفعيل المصادقة الثنائية', subtitle: 'رمز تحقق إضافي عند تسجيل الدخول', value: _enabled, activeColor: AppColors.primary, onChanged: (v) => setState(() => _enabled = v)),
        ]),
      ),
    );
  }
}
