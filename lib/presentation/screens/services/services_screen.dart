import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import '../doctor/doctors_list_screen.dart';
import '../pharmacy/pharmacy_screen.dart';
import '../lab/labs_list_screen.dart';
import '../map/interactive_map_screen.dart';
import '../emergencies/emergency_numbers.dart';
import '../health/health_dashboard.dart';
import '../payment/wallet_screen.dart';
import '../consultation/consultation_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final List<Map<String, dynamic>> _services = const [
    {
      'icon': Icons.medical_services_rounded,
      'title': 'الأطباء',
      'subtitle': 'استشر أفضل الأطباء',
      'color': AppColors.primary,
      'screen': DoctorsListScreen(),
    },
    {
      'icon': Icons.local_pharmacy_rounded,
      'title': 'الصيدلية',
      'subtitle': 'اطلب أدويتك',
      'color': AppColors.success,
      'screen': PharmacyScreen(),
    },
    {
      'icon': Icons.science_rounded,
      'title': 'المختبرات',
      'subtitle': 'تحاليل دقيقة',
      'color': AppColors.purple,
      'screen': LabsListScreen(),
    },
    {
      'icon': Icons.map_rounded,
      'title': 'المرافق الصحية',
      'subtitle': 'ابحث عن أقرب مرافق',
      'color': AppColors.info,
      'screen': InteractiveMapScreen(),
    },
    {
      'icon': Icons.emergency_rounded,
      'title': 'الطوارئ',
      'subtitle': 'خدمات طوارئ 24/7',
      'color': AppColors.error,
      'screen': EmergencyNumbers(),
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'الصحة',
      'subtitle': 'متابعة صحتك',
      'color': AppColors.pink,
      'screen': HealthDashboard(),
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'المحفظة',
      'subtitle': 'إدارة رصيدك',
      'color': AppColors.amber,
      'screen': WalletScreen(),
    },
    {
      'icon': Icons.chat_rounded,
      'title': 'استشارات',
      'subtitle': 'استشارة فورية',
      'color': AppColors.teal,
      'screen': ConsultationScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text(
          'الخدمات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return _buildServiceCard(context, service);
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final color = service['color'] as Color;
    final icon = service['icon'] as IconData;
    final title = service['title'] as String;
    final subtitle = service['subtitle'] as String;
    final screen = service['screen'] as Widget;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
