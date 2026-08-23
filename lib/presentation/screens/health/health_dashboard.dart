import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/health/health_detail_screen.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard>
    with SingleTickerProviderStateMixin {
  String _userName = 'مستخدم';
  double _healthScore = 0.0;
  bool _isLoading = true;
  int _selectedTab = 0;
  late TabController _tabController;

  // ✅ المؤشرات الصحية - أيقونات مكبرة بدون حاويات
  final List<Map<String, dynamic>> _healthMetrics = [
    {
      'icon': 'assets/images/tracking/heart_rate.png',
      'label': 'نبض القلب',
      'value': '72',
      'unit': 'نبضة/دقيقة',
      'color': Colors.red,
      'status': 'طبيعي',
      'statusColor': Colors.green,
      'data': [70, 75, 72, 78, 74, 72, 71],
      'trend': '+2%',
      'trendUp': true,
    },
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.blue,
      'status': 'طبيعي',
      'statusColor': Colors.green,
      'data': [118, 120, 122, 119, 121, 120, 120],
      'trend': '0%',
      'trendUp': false,
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'سكر الدم',
      'value': '95',
      'unit': 'مجم/دل',
      'color': Colors.orange,
      'status': 'طبيعي',
      'statusColor': Colors.green,
      'data': [90, 95, 100, 88, 92, 95, 97],
      'trend': '-3%',
      'trendUp': false,
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.green,
      'status': 'مثالي',
      'statusColor': Colors.green,
      'data': [73, 72.5, 72, 71.8, 72, 72.2, 72],
      'trend': '-0.5%',
      'trendUp': false,
    },
  ];

  // ✅ النصائح الصحية - أيقونات جديدة
  final List<Map<String, dynamic>> _healthTips = [
    {
      'icon': 'assets/images/tracking/water_drinking.png',
      'title': 'شرب الماء',
      'subtitle': '8 أكواب يومياً',
      'color': Colors.blue,
      'progress': 0.75,
      'target': '2.4/3 لتر',
    },
    {
      'icon': 'assets/images/tracking/walking.png',
      'title': 'المشي',
      'subtitle': '30 دقيقة يومياً',
      'color': Colors.green,
      'progress': 0.6,
      'target': '18/30 دقيقة',
    },
    {
      'icon': 'assets/images/tracking/sleep_tracking.png',
      'title': 'النوم',
      'subtitle': '7-8 ساعات ليلاً',
      'color': Colors.indigo,
      'progress': 0.8,
      'target': '6.4/8 ساعات',
    },
    {
      'icon': 'assets/images/tracking/fruits.png',
      'title': 'الفواكه',
      'subtitle': '5 حصص يومياً',
      'color': Colors.red,
      'progress': 0.4,
      'target': '2/5 حصص',
    },
  ];

  // ✅ سجل الفحوصات
  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'title': 'تحليل دم شامل',
      'date': '2024-01-15',
      'lab': 'مختبرات الذبحاني',
      'status': 'مكتمل',
      'statusColor': Colors.green,
    },
    {
      'title': 'تحليل وظائف الكبد',
      'date': '2024-01-10',
      'lab': 'مختبرات العولقي',
      'status': 'مكتمل',
      'statusColor': Colors.green,
    },
    {
      'title': 'تحليل سكر تراكمي',
      'date': '2024-01-05',
      'lab': 'مختبرات المأمون',
      'status': 'قيد الانتظار',
      'statusColor': Colors.orange,
    },
    {
      'title': 'تحليل فيتامين د',
      'date': '2024-01-01',
      'lab': 'مختبرات الرازي',
      'status': 'مكتمل',
      'statusColor': Colors.green,
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
      'statusColor': Colors.green,
    },
    {
      'doctor': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'date': '2024-01-25',
      'time': '02:00 م',
      'status': 'قيد الانتظار',
      'statusColor': Colors.orange,
    },
    {
      'doctor': 'د. أسماء الهندي',
      'specialty': 'أطفال',
      'date': '2024-01-28',
      'time': '09:30 ص',
      'status': 'مؤكد',
      'statusColor': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    _loadUserData();
    _loadHealthScore();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        } else {
          setState(() {
            _userName = user.displayName ?? 'مستخدم';
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

  // ✅ دالة عرض الأيقونة - بدون حاويات
  Widget _buildIcon(String path, {double size = 48, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: color ?? AppColors.primary, size: size);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'صحتي',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(isDark),
                  const SizedBox(height: 16),
                  _buildHealthScoreCard(isDark),
                  const SizedBox(height: 20),
                  _buildSectionHeader('المؤشرات الحيوية', isDark),
                  const SizedBox(height: 12),
                  _buildMetricsGrid(isDark),
                  const SizedBox(height: 20),
                  _buildSectionHeader('النصائح الصحية', isDark),
                  const SizedBox(height: 12),
                  _buildTipsGrid(isDark),
                  const SizedBox(height: 20),
                  _buildTabBar(isDark),
                  const SizedBox(height: 12),
                  _buildTabContent(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ✅ بطاقة الترحيب
  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.6),
            const Color(0xFF0D5257),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
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
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً 👋',
                  style: TextStyle(
                    fontSize: 14,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ بطاقة درجة الصحة - دائرة مكبرة
  Widget _buildHealthScoreCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ دائرة مكبرة (120 -> 100)
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _healthScore / 100,
                  strokeWidth: 10,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  color: _getScoreColor(_healthScore),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _healthScore.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(_healthScore),
                      ),
                    ),
                    Text(
                      'من 100',
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
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildStatusChip('ممتاز', Colors.green, isDark),
                    _buildStatusChip('جيد', Colors.blue, isDark),
                    _buildStatusChip('يحتاج تحسين', Colors.orange, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'عرض الكل',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ المؤشرات الحيوية - أيقونات مكبرة 3x بدون حاويات
  Widget _buildMetricsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: _healthMetrics.length,
      itemBuilder: (context, index) {
        final metric = _healthMetrics[index];
        return GestureDetector(
          onTap: () {
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (metric['color'] as Color).withOpacity(0.08),
                  (metric['color'] as Color).withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (metric['color'] as Color).withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ أيقونة مكبرة 3x (36 -> 48)
                _buildIcon(
                  metric['icon'] as String,
                  size: 48,
                  color: metric['color'] as Color,
                ),
                const SizedBox(height: 10),
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
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (metric['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: metric['statusColor'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metric['status'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: metric['statusColor'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      (metric['trendUp'] as bool) ? Icons.trending_up : Icons.trending_down,
                      color: (metric['trendUp'] as bool) ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      metric['trend'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: (metric['trendUp'] as bool) ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
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

  // ✅ النصائح الصحية - أيقونات مكبرة بدون حاويات
  Widget _buildTipsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _healthTips.length,
      itemBuilder: (context, index) {
        final tip = _healthTips[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ أيقونة مكبرة (30 -> 40)
              _buildIcon(
                tip['icon'] as String,
                size: 40,
                color: tip['color'] as Color,
              ),
              const SizedBox(height: 8),
              Text(
                tip['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                tip['subtitle'] as String,
                style: TextStyle(
                  fontSize: 9,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: tip['progress'] as double,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tip['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tip['target'] as String,
                style: TextStyle(
                  fontSize: 8,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ التبويبات
  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
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
        onTap: () {
          setState(() {
            _selectedTab = index;
            _tabController.animateTo(index);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

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
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ أيقونة مكبرة (44 -> 32)
              _buildIcon('assets/images/services/laboratory.png', size: 32, color: AppColors.primary),
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
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (record['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  record['status'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: record['statusColor'] as Color,
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
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ أيقونة مكبرة (44 -> 32)
              _buildIcon('assets/images/services/calendar_booking.png', size: 32, color: AppColors.primary),
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
                        fontSize: 11,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (appointment['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  appointment['status'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: appointment['statusColor'] as Color,
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

  // ✅ دوال مساعدة
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
}
