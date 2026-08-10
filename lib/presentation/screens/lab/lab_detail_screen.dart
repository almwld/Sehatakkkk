import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_results_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_review_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';

class LabDetailScreen extends StatefulWidget {
  final String labId;

  const LabDetailScreen({super.key, required this.labId});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _lab = {};
  bool _isFavorite = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLabData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLabData() {
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
        'tests': [
          {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 150, 'time': '2-4 ساعات'},
          {'id': 't2', 'name': 'سكر الدم', 'price': 100, 'time': '1-2 ساعات'},
          {'id': 't3', 'name': 'دهون ثلاثية', 'price': 120, 'time': '2-4 ساعات'},
          {'id': 't4', 'name': 'وظائف كبد', 'price': 180, 'time': '4-8 ساعات'},
          {'id': 't5', 'name': 'وظائف كلى', 'price': 160, 'time': '4-8 ساعات'},
          {'id': 't6', 'name': 'فيتامين د', 'price': 250, 'time': '24-48 ساعة'},
        ],
        'equipment': ['ميكروسكوب رقمي', 'جهاز تحليل كيميائي', 'جهاز PCR', 'جهاز طيف ضوئي'],
        'specialties': ['تحاليل عامة', 'كيمياء حيوية', 'أمراض معدية'],
        'homeService': true,
        'urgent': true,
        'established': '2005',
        'description': 'أحد أقدم المختبرات في صنعاء مع كادر طبي متخصص وأجهزة حديثة',
        'workingHours': '8:00 ص - 8:00 م',
        'doctors': ['د. محمد الذبحاني', 'د. أحمد العزي'],
        'accreditations': ['معتمد من وزارة الصحة', 'جودة ISO 9001'],
        'images': [ImageKit.lab1, ImageKit.lab2, ImageKit.lab3, ImageKit.lab1],
        'resultsTime': '4-24 ساعة',
        'homeCollection': true,
        'insurance': ['جوبيلي', 'أدامجي', 'أليانز'],
        'languages': ['العربية', 'الإنجليزية'],
        'parking': true,
        'wheelchair': true,
      },
    ];

    _lab = labs.firstWhere((l) => l['id'] == widget.labId, orElse: () => labs[0]);
  }

  void _navigateToBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabBookingScreen(
          labId: _lab['id'] as String,
        ),
      ),
    );
  }

  void _navigateToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabResultsScreen(labId: _lab['id'] as String),
      ),
    );
  }

  void _navigateToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabReviewScreen(labId: _lab['id'] as String),
      ),
    );
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
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'معلومات'),
            Tab(text: 'فحوصات'),
            Tab(text: 'أجهزة'),
            Tab(text: 'معرض'),
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
          _buildGalleryTab(isDark),
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
                  onPressed: _navigateToBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حجز فحص',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InteractiveMapScreen(type: 'labs'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('الموقع'),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AppImage(
              imageUrl: _lab['image'],
              height: 200,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
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
              GestureDetector(
                onTap: _navigateToReview,
                child: Container(
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
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _lab['address'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'نتائج خلال ${_lab['resultsTime'] ?? '4-24 ساعة'}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, size: 14, color: _lab['open'] == true ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(
                _lab['open'] == true ? 'مفتوح الآن' : 'مغلق حالياً',
                style: TextStyle(
                  fontSize: 14,
                  color: _lab['open'] == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureItem(
                  Icons.home,
                  'خدمة منزلية',
                  _lab['homeCollection'] == true,
                  isDark,
                ),
                _buildFeatureItem(
                  Icons.local_hospital,
                  'عينة منزلية',
                  _lab['homeService'] == true,
                  isDark,
                ),
                _buildFeatureItem(
                  Icons.local_parking,
                  'موقف سيارات',
                  _lab['parking'] == true,
                  isDark,
                ),
                _buildFeatureItem(
                  Icons.accessible,
                  'كرسي متحرك',
                  _lab['wheelchair'] == true,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'عن المختبر',
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
          const Text(
            'التخصصات',
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
          const Text(
            'اللغات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: (_lab['languages'] as List).map((l) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'شركات التأمين المقبولة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: (_lab['insurance'] as List).map((i) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  i,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'الشهادات والاعتمادات',
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
          const Text(
            'الكادر الطبي',
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateToResults,
                  icon: const Icon(Icons.history),
                  label: const Text('نتائج سابقة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateToReview,
                  icon: const Icon(Icons.star),
                  label: const Text('تقييم'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber,
                    side: const BorderSide(color: Colors.amber),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, bool active, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          color: active ? AppColors.primary : (isDark ? Colors.grey[600] : Colors.grey[400]),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? AppColors.primary : (isDark ? Colors.grey[500] : Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  // ✅ تبويب الفحوصات
  Widget _buildTestsTab(bool isDark) {
    final tests = _lab['tests'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return GestureDetector(
          onTap: _navigateToBooking,
          child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'النتيجة خلال ${test['time']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${test['price']} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'متاح',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
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

  // ✅ تبويب المعرض
  Widget _buildGalleryTab(bool isDark) {
    final images = _lab['images'] as List;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AppImage(
              imageUrl: images[_selectedImageIndex],
              height: 200,
              width: double.infinity,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedImageIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppImage(
                      imageUrl: images[index],
                      width: 70,
                      height: 70,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
