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
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';
import 'package:sehatak/presentation/screens/appointments/appointments_screen.dart';
import 'package:sehatak/presentation/screens/reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_tests_screen.dart';
import 'package:sehatak/presentation/screens/vaccination/vaccination_screen.dart';
import 'package:sehatak/presentation/screens/medication/medications_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/diet/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/exercise/exercise_plan_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/consultation/video_consult_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المزيد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الخريطة التفاعلية
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الخريطة التفاعلية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '240 موقع صحي في صنعاء',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InteractiveMapScreen(type: 'hospitals'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('استعراض'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الباقات والاشتراكات
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الباقات والاشتراكات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'خطط اشتراك تناسب احتياجاتك',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('استعراض'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ✅ خدمات سريعة
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

            // ✅ الرعاية الصحية
            _sectionTitle('الرعاية الصحية'),
            const SizedBox(height: 10),
            _menuItem(context, Icons.calendar_month_rounded, 'مواعيدي', 'عرض وإدارة المواعيد', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()))),
            _menuItem(context, Icons.receipt_long, 'الوصفات الطبية', 'عرض الوصفات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientPrescriptions()))),
            _menuItem(context, Icons.folder_shared, 'السجل الطبي', 'سجل صحي كامل', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientMedicalHistory()))),
            _menuItem(context, Icons.chat_bubble_rounded, 'استشارات', 'تحدث مع طبيب', () => ChatNavigation.openChat(context, doctorName: 'الطبيب', doctorId: '1')),
            _menuItem(context, Icons.videocam, 'استشارة فيديو', 'مكالمة مباشرة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoConsultScreen()))),
            const SizedBox(height: 22),

            // ✅ الخدمات الطبية
            _sectionTitle('الخدمات الطبية'),
            const SizedBox(height: 10),
            _menuItem(context, Icons.medical_information, 'التقارير الطبية', 'عرض التقارير', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalReportsScreen()))),
            _menuItem(context, Icons.science, 'التحاليل', 'قائمة التحاليل', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabTestsScreen()))),
            _menuItem(context, Icons.vaccines, 'التطعيمات', 'سجل التطعيمات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationScreen()))),
            _menuItem(context, Icons.medication, 'الأدوية', 'قائمة الأدوية', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationsScreen()))),
            const SizedBox(height: 22),

            // ✅ أدوات صحية
            _sectionTitle('أدوات صحية'),
            const SizedBox(height: 10),
            _menuItem(context, Icons.psychology, 'الصحة النفسية', 'دعم نفسي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthScreen()))),
            _menuItem(context, Icons.medical_services, 'إسعافات أولية', 'دليل الطوارئ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen()))),
            _menuItem(context, Icons.restaurant_menu, 'نظام غذائي', 'خطة غذائية', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DietPlanScreen()))),
            _menuItem(context, Icons.fitness_center, 'تمارين رياضية', 'خطة تمارين', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisePlanScreen()))),
            _menuItem(context, Icons.tips_and_updates, 'نصائح صحية', 'نصائح يومية مفيدة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsScreen()))),
            _menuItem(context, Icons.alarm, 'تذكير الأدوية', 'لا تنس جرعاتك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationReminderScreen()))),
            const SizedBox(height: 22),

            // ✅ عام
            _sectionTitle('عام'),
            const SizedBox(height: 10),
            _menuItem(context, Icons.settings_rounded, 'الإعدادات', 'تفضيلات التطبيق', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            _menuItem(context, Icons.info_outline, 'عن التطبيق', 'معلومات عن صحتك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
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

  Widget _menuItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
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
