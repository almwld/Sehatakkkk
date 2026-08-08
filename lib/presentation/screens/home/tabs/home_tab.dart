// ✅ في _quickServices - استخدام المسارات الصحيحة
final List<Map<String, dynamic>> _quickServices = [
  {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية', 'color': AppColors.success, 'screen': const MedicinesScreen()},
  {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
  {'icon': 'assets/images/services/medical_community.png', 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
  {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
  {'icon': 'assets/images/services/consultation.png', 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
  {'icon': 'assets/images/services/laboratory.png', 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
  {'icon': 'assets/images/services/health_tips.png', 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
  {'icon': 'assets/images/services/wallet.png', 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
  {'icon': 'assets/images/services/medical_records.png', 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
  {'icon': 'assets/images/services/map_location.png', 'label': 'بالقرب منك', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
  {'icon': 'assets/images/services/health_insurance.png', 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
];
