import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/health/child_health_screen.dart';
import 'package:sehatak/presentation/screens/health/womens_health_screen.dart';
import 'package:sehatak/presentation/screens/health/pregnancy_follow_up_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/dental_care/dental_care_screen.dart';
import 'package:sehatak/presentation/screens/eye_care/eye_care_screen.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/step_tracker/step_tracker_screen.dart';
import 'package:sehatak/presentation/screens/sleep/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/heart_rate/heart_rate_screen.dart';

class MoreScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const MoreScreen({super.key, this.scrollController});
  @override State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;
  String _category = 'الكل';

  final List<Map<String, dynamic>> _vitals = [
    {'label': 'ضغط الدم', 'value': '120/80', 'unit': 'مم زئبق', 'icon': Icons.monitor_heart_rounded, 'screen': const BloodPressureScreen()},
    {'label': 'سكر الدم', 'value': '98', 'unit': 'مجم/دل', 'icon': Icons.bloodtype_rounded, 'screen': const GlucoseTrackerScreen()},
    {'label': 'اللياقة', 'value': '85', 'unit': '%', 'icon': Icons.directions_walk_rounded, 'screen': const StepTrackerScreen()},
    {'label': 'الوزن', 'value': '72', 'unit': 'كجم', 'icon': Icons.monitor_weight_rounded, 'screen': const WeightTrackerScreen()},
    {'label': 'النوم', 'value': '7.5', 'unit': 'ساعات', 'icon': Icons.bedtime_rounded, 'screen': const SleepTrackerScreen()},
    {'label': 'النبض', 'value': '--', 'unit': 'BPM', 'icon': Icons.favorite_rounded, 'screen': const HeartRateScreen()},
    {'label': 'الماء', 'value': '6', 'unit': 'أكواب', 'icon': Icons.water_drop_rounded, 'screen': const HealthDashboard()},
  ];

  final List<Map<String, dynamic>> _services = [
    {'title': 'صحة الأسنان', 'subtitle': 'فحوصات وخدمات الأسنان', 'icon': Icons.health_and_safety_rounded, 'category': 'خدمات طبية', 'screen': const DentalCareScreen()},
    {'title': 'صحة العين', 'subtitle': 'اختبارات النظر والعناية بالعين', 'icon': Icons.visibility_rounded, 'category': 'خدمات طبية', 'screen': const EyeCareScreen()},
    {'title': 'الأطباء', 'subtitle': 'البحث والحجز مع الأطباء', 'icon': Icons.person_search_rounded, 'category': 'خدمات طبية', 'screen': const DoctorsListScreen()},
    {'title': 'الصيدلية', 'subtitle': 'الأدوية والصيدليات', 'icon': Icons.local_pharmacy_rounded, 'category': 'لوجستيات وتأمين', 'screen': const PharmacyScreen()},
    {'title': 'المختبرات', 'subtitle': 'التحاليل والفحوصات', 'icon': Icons.science_rounded, 'category': 'لوجستيات وتأمين', 'screen': const LabsListScreen()},
    {'title': 'الباقات والاشتراكات', 'subtitle': 'عرض الباقات والدفع', 'icon': Icons.card_membership_rounded, 'category': 'لوجستيات وتأمين', 'screen': const SubscriptionsScreen()},
    {'title': 'المحفظة', 'subtitle': 'إدارة الرصيد والمدفوعات', 'icon': Icons.account_balance_wallet_rounded, 'category': 'لوجستيات وتأمين', 'screen': const WalletScreen()},
    {'title': 'الخريطة الطبية', 'subtitle': 'المرافق الصحية', 'icon': Icons.map_rounded, 'category': 'لوجستيات وتأمين', 'screen': const InteractiveMapScreen()},
    {'title': 'تذكير الأدوية', 'subtitle': 'تنظيم مواعيد الأدوية', 'icon': Icons.medication_rounded, 'category': 'أدوات تشخيصية', 'screen': const MedicationReminderScreen()},
    {'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'icon': Icons.settings_rounded, 'category': 'إعدادات', 'screen': const SettingsScreen()},
    {'title': 'الإشعارات', 'subtitle': 'إدارة الإشعارات', 'icon': Icons.notifications_rounded, 'category': 'إعدادات', 'screen': const NotificationsScreen()},
    {'title': 'صحة الأسرة', 'subtitle': 'متابعة صحة أفراد الأسرة', 'icon': Icons.family_restroom_rounded, 'category': 'رعاية عائلية', 'screen': const ChildHealthScreen()},
    {'title': 'صحة المرأة', 'subtitle': 'متابعة صحة المرأة', 'icon': Icons.female_rounded, 'category': 'رعاية عائلية', 'screen': const WomensHealthScreen()},
    {'title': 'متابعة الحمل', 'subtitle': 'متابعة مراحل الحمل', 'icon': Icons.pregnant_woman_rounded, 'category': 'رعاية عائلية', 'screen': const PregnancyFollowUpScreen()},
  ];

  List<Map<String, dynamic>> get _filtered => _category == 'الكل' ? _services : _services.where((s) => s['category'] == _category).toList();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF4F6F7),
      appBar: AppBar(title: const Text('المزيد'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: ListView(controller: widget.scrollController, padding: const EdgeInsets.fromLTRB(16, 16, 16, 28), children: [
        Text('المؤشرات الحيوية', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _vitals.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final v = _vitals[i]; return SizedBox(width: 125, child: Card(elevation: 0, child: InkWell(borderRadius: BorderRadius.circular(14), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => v['screen'] as Widget)), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(v['icon'] as IconData, color: AppColors.primary, size: 22), const Spacer(), Text(v['label'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text('${v['value']} ${v['unit']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))])))); })),
        const SizedBox(height: 22),
        Text('الخدمات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: ['الكل', 'رعاية عائلية', 'أدوات تشخيصية', 'لوجستيات وتأمين', 'خدمات طبية', 'إعدادات'].map((c) => ChoiceChip(label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c))).toList()),
        const SizedBox(height: 14),
        ..._filtered.map((service) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 9), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(11)), child: Icon(service['icon'] as IconData, color: AppColors.primary)), title: Text(service['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text(service['subtitle'] as String, style: const TextStyle(fontSize: 11)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => service['screen'] as Widget))))),
      ]),
    );
  }
}
