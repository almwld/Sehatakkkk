import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';

/// Canonical icon-only quick services section used by HomeTab.
/// Navigation is delegated to the parent so Home remains the single
/// navigation owner and no second routing system is introduced.
class QuickServicesWidget extends StatelessWidget {
  final bool isDark;
  final ValueChanged<Widget> onNavigate;

  const QuickServicesWidget({
    super.key,
    required this.isDark,
    required this.onNavigate,
  });

  static const List<Map<String, dynamic>> _services = [
    {
      'icon': 'assets/images/services/pharmacy.png',
      'label': 'صيدلية',
      'screen': PharmacyScreen.new,
    },
    {
      'icon': 'assets/images/services/emergency.png',
      'label': 'طوارئ',
      'screen': EmergencyNumbers.new,
    },
    {
      'icon': 'assets/images/services/medical_community.png',
      'label': 'خدمات منزلية',
      'screen': ServicesScreen.new,
    },
    {
      'icon': 'assets/images/services/blood_donation.png',
      'label': 'تبرع بالدم',
      'screen': BloodDonationScreen.new,
    },
    {
      'icon': 'assets/images/services/consultation.png',
      'label': 'أطباء',
      'screen': DoctorsListScreen.new,
    },
    {
      'icon': 'assets/images/services/laboratory.png',
      'label': 'مختبرات',
      'screen': LabsListScreen.new,
    },
    {
      'icon': 'assets/images/services/health_tips.png',
      'label': 'صحة',
      'screen': HealthDashboard.new,
    },
    {
      'icon': 'assets/images/services/wallet.png',
      'label': 'محفظة',
      'screen': WalletScreen.new,
    },
    {
      'icon': 'assets/images/services/consultation.png',
      'label': 'استشارة',
      'screen': ConsultationScreen.new,
    },
    {
      'icon': 'assets/images/services/map_location.png',
      'label': 'بالقرب منك',
      'screen': InteractiveMapScreen.new,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 0),
        itemBuilder: (context, index) => _buildServiceItem(
          context,
          _services[index],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final builder = service['screen'] as Widget Function();
        onNavigate(builder());
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              service['icon'] as String,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 44,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              service['label'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
