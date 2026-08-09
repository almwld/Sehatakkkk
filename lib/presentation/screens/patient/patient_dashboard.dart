import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ValueNotifier<bool>? isBottomBarVisible;

  const PatientDashboard({super.key, this.isBottomBarVisible});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // ✅ بيانات المريض
  final Map<String, dynamic> _patientData = {
    'name': 'أحمد محمد',
    'age': 35,
    'bloodType': 'A+',
    'weight': 75,
    'height': 175,
  };

  // ✅ المؤشرات الحيوية - جميعها من مجلد tracking
  final List<Map<String, dynamic>> _vitals = [
    {'title': 'ضغط الدم', 'value': '120/80', 'unit': 'mmHg', 'icon': 'assets/images/tracking/blood_pressure.png', 'color': Colors.red, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'السكر', 'value': '95', 'unit': 'mg/dL', 'icon': 'assets/images/tracking/blood_sugar.png', 'color': Colors.orange, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'الوزن', 'value': '75', 'unit': 'kg', 'icon': 'assets/images/tracking/weight_tracking.png', 'color': Colors.green, 'status': 'مثالي', 'statusColor': Colors.green},
    {'title': 'معدل القلب', 'value': '72', 'unit': 'bpm', 'icon': 'assets/images/tracking/fitness.png', 'color': Colors.pink, 'status': 'ممتاز', 'statusColor': Colors.green},
    {'title': 'الصحة النفسية', 'value': 'جيد', 'unit': '', 'icon': 'assets/images/tracking/mental_health.png', 'color': Colors.purple, 'status': 'مستقر', 'statusColor': Colors.green},
    {'title': 'التغذية', 'value': '5', 'unit': 'وجبات', 'icon': 'assets/images/tracking/nutrition.png', 'color': Colors.teal, 'status': 'جيد', 'statusColor': Colors.green},
  ];

  // ✅ الإحصائيات - جميعها من مجلد services
  final List<Map<String, dynamic>> _stats = [
    {'label': 'الزيارات', 'value': '12', 'icon': 'assets/images/services/calendar_booking.png', 'color': AppColors.primary},
    {'label': 'الأدوية', 'value': '5', 'icon': 'assets/images/services/medications.png', 'color': AppColors.success},
    {'label': 'التحاليل', 'value': '8', 'icon': 'assets/images/services/laboratory.png', 'color': AppColors.purple},
    {'label': 'التقارير', 'value': '6', 'icon': 'assets/images/services/medical_records.png', 'color': AppColors.info},
  ];

  // ✅ الباقات
  final List<Map<String, dynamic>> _packages = [
    {'name': 'الفضية', 'price': '4,900', 'features': ['استشارات محدودة', 'دعم أساسي', '3 مواعيد'], 'color': Colors.grey},
    {'name': 'الذهبية', 'price': '7,900', 'features': ['استشارات غير محدودة', 'دعم مميز', 'مواعيد غير محدودة', 'خصم 20%'], 'color': AppColors.amber, 'popular': true},
    {'name': 'البلاتينية', 'price': '12,900', 'features': ['استشارات VIP', 'دعم على مدار الساعة', 'مواعيد خاصة', 'خصم 30%', 'طبيب خاص'], 'color': Colors.blue},
  ];

  // ✅ الخدمات الصحية - جميعها من مجلد services
  final List<Map<String, dynamic>> _healthServices = [
    {'icon': 'assets/images/tracking/blood_pressure.png', 'label': 'ضغط الدم', 'color': AppColors.error, 'screen': const BloodPressureScreen()},
    {'icon': 'assets/images/tracking/blood_sugar.png', 'label': 'تتبع السكر', 'color': AppColors.warning, 'screen': const GlucoseTrackerScreen()},
    {'icon': 'assets/images/tracking/weight_tracking.png', 'label': 'الوزن', 'color': AppColors.info, 'screen': const WeightTrackerScreen()},
    {'icon': 'assets/images/services/medications.png', 'label': 'الأدوية', 'color': AppColors.success, 'screen': const MedicationReminderScreen()},
    {'icon': 'assets/images/tracking/fitness.png', 'label': 'فحص البلاس', 'color': AppColors.teal, 'screen': const PulseOximeterScreen()},
    {'icon': 'assets/images/services/medical_records.png', 'label': 'التقارير', 'color': AppColors.primary, 'screen': const MedicalReportsScreen()},
    {'icon': 'assets/images/services/calendar_booking.png', 'label': 'المواعيد', 'color': AppColors.purple, 'screen': const PatientAppointments()},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    if (widget.isBottomBarVisible != null) {
      if (currentScroll <= 10) {
        widget.isBottomBarVisible!.value = true;
        return;
      }

      if (currentScroll >= maxScroll - 10) {
        widget.isBottomBarVisible!.value = true;
        return;
      }

      if (position.userScrollDirection == ScrollDirection.reverse) {
        widget.isBottomBarVisible!.value = false;
      } else if (position.userScrollDirection == ScrollDirection.forward) {
        widget.isBottomBarVisible!.value = true;
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'حدث خطأ في تحميل البيانات';
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'حدث خطأ في تحديث البيانات';
      });
    }
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
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.circle, color: color, size: size * 0.6),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildShimmerLoader();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(isDark),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('المؤشرات الحيوية', isDark),
                  const SizedBox(height: 12),
                  _buildVitalsGrid(),
                  const SizedBox(height: 20),
                  _buildPackagesSection(isDark),
                  const SizedBox(height: 20),
                  _buildSectionTitle('خدمات صحية', isDark),
                  const SizedBox(height: 12),
                  _buildHealthServicesGrid(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('آخر المواعيد', isDark),
                  const SizedBox(height: 12),
                  _buildAppointmentsList(isDark),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دوال البناء
  Widget _buildHeader(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final logged = user != null;
    final name = logged ? user.displayName ?? 'مستخدم' : 'زائر';

    return Container(
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
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: _buildIcon('assets/images/icons/doctors/Male doctor.png', AppColors.primary, size: 30),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'حالتك الصحية جيدة 👍',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: _buildIcon('assets/images/services/medical_records.png', AppColors.primary, size: 22),
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

  Widget _buildStatsRow() {
    return Row(
      children: _stats.map((stat) {
        final color = stat['color'] as Color;
        final iconPath = stat['icon'] as String;
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
                _buildIcon(iconPath, color, size: 22),
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

  Widget _buildVitalsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        final color = vital['color'] as Color;
        final statusColor = vital['statusColor'] as Color;
        final iconPath = vital['icon'] as String;

        return GestureDetector(
          onTap: () {
            // التنقل إلى شاشة التفاصيل
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _buildIcon(iconPath, color, size: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vital['status'] as String,
                        style: TextStyle(
                          fontSize: 8,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  vital['title'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      vital['value'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (vital['unit'] != null && (vital['unit'] as String).isNotEmpty)
                      Text(
                        ' ${vital['unit']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                child: _buildIcon('assets/images/services/wallet.png', Colors.white, size: 28),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _packages.map((package) {
                final isPopular = package['popular'] == true;
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: isPopular
                        ? Border.all(color: AppColors.amber, width: 2)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      Text(
                        package['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${package['price']} ريال',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(package['features'] as List<String>).map((feature) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white70, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                feature,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthServicesGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: _healthServices.length,
      itemBuilder: (context, index) {
        final service = _healthServices[index];
        final color = service['color'] as Color;
        final iconPath = service['icon'] as String;

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
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(iconPath, color, size: 24),
                const SizedBox(height: 4),
                Text(
                  service['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsList(bool isDark) {
    final appointments = [
      {'doctor': 'د. أحمد المولد', 'date': '15/01/2024', 'time': '10:00 ص', 'status': 'قادم', 'statusColor': Colors.green},
      {'doctor': 'د. خالد النخلاني', 'date': '10/01/2024', 'time': '02:30 م', 'status': 'منتهي', 'statusColor': Colors.grey},
      {'doctor': 'د. أسماء الهندي', 'date': '05/01/2024', 'time': '09:00 ص', 'status': 'منتهي', 'statusColor': Colors.grey},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildIcon('assets/images/icons/doctors/Male doctor.png', AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctor'] as String,
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
                  appointment['status'] as String,
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

  Widget _buildShimmerLoader() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _shimmerPlaceholder(56, 56, 50),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _shimmerPlaceholder(150, 18, 8),
                                const SizedBox(height: 4),
                                _shimmerPlaceholder(100, 14, 8),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _shimmerPlaceholder(40, 20, 14),
                                    const SizedBox(width: 6),
                                    _shimmerPlaceholder(30, 20, 14),
                                    const SizedBox(width: 6),
                                    _shimmerPlaceholder(40, 20, 14),
                                  ],
                                ),
                              ],
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
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(child: _shimmerPlaceholder(80, 70, 12)),
                    const SizedBox(width: 8),
                    Expanded(child: _shimmerPlaceholder(80, 70, 12)),
                    const SizedBox(width: 8),
                    Expanded(child: _shimmerPlaceholder(80, 70, 12)),
                    const SizedBox(width: 8),
                    Expanded(child: _shimmerPlaceholder(80, 70, 12)),
                  ],
                ),
                const SizedBox(height: 20),
                _shimmerPlaceholder(120, 24, 8),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, __) => _shimmerPlaceholder(double.infinity, 120, 16),
                ),
                const SizedBox(height: 20),
                _shimmerPlaceholder(double.infinity, 200, 16),
                const SizedBox(height: 20),
                _shimmerPlaceholder(120, 24, 8),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, __) => _shimmerPlaceholder(double.infinity, 60, 12),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon('assets/images/services/emergency.png', Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
