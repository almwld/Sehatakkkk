import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_medical_history.dart';
import 'package:sehatak/presentation/screens/patient/patient_prescriptions.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/health_tips/health_tips_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/vaccination/vaccination_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/child_growth/child_growth_screen.dart';
import 'package:sehatak/presentation/screens/drug_dictionary/drug_dictionary_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/bmi_calculator_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/calorie_calculator_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/pregnancy/pregnancy_tracker_screen.dart';
import 'package:sehatak/presentation/screens/symptom_checker/symptom_checker_screen.dart';
import 'package:sehatak/presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/step_counter/step_counter_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
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
            // ========= خدمات سريعة =========
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
                _serviceItem(Icons.local_hospital, 'مستشفيات', AppColors.teal, () {}),
                _serviceItem(Icons.science_rounded, 'مختبرات', AppColors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabsListScreen()))),
                _serviceItem(Icons.shield_moon, 'تأمين', AppColors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceCompanies()))),
                _serviceItem(Icons.local_pharmacy, 'صيدلية', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen()))),
                _serviceItem(Icons.bloodtype, 'بنك الدم', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodDonationScreen()))),
              ],
            ),
            const SizedBox(height: 22),

            // ========= الرعاية الصحية =========
            _sectionTitle('الرعاية الصحية'),
            const SizedBox(height: 10),
            _menuItem(Icons.calendar_month_rounded, 'مواعيدي', 'عرض وإدارة المواعيد', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientAppointments()))),
            _menuItem(Icons.receipt_long, 'الوصفات الطبية', 'عرض الوصفات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientPrescriptions()))),
            _menuItem(Icons.folder_shared, 'السجل الطبي', 'سجل صحي كامل', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientMedicalHistory()))),
            _menuItem(Icons.chat_bubble_rounded, 'استشارات', 'تحدث مع طبيب', () => ChatNavigation.openChat(context, doctorName: 'الطبيب', doctorId: '1')),
            const SizedBox(height: 22),

            // ========= خدمات متخصصة =========
            _sectionTitle('خدمات متخصصة'),
            const SizedBox(height: 10),
            _menuItem(Icons.tips_and_updates, 'نصائح صحية', 'نصائح يومية مفيدة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsScreen()))),
            _menuItem(Icons.pregnant_woman, 'متابعة الحمل', 'أسبوع بأسبوع', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PregnancyTrackerScreen()))),
            _menuItem(Icons.child_care, 'نمو الطفل', 'مراحل التطور', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChildGrowthScreen()))),
            _menuItem(Icons.vaccines, 'سجل التطعيمات', 'تطعيماتك كاملة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationScreen()))),
            const SizedBox(height: 22),

            // ========= أدوات صحية =========
            _sectionTitle('أدوات صحية'),
            const SizedBox(height: 10),
            _menuItem(Icons.medical_services, 'إسعافات أولية', 'دليل الطوارئ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen()))),
            _menuItem(Icons.sick, 'فحص الأعراض', 'حلل أعراضك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomCheckerScreen()))),
            _menuItem(Icons.medication_liquid, 'قاموس الأدوية', 'معلومات الأدوية', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DrugDictionaryScreen()))),
            _menuItem(Icons.monitor_weight, 'حاسبة BMI', 'اعرف وزنك المثالي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BMICalculatorScreen()))),
            _menuItem(Icons.calculate, 'حاسبة السعرات', 'احسب سعرات طعامك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalorieCalculatorScreen()))),
            const SizedBox(height: 22),

            // ========= متابعة صحية =========
            _sectionTitle('متابعة صحية'),
            const SizedBox(height: 10),
            _menuItem(Icons.alarm, 'تذكير الأدوية', 'لا تنس جرعاتك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationReminderScreen()))),
            _menuItem(Icons.bedtime, 'تتبع النوم', 'جودة ومدة نومك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackerScreen()))),
            _menuItem(Icons.directions_walk, 'عداد الخطوات', 'خطواتك اليومية', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StepCounterScreen()))),
            _menuItem(Icons.monitor_heart, 'ضغط الدم', 'تتبع وسجل ضغطك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodPressureScreen()))),
            _menuItem(Icons.monitor_weight_outlined, 'تتبع الوزن', 'وزنك وBMI والهدف', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightTrackerScreen()))),
            _menuItem(Icons.bloodtype_outlined, 'تتبع السكر', 'قراءات الجلوكوز', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlucoseTrackerScreen()))),
            const SizedBox(height: 22),

            // ========= خدمات أخرى =========
            _sectionTitle('خدمات أخرى'),
            const SizedBox(height: 10),
            _menuItem(Icons.description, 'تقارير طبية', 'تقاريرك المخزنة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalReportsScreen()))),
            _menuItem(Icons.psychology, 'صحة نفسية', 'استشارات ودعم نفسي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthScreen()))),
            _menuItem(Icons.favorite_outline, 'أطباء مفضلين', 'قائمة أطبائك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteDoctorsScreen()))),
            const SizedBox(height: 22),

            // ========= عام =========
            _sectionTitle('عام'),
            const SizedBox(height: 10),
            _menuItem(Icons.notifications_active, 'الإشعارات', 'تنبيهاتك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
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
