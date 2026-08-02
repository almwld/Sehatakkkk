import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';

class LabDetailScreen extends StatefulWidget {
  final String labId;

  const LabDetailScreen({super.key, required this.labId});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _lab = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLabData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLabData() {
    // ✅ بيانات تجريبية - سيتم جلبها من Firebase لاحقاً
    final labs = [
      {
        'id': '1',
        'name': 'مختبرات الذبحاني',
        'category': 'تحاليل عامة',
        'address': 'صنعاء - شارع الأصبحي',
        'rating': 4.9,
        'reviews': 328,
        'phone': '01-234567',
        'image': ImageKit.lab1,
        'open': true,
        'price': '100-500',
        'tests': ['CBC', 'سكر', 'دهون', 'وظائف كبد', 'وظائف كلى', 'فيتامين د'],
        'equipment': ['ميكروسكوب رقمي', 'جهاز تحليل كيميائي', 'جهاز PCR', 'جهاز طيف ضوئي'],
        'specialties': ['تحاليل عامة', 'كيمياء حيوية', 'أمراض معدية'],
        'homeService': true,
        'urgent': true,
        'established': '2005',
        'description': 'أحد أقدم المختبرات في صنعاء مع كادر طبي متخصص وأجهزة حديثة',
        'workingHours': '8:00 ص - 8:00 م',
        'doctors': ['د. محمد الذبحاني', 'د. أحمد العزي'],
        'accreditations': ['معتمد من وزارة الصحة', 'جودة ISO 9001'],
      },
      // يمكن إضافة المزيد من المختبرات هنا
    ];

    _lab = labs.firstWhere((l) => l['id'] == widget.labId, orElse: () => labs[0]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_lab['name'] ?? 'تفاصيل المختبر'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '📋 معلومات'),
            Tab(text: '🔬 الفحوصات'),
            Tab(text: '📊 الأجهزة'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(isDark),
          _buildTestsTab(isDark),
          _buildEquipmentTab(isDark),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LabBookingScreen(labId: _lab['id'] as String),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '📅 حجز فحص',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ تبويب المعلومات
  Widget _buildInfoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ صورة المختبر
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AppImage(
              url: _lab['image'],
              height: 200,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ الاسم والتقييم
          Row(
            children: [
              Expanded(
                child: Text(
                  _lab['name'] ?? '',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _lab['rating'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      ' (${_lab['reviews']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ العنوان
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _lab['address'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ✅ ساعات العمل
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _lab['workingHours'] ?? '8:00 ص - 8:00 م',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ✅ الحالة
          Row(
            children: [
              Icon(Icons.circle, size: 14, color: _lab['open'] == true ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(
                _lab['open'] == true ? '🟢 مفتوح الآن' : '🔴 مغلق حالياً',
                style: TextStyle(
                  fontSize: 14,
                  color: _lab['open'] == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Divider(),
          const SizedBox(height: 16),

          // ✅ الوصف
          const Text(
            '📝 عن المختبر',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _lab['description'] ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ التخصصات
          const Text(
            '🎯 التخصصات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: (_lab['specialties'] as List).map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ✅ الشهادات
          const Text(
            '🏅 الشهادات والاعتمادات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...(_lab['accreditations'] as List).map((a) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    a,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),

          // ✅ الأطباء
          const Text(
            '👨‍⚕️ الكادر الطبي',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...(_lab['doctors'] as List).map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    d,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),

          // ✅ سنة التأسيس
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'تأسس عام ${_lab['established'] ?? '2010'}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ✅ تبويب الفحوصات
  Widget _buildTestsTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: (_lab['tests'] as List).length,
      itemBuilder: (context, index) {
        final test = (_lab['tests'] as List)[index];
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
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.science,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  test,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'متاح',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
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

  // ✅ تبويب الأجهزة
  Widget _buildEquipmentTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: (_lab['equipment'] as List).length,
      itemBuilder: (context, index) {
        final equipment = (_lab['equipment'] as List)[index];
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
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  equipment,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }
}
