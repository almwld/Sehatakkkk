// ============================================================
// 🏠 HomeScreen - الخدمات السريعة مع صور حقيقية
// ============================================================

// ✅ بدلاً من Icon(Icons.xxx) استخدم Image.asset()

final List<Map<String, dynamic>> _quickServices = [
  {'icon': 'assets/icons/services/أطباء.png', 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
  {'icon': 'assets/icons/services/ادويه.png', 'label': 'صيدلية', 'color': AppColors.success, 'screen': const PharmacyScreen()},
  {'icon': 'assets/icons/services/مخابر.png', 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
  {'icon': 'assets/icons/services/بالقرب مني .png', 'label': 'بالقرب منك', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
  {'icon': 'assets/icons/services/تامين.png', 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
  {'icon': 'assets/icons/services/تقييم.png', 'label': 'تقييم', 'color': Colors.amber, 'screen': const HealthDashboard()},
  {'icon': 'assets/icons/services/صحةالقلب.png', 'label': 'صحة القلب', 'color': AppColors.pink, 'screen': const HealthDashboard()},
  {'icon': 'assets/icons/services/طبيبك.png', 'label': 'طبيبك', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
  {'icon': 'assets/icons/services/محادثات للمعارف.png', 'label': 'محادثات', 'color': AppColors.info, 'screen': const ConsultationScreen()},
  {'icon': 'assets/icons/services/محفظ.png', 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
  {'icon': 'assets/icons/services/مراسلات.png', 'label': 'مراسلات', 'color': AppColors.purple, 'screen': const ChatScreen()},
  {'icon': 'assets/icons/services/مواعيد.png', 'label': 'مواعيد', 'color': AppColors.primaryDark, 'screen': const PatientAppointments()},
];
