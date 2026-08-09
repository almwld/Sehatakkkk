import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/health_tools/pulse_oximeter_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;
  bool _isLoading = false;

  final Map<String, dynamic> _patientData = {
    'name': 'أحمد محمد',
    'age': 35,
    'bloodType': 'A+',
    'height': 175,
    'weight': 75,
    'emergencyContact': 'خالد أحمد',
    'emergencyPhone': '777888999',
  };

  // ✅ الإحصائيات
  final List<Map<String, dynamic>> _stats = [
    {'label': 'الزيارات', 'value': '12', 'icon': Icons.calendar_month, 'color': AppColors.primary},
    {'label': 'الأدوية', 'value': '5', 'icon': Icons.medication, 'color': AppColors.success},
    {'label': 'التحاليل', 'value': '8', 'icon': Icons.science, 'color': AppColors.purple},
    {'label': 'التقارير', 'value': '6', 'icon': Icons.description, 'color': AppColors.info},
  ];

  // ✅ المؤشرات الحيوية - استخدام أيقونات tracking
  final List<Map<String, dynamic>> _vitals = [
    {'title': 'ضغط الدم', 'value': '120/80', 'status': 'طبيعي', 'icon': 'assets/images/tracking/blood_pressure.png', 'color': AppColors.error, 'screen': const BloodPressureScreen()},
    {'title': 'معدل السكر', 'value': '95 mg/dL', 'status': 'طبيعي', 'icon': 'assets/images/tracking/blood_sugar.png', 'color': AppColors.warning, 'screen': const GlucoseTrackerScreen()},
    {'title': 'الوزن', 'value': '75 kg', 'status': 'مثالي', 'icon': 'assets/images/tracking/weight_tracking.png', 'color': AppColors.info, 'screen': const WeightTrackerScreen()},
    {'title': 'الأدوية', 'value': '3', 'status': 'نشط', 'icon': 'assets/images/services/medications.png', 'color': AppColors.success, 'screen': const MedicationReminderScreen()},
    {'title': 'فحص البلاس', 'value': '98%', 'status': 'ممتاز', 'icon': 'assets/images/tracking/fitness.png', 'color': AppColors.teal, 'screen': const PulseOximeterScreen()},
  ];

  // ✅ أيقونات المؤشرات الحيوية - من مجلد tracking
  final List<Map<String, dynamic>> _vitalIcons = [
    {'icon': 'assets/images/tracking/blood_pressure.png', 'title': 'ضغط الدم', 'value': '120/80', 'unit': 'mmHg', 'color': Colors.red},
    {'icon': 'assets/images/tracking/blood_sugar.png', 'title': 'سكر الدم', 'value': '95', 'unit': 'mg/dL', 'color': Colors.orange},
    {'icon': 'assets/images/tracking/weight_tracking.png', 'title': 'الوزن', 'value': '72', 'unit': 'kg', 'color': Colors.green},
    {'icon': 'assets/images/tracking/fitness.png', 'title': 'اللياقة', 'value': '85%', 'unit': '', 'color': Colors.blue},
    {'icon': 'assets/images/tracking/mental_health.png', 'title': 'الصحة النفسية', 'value': 'جيد', 'unit': '', 'color': Colors.purple},
    {'icon': 'assets/images/tracking/nutrition.png', 'title': 'التغذية', 'value': '5 وجبات', 'unit': 'يومياً', 'color': Colors.teal},
    {'icon': 'assets/images/tracking/vaccination.png', 'title': 'التطعيمات', 'value': 'مكتمل', 'unit': '', 'color': Colors.indigo},
  ];

  // ✅ آخر المواعيد
  final List<Map<String, dynamic>> _recentAppointments = [
    {'doctor': 'د. أحمد المولد', 'date': '2024-01-15', 'time': '10:00 ص', 'status': 'قادم', 'image': "assets/images/doctors/doctor_1.png"},
    {'doctor': 'د. خالد النخلاني', 'date': '2024-01-10', 'time': '02:30 م', 'status': 'منتهي', 'image': "assets/images/doctors/doctor_2.png"},
    {'doctor': 'د. أسماء الهندي', 'date': '2024-01-05', 'time': '09:00 ص', 'status': 'منتهي', 'image': "assets/images/doctors/doctor_3.png"},
  ];

  // ✅ آخر النتائج
  final List<Map<String, dynamic>> _recentResults = [
    {'title': 'فحص الدم الشامل', 'date': '2024-01-10', 'status': 'طبيعي', 'color': Colors.green, 'icon': Icons.science},
    {'title': 'فحص السكر التراكمي', 'date': '2024-01-05', 'status': 'مرتفع قليلاً', 'color': Colors.orange, 'icon': Icons.biotech},
    {'title': 'فحص الدهون', 'date': '2024-01-01', 'status': 'طبيعي', 'color': Colors.green, 'icon': Icons.medical_services},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ دالة عرض أيقونة PNG
  Widget _buildIcon(String iconPath, Color color, {double size = 24}) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: color, size: size);
      },
    );
  }

  // ✅ دالة عرض أيقونة التتبع
  Widget _buildTrackingIcon(Map<String, dynamic> item, bool isDark) {
    return GestureDetector(
      onTap: () {
        // التنقل إلى شاشة التفاصيل
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _buildIcon(item['icon'] as String, item['color'] as Color, size: 24),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              item['value'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (item['unit'] != null && (item['unit'] as String).isNotEmpty)
              Text(
                item['unit'] as String,
                style: TextStyle(
                  fontSize: 9,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // ✅ عرض المؤشرات الحيوية في شبكة
  Widget _buildVitalsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _vitalIcons.length,
      itemBuilder: (context, index) {
        final item = _vitalIcons[index];
        return _buildTrackingIcon(item, isDark);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final user = FirebaseAuth.instance.currentUser;
    final logged = user != null;
    final name = logged ? user.displayName ?? 'مستخدم' : 'زائر';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
            foregroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Opacity(
                opacity: _appBarOpacity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PatientProfile()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: user?.photoURL ?? '',
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _shimmerPlaceholder(56, 56, 50),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(Icons.person, color: primaryColor, size: 30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مرحباً، $name',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'حالتك الصحية جيدة',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip('${_patientData['age']} سنة', isDark),
                                    _buildInfoChip(_patientData['bloodType'], isDark),
                                    _buildInfoChip('${_patientData['weight']} كجم', isDark),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.edit_outlined, color: primaryColor, size: 22),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PatientProfile()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _statsRow(),
                const SizedBox(height: 20),
                _buildPackagesSection(isDark),
                const SizedBox(height: 20),
                _sectionTitle('المؤشرات الحيوية', isDark),
                const SizedBox(height: 10),
                _buildVitalsGrid(),
                const SizedBox(height: 20),
                _sectionTitle('خدمات صحية', isDark),
                const SizedBox(height: 10),
                _healthServices(),
                const SizedBox(height: 20),
                _sectionTitle('آخر المواعيد', isDark),
                const SizedBox(height: 10),
                _buildAppointmentsList(isDark),
                const SizedBox(height: 20),
                _sectionTitle('آخر النتائج', isDark),
                const SizedBox(height: 10),
                _buildResultsList(isDark),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerPlaceholder(double width, double height, double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('عرض الكل'),
        ),
      ],
    );
  }

  Widget _buildPackagesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_membership,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اشترك في الباقات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'احصل على مميزات حصرية',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'الباقة الفضية',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '4,900 ريال',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'شهرياً',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.amber,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'الأكثر شيوعاً',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'الباقة الذهبية',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '7,900 ريال',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'شهرياً',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: _stats.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _healthServices() {
    final services = [
      {'icon': Icons.monitor_heart, 'label': 'ضغط الدم', 'color': AppColors.error, 'screen': const BloodPressureScreen()},
      {'icon': Icons.biotech, 'label': 'تتبع السكر', 'color': AppColors.warning, 'screen': const GlucoseTrackerScreen()},
      {'icon': Icons.monitor_weight, 'label': 'الوزن', 'color': AppColors.info, 'screen': const WeightTrackerScreen()},
      {'icon': Icons.medication, 'label': 'الأدوية', 'color': AppColors.success, 'screen': const MedicationReminderScreen()},
      {'icon': Icons.sensors, 'label': 'فحص البلاس', 'color': AppColors.teal, 'screen': const PulseOximeterScreen()},
      {'icon': Icons.description, 'label': 'التقارير', 'color': AppColors.primary, 'screen': const MedicalReportsScreen()},
      {'icon': Icons.calendar_month, 'label': 'المواعيد', 'color': AppColors.purple, 'screen': const PatientAppointments()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final color = service['color'] as Color;
        final isPulseOximeter = service['label'] == 'فحص البلاس';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => service['screen'] as Widget),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: isPulseOximeter ? Border.all(color: AppColors.teal, width: 1) : null,
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service['icon'] as IconData, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      service['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (isPulseOximeter)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _recentAppointments[index];
        final isPast = appointment['status'] == 'منتهي';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: appointment['image'],
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 44,
                    height: 44,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(Icons.person, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctor'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${appointment['date']} • ${appointment['time']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPast
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  appointment['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isPast ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentResults.length,
      itemBuilder: (context, index) {
        final result = _recentResults[index];
        final color = result['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(result['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      result['date'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  result['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
