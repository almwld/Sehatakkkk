import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_dimensions.dart';
import 'package:sehatak/presentation/screens/health/health_detail_screen.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  String _userName = 'مستخدم';
  double _healthScore = 0.0;
  bool _isLoading = true;
  int _selectedTab = 0;

  // ✅ بيانات المؤشرات الصحية (4 مؤشرات رئيسية) - مع مسارات PNG
  final List<Map<String, dynamic>> _healthMetrics = [
    {
      'icon': 'assets/images/tracking/heart_rate.png',
      'label': 'نبض القلب',
      'value': '72',
      'unit': 'نبضة/دقيقة',
      'color': Colors.red,
      'status': 'طبيعي',
      'data': [70, 75, 72, 78, 74, 72, 71],
      'screen': HealthDetailScreen(
        title: 'نبض القلب',
        icon: 'assets/images/tracking/heart_rate.png',
        color: Colors.red,
      ),
    },
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.blue,
      'status': 'طبيعي',
      'data': [118, 120, 122, 119, 121, 120, 120],
      'screen': HealthDetailScreen(
        title: 'ضغط الدم',
        icon: 'assets/images/tracking/blood_pressure.png',
        color: Colors.blue,
      ),
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'السكر',
      'value': '95',
      'unit': 'مج/دل',
      'color': Colors.orange,
      'status': 'طبيعي',
      'data': [90, 95, 100, 88, 92, 95, 97],
      'screen': HealthDetailScreen(
        title: 'السكر',
        icon: 'assets/images/tracking/blood_sugar.png',
        color: Colors.orange,
      ),
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.green,
      'status': 'طبيعي',
      'data': [73, 72.5, 72, 71.8, 72, 72.2, 72],
      'screen': HealthDetailScreen(
        title: 'الوزن',
        icon: 'assets/images/tracking/weight_tracking.png',
        color: Colors.green,
      ),
    },
  ];

  // ✅ نصائح صحية (أيقونات مصغرة) - مع مسارات PNG
  final List<Map<String, dynamic>> _healthTips = [
    {
      'title': 'شرب الماء',
      'value': '1.5',
      'unit': 'لتر',
      'icon': 'assets/images/tracking/water.png',
      'color': Colors.blue,
      'data': [1.2, 1.5, 1.8, 1.5, 1.0, 1.5, 1.5],
    },
    {
      'title': 'خطوات المشي',
      'value': '8,542',
      'unit': 'خطوة',
      'icon': 'assets/images/tracking/steps.png',
      'color': Colors.green,
      'data': [7000, 8000, 8542, 8200, 7800, 9000, 8542],
    },
    {
      'title': 'ساعات النوم',
      'value': '7.5',
      'unit': 'ساعة',
      'icon': 'assets/images/tracking/sleep.png',
      'color': Colors.indigo,
      'data': [6.5, 7.0, 7.5, 8.0, 7.0, 7.5, 7.5],
    },
    {
      'title': 'السعرات الحرارية',
      'value': '2,450',
      'unit': 'سعرة',
      'icon': 'assets/images/tracking/calories.png',
      'color': Colors.orange,
      'data': [2000, 2200, 2450, 2300, 2100, 2500, 2450],
    },
  ];

  // ✅ سجل الفحوصات
  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'title': 'تحليل دم شامل',
      'date': '2024-01-15',
      'lab': 'مختبرات الذبحاني',
      'status': 'مكتمل',
      'color': Colors.green,
    },
    {
      'title': 'تحليل وظائف الكبد',
      'date': '2024-01-10',
      'lab': 'مختبرات العولقي',
      'status': 'مكتمل',
      'color': Colors.green,
    },
    {
      'title': 'تحليل سكر تراكمي',
      'date': '2024-01-05',
      'lab': 'مختبرات المأمون',
      'status': 'قيد الانتظار',
      'color': Colors.orange,
    },
  ];

  // ✅ المواعيد القادمة
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'doctor': 'د. أحمد المؤيد',
      'specialty': 'باطنية',
      'date': '2024-01-20',
      'time': '10:00 ص',
      'status': 'مؤكد',
    },
    {
      'doctor': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'date': '2024-01-25',
      'time': '02:00 م',
      'status': 'قيد الانتظار',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHealthScore();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _userName = doc.data()?['name'] ?? user.displayName ?? 'مستخدم';
          });
        }
      } catch (e) {
        setState(() {
          _userName = user.displayName ?? 'مستخدم';
        });
      }
    }
  }

  Future<void> _loadHealthScore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('health_metrics')
            .doc('current')
            .get();

        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _healthScore = (data?['score'] ?? 0.0).toDouble();
            _isLoading = false;
          });
        } else {
          setState(() {
            _healthScore = 78.5;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _healthScore = 78.5;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _healthScore = 78.5;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('صحتي'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // فتح شاشة الإشعارات
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ بطاقة الترحيب
                  _buildWelcomeCard(isDark),
                  const SizedBox(height: 16),

                  // ✅ درجة الصحة
                  _buildHealthScoreCard(isDark),
                  const SizedBox(height: 16),

                  // ✅ 4 مؤشرات صحية رئيسية (مع ربطها بشاشاتها)
                  _buildMetricsGrid(isDark),
                  const SizedBox(height: 16),

                  // ✅ النصائح الصحية (أيقونات مصغرة)
                  _buildTipsGrid(isDark),
                  const SizedBox(height: 16),

                  // ✅ أقسام التبويب
                  _buildTabBar(isDark),
                  const SizedBox(height: 16),

                  // ✅ محتوى التبويب
                  _buildTabContent(isDark),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 🧑 بطاقة الترحيب
  // ============================================================
  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _userName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  _healthScore.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 بطاقة درجة الصحة
  // ============================================================
  Widget _buildHealthScoreCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'درجة صحتي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // ✅ الدائرة
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _healthScore / 100,
                      strokeWidth: 8,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      color: _getScoreColor(_healthScore),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _healthScore.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(_healthScore),
                          ),
                        ),
                        Text(
                          'من 100',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getScoreStatus(_healthScore),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(_healthScore),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreDescription(_healthScore),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusChip('ممتاز', Colors.green),
                        _buildStatusChip('جيد', Colors.blue),
                        _buildStatusChip('يحتاج تحسين', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreStatus(double score) {
    if (score >= 80) return 'ممتاز';
    if (score >= 60) return 'جيد';
    return 'يحتاج تحسين';
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'صحتك في أفضل حالاتها، استمر على هذا المنوال!';
    if (score >= 60) return 'صحتك جيدة، يمكنك تحسين بعض العادات.';
    return 'يجب الانتباه لبعض المؤشرات، استشر طبيبك.';
  }

  // ============================================================
  // 📊 شبكة المؤشرات الصحية (4 مؤشرات رئيسية)
  // ============================================================
  Widget _buildMetricsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _healthMetrics.length,
      itemBuilder: (context, index) {
        final metric = _healthMetrics[index];
        return GestureDetector(
          onTap: () {
            // ✅ فتح شاشة التفاصيل عند الضغط
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HealthDetailScreen(
                  title: metric['label'] as String,
                  icon: metric['icon'] as String,
                  color: metric['color'] as Color,
                  value: metric['value'] as String,
                  unit: metric['unit'] as String,
                  data: metric['data'] as List<dynamic>,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
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
                // ✅ أيقونة PNG
                Image.asset(
                  metric['icon'] as String,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.favorite,
                      color: metric['color'] as Color,
                      size: 48,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  metric['value'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  metric['unit'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (metric['status'] as String) == 'طبيعي'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    metric['status'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: (metric['status'] as String) == 'طبيعي'
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
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

  // ============================================================
  // 📊 شبكة النصائح الصحية (أيقونات مصغرة)
  // ============================================================
  Widget _buildTipsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: _healthTips.length,
      itemBuilder: (context, index) {
        final tip = _healthTips[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ أيقونة PNG مصغرة (نصف الحجم)
              Image.asset(
                tip['icon'] as String,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.circle,
                    color: tip['color'] as Color,
                    size: 24,
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                tip['value'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                tip['unit'] as String,
                style: TextStyle(
                  fontSize: 8,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                tip['title'] as String,
                style: TextStyle(
                  fontSize: 8,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 📱 التبويبات
  // ============================================================
  Widget _buildTabBar(bool isDark) {
    return Container(
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
      child: Row(
        children: [
          _buildTabItem('الفحوصات', 0, isDark),
          _buildTabItem('المواعيد', 1, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📄 محتوى التبويبات
  // ============================================================
  Widget _buildTabContent(bool isDark) {
    switch (_selectedTab) {
      case 0:
        return _buildRecordsTab(isDark);
      case 1:
        return _buildAppointmentsTab(isDark);
      default:
        return const SizedBox();
    }
  }

  // ✅ تبويب الفحوصات
  Widget _buildRecordsTab(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicalRecords.length,
      itemBuilder: (context, index) {
        final record = _medicalRecords[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.science, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record['lab']} • ${record['date']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (record['status'] as String) == 'مكتمل'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record['status'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: (record['status'] as String) == 'مكتمل'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ تبويب المواعيد
  Widget _buildAppointmentsTab(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _upcomingAppointments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctor'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appointment['specialty']} • ${appointment['date']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment['time'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (appointment['status'] as String) == 'مؤكد'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment['status'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: (appointment['status'] as String) == 'مؤكد'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
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
