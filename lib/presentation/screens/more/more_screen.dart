import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/screens/patient/patient_medical_history.dart';
import 'package:sehatak/presentation/screens/patient/patient_prescriptions.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/health_tips/health_tips_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/favorites/favorite_doctors_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('خدمات سريعة'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _serviceItem(Icons.emergency_share, 'الطوارئ', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyNumbers()))),
                _serviceItem(Icons.science_rounded, 'مختبرات', AppColors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabsListScreen()))),
                _serviceItem(Icons.shield_moon, 'تأمين', AppColors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceCompanies()))),
                _serviceItem(Icons.favorite_outline, 'أطباء مفضلين', AppColors.pink, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteDoctorsScreen()))),
              ],
            ),
            const SizedBox(height: 22),
            _sectionTitle('الرعاية الصحية'),
            const SizedBox(height: 10),
            _menuItem(Icons.calendar_month_rounded, 'مواعيدي', 'عرض وإدارة المواعيد', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientAppointments()))),
            _menuItem(Icons.receipt_long, 'الوصفات الطبية', 'عرض الوصفات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientPrescriptions()))),
            _menuItem(Icons.folder_shared, 'السجل الطبي', 'سجل صحي كامل', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientMedicalHistory()))),
            _menuItem(Icons.chat_bubble_rounded, 'استشارات', 'تحدث مع طبيب', () => ChatNavigation.openChat(context, doctorName: 'الطبيب', doctorId: '1')),
            const SizedBox(height: 22),
            _sectionTitle('أدوات صحية'),
            const SizedBox(height: 10),
            _menuItem(Icons.tips_and_updates, 'نصائح صحية', 'نصائح يومية مفيدة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsScreen()))),
            _menuItem(Icons.alarm, 'تذكير الأدوية', 'لا تنس جرعاتك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationReminderScreen()))),
            const SizedBox(height: 22),
            _sectionTitle('عام'),
            const SizedBox(height: 10),
            _menuItem(Icons.settings_rounded, 'الإعدادات', 'تفضيلات التطبيق', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            _menuItem(Icons.info_outline, 'عن التطبيق', 'معلومات عن صحتك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _serviceItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 5),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
        trailing: const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.grey),
        onTap: onTap,
      ),
    );
  }
}
