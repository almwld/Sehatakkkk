import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/screens/health/pulse_camera_screen.dart';
import 'package:sehatak/presentation/screens/health/sleep_tracking_screen.dart';
import 'package:sehatak/presentation/screens/health/steps_tracking_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = [
      _Service('تتبع الخطوات', 'تابع خطواتك اليومية من حساس الحركة', Icons.directions_walk_rounded, () => const StepsTrackingScreen()),
      _Service('تتبع النوم', 'سجل مدة نومك وتابع هدفك اليومي', Icons.bedtime_rounded, () => const SleepTrackingScreen()),
      _Service('قياس النبض بالكاميرا', 'قياس تقديري للنبض باستخدام كاميرا الهاتف', Icons.monitor_heart_outlined, () => const PulseCameraScreen()),
    ];
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'الخدمات الصحية', backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white, foregroundColor: isDark ? Colors.white : Colors.black87, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('تتبع صحتك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 6),
        Text('أدوات صحية عملية داخل تطبيق صحتك', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 18),
        ...services.map((service) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            color: isDark ? const Color(0xFF111B31) : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(16)), child: Icon(service.icon, color: AppColors.primary)),
              title: Text(service.title, style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(service.subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]))),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => service.builder())),
            ),
          ),
        )),
        const SizedBox(height: 10),
        const Text('تنبيه: القياسات الصحية التي تعتمد على الهاتف تقديرية ولا تغني عن الأجهزة الطبية أو التقييم الطبي المتخصص.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }
}

class _Service {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;
  const _Service(this.title, this.subtitle, this.icon, this.builder);
}
