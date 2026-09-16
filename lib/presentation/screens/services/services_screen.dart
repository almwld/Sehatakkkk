import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/app_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = <_ServiceItem>[
      _ServiceItem('😴', 'تتبع النوم', 'تسجيل ومتابعة النوم والإحصائيات الأسبوعية', AppRouter.sleepTracker),
      _ServiceItem('👟', 'تتبع الخطوات', 'الخطوات والمسافة والسعرات والنشاط الأسبوعي', AppRouter.stepTracker),
      _ServiceItem('🚚', 'خدمة التوصيل', 'اختيار خدمة وشركات التوصيل المتاحة', AppRouter.delivery),
      _ServiceItem('🏢', 'شركات التوصيل', 'عرض الشركات المتاحة حسب المنطقة والمسافة', AppRouter.deliveryCompanies),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'جميع الخدمات',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final item = services[index];
          return Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (item.route == AppRouter.deliveryCompanies) {
                  context.push(item.route, extra: <String, dynamic>{'area': '', 'distance': 5.0});
                } else {
                  context.push(item.route);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 38)),
                    const SizedBox(height: 12),
                    Text(item.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Text(item.subtitle, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(height: 10),
                    Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceItem {
  final String icon;
  final String title;
  final String subtitle;
  final String route;
  const _ServiceItem(this.icon, this.title, this.subtitle, this.route);
}
