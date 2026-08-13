import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final String hospitalId;
  final Map<String, dynamic>? hospitalData;

  const HospitalDetailsScreen({
    super.key,
    required this.hospitalId,
    this.hospitalData,
  });

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  bool _isLoading = true;
  Map<String, dynamic> _hospital = {};
  int _selectedRating = 0;

  // ✅ بيانات وهمية للمستشفى
  final Map<String, dynamic> _defaultHospital = {
    'id': '1',
    'name': 'مستشفى 22 مايو',
    'location': 'صنعاء - حدة',
    'rating': 4.9,
    'reviews': 328,
    'image': ImageKit.hospital1,
    'open': true,
    'phone': '+967 1 234 567',
    'email': 'info@22mayhospital.com',
    'website': 'www.22mayhospital.com',
    'description': 'مستشفى 22 مايو هو أحد أكبر المستشفيات في اليمن، يقدم خدمات طبية متكاملة على مدار الساعة. يحتوي على أقسام متخصصة في الجراحة، الباطنية، القلب، الأطفال، والعناية المركزة.',
    'specialties': [
      'جراحة عامة',
      'جراحة قلبية',
      'باطنية',
      'أطفال',
      'نساء وولادة',
      'عناية مركزة',
      'طوارئ',
      'أشعة',
      'مختبر',
    ],
    'doctors': [
      {'id': '1', 'name': 'د. أحمد المؤيد', 'specialty': 'جراحة قلبية', 'image': ImageKit.doctor1},
      {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'باطنية', 'image': ImageKit.doctor2},
      {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'image': ImageKit.doctor3},
      {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'جراحة عامة', 'image': ImageKit.doctor4},
    ],
    'workingHours': {
      'الأحد': '08:00 - 22:00',
      'الإثنين': '08:00 - 22:00',
      'الثلاثاء': '08:00 - 22:00',
      'الأربعاء': '08:00 - 22:00',
      'الخميس': '08:00 - 22:00',
      'الجمعة': '09:00 - 17:00',
      'السبت': '09:00 - 17:00',
    },
    'services': [
      {'icon': Icons.emergency, 'label': 'طوارئ 24 ساعة'},
      {'icon': Icons.local_hospital, 'label': 'عيادات خارجية'},
      {'icon': Icons.science, 'label': 'مختبر متكامل'},
      {'icon': Icons.radar, 'label': 'أشعة مقطعية'},
      {'icon': Icons.favorite, 'label': 'قسطرة قلبية'},
      {'icon': Icons.medical_services, 'label': 'جراحة متقدمة'},
    ],
    'gallery': [
      ImageKit.hospital1,
      ImageKit.hospital2,
      ImageKit.hospital3,
      ImageKit.hospital4,
      ImageKit.hospital5,
      ImageKit.hospital6,
    ],
  };

  // ✅ بيانات المواعيد المتاحة
  final List<Map<String, dynamic>> _availableAppointments = [
    {'date': 'اليوم', 'time': '10:00 ص', 'available': true},
    {'date': 'اليوم', 'time': '02:00 م', 'available': true},
    {'date': 'غداً', 'time': '09:00 ص', 'available': true},
    {'date': 'غداً', 'time': '01:00 م', 'available': false},
    {'date': 'بعد غد', 'time': '11:00 ص', 'available': true},
    {'date': 'بعد غد', 'time': '03:00 م', 'available': true},
  ];

  // ✅ التقييمات
  final List<Map<String, dynamic>> _reviews = [
    {'name': 'أحمد علي', 'rating': 5, 'comment': 'مستشفى ممتاز وخدمات رائعة، الطاقم الطبي متعاون جداً.', 'date': 'منذ 3 أيام'},
    {'name': 'فاطمة حسن', 'rating': 4, 'comment': 'خدمة جيدة ولكن الانتظار طويل بعض الشيء.', 'date': 'منذ أسبوع'},
    {'name': 'محمد صالح', 'rating': 5, 'comment': 'أفضل مستشفى في صنعاء، أنصح به الجميع.', 'date': 'منذ أسبوعين'},
    {'name': 'سارة أحمد', 'rating': 4, 'comment': 'نظافة وترتيب، والأطباء متميزون.', 'date': 'منذ شهر'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHospitalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadHospitalData() {
    setState(() => _isLoading = true);
    // محاكاة تحميل البيانات
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _hospital = widget.hospitalData ?? _defaultHospital;
        _isLoading = false;
      });
    });
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '✅ تمت الإضافة إلى المفضلة' : '❌ تمت الإزالة من المفضلة'),
        backgroundColor: _isFavorite ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAppointmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          String selectedDate = 'اليوم';
          String selectedTime = '10:00 ص';

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'حجز موعد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر التاريخ والوقت المناسبين',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'التاريخ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _availableAppointments[index];
                      final isSelected = selectedDate == appointment['date'];
                      return GestureDetector(
                        onTap: appointment['available'] ? () {
                          setStateModal(() {
                            selectedDate = appointment['date'] as String;
                            selectedTime = appointment['time'] as String;
                          });
                        } : null,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (appointment['available']
                                    ? Colors.grey[200]
                                    : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            appointment['date'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (appointment['available']
                                      ? Colors.black
                                      : Colors.grey[400]),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'الوقت',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableAppointments.where((a) => a['date'] == selectedDate).map((appointment) {
                    final isSelected = selectedTime == appointment['time'];
                    return GestureDetector(
                      onTap: appointment['available'] ? () {
                        setStateModal(() {
                          selectedTime = appointment['time'] as String;
                        });
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (appointment['available']
                                  ? Colors.grey[200]
                                  : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          appointment['time'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (appointment['available']
                                    ? Colors.black
                                    : Colors.grey[400]),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم حجز الموعد بنجاح!'),
                          backgroundColor: Colors.green,
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
                      'تأكيد الحجز',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDoctorDetails(String doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailsScreen(doctorId: doctorId),
      ),
    );
  }

  void _showFullMap() {
    // سيتم إضافة شاشة الخريطة لاحقاً
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗺️ جاري تحميل الخريطة...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _callHospital() {
    final phone = _hospital['phone'] ?? '+967 1 234 567';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 جاري الاتصال بـ $phone'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              floating: false,
              backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔗 تم نسخ الرابط'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      imageUrl: _hospital['image'] as String? ?? ImageKit.hospital1,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _hospital['open'] == true
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _hospital['open'] == true ? 'مفتوح' : 'مغلق',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    _hospital['rating'].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${_hospital['reviews']})',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hospital['name'] as String? ?? 'مستشفى',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _hospital['location'] as String? ?? 'صنعاء',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'نبذة'),
                  Tab(text: 'الأطباء'),
                  Tab(text: 'التقييمات'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // ✅ تبويب النبذة
            _buildOverviewTab(isDark),
            // ✅ تبويب الأطباء
            _buildDoctorsTab(isDark),
            // ✅ تبويب التقييمات
            _buildReviewsTab(isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  // ============================================================
  // ✅ التبويب الأول: النبذة
  // ============================================================
  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ الوصف
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نبذة عن المستشفى',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _hospital['description'] as String? ?? 'مستشفى يقدم خدمات طبية متكاملة.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ المعلومات
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات الاتصال',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, 'الهاتف', _hospital['phone'] as String? ?? '+967 1 234 567', isDark),
                _buildInfoRow(Icons.email, 'البريد الإلكتروني', _hospital['email'] as String? ?? 'info@hospital.com', isDark),
                _buildInfoRow(Icons.language, 'الموقع الإلكتروني', _hospital['website'] as String? ?? 'www.hospital.com', isDark),
                _buildInfoRow(Icons.location_on, 'العنوان', _hospital['location'] as String? ?? 'صنعاء', isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ التخصصات
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التخصصات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_hospital['specialties'] as List? ?? []).map((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        specialty as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ الخدمات
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخدمات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_hospital['services'] as List? ?? []).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service['icon'] as IconData? ?? Icons.medical_services,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service['label'] as String? ?? 'خدمة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ ساعات العمل
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ساعات العمل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_hospital['workingHours'] as Map? ?? {}).entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          entry.value as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ معرض الصور
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معرض الصور',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (_hospital['gallery'] as List? ?? []).length,
                    itemBuilder: (context, index) {
                      final imageUrl = (_hospital['gallery'] as List)[index] as String;
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ التبويب الثاني: الأطباء
  // ============================================================
  Widget _buildDoctorsTab(bool isDark) {
    final doctors = _hospital['doctors'] as List? ?? [];

    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد أطباء',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return GestureDetector(
          onTap: () => _showDoctorDetails(doctor['id'] as String? ?? ''),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    doctor['image'] as String? ?? ImageKit.doctor1,
                  ),
                  onBackgroundImageError: (e, s) {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'] as String? ?? 'طبيب',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor['specialty'] as String? ?? 'تخصص',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'عرض',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
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
  // ✅ التبويب الثالث: التقييمات
  // ============================================================
  Widget _buildReviewsTab(bool isDark) {
    return Column(
      children: [
        // ✅ متوسط التقييم
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _hospital['rating'].toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star,
                            color: i < (_hospital['rating'] as double? ?? 0).round()
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 12,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_hospital['reviews']} تقييم',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تقييم عام ممتاز',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'تقييم المستشفى',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              return IconButton(
                                icon: Icon(
                                  i < _selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: i < _selectedRating
                                      ? Colors.amber
                                      : Colors.grey,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() => _selectedRating = i + 1);
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'اكتب تعليقك...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ تم إضافة تقييمك بنجاح!'),
                                    backgroundColor: Colors.green,
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
                              child: const Text('إرسال التقييم'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('تقييم'),
              ),
            ],
          ),
        ),

        // ✅ قائمة التقييمات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            review['name'][0],
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    Icons.star,
                                    color: i < (review['rating'] as int)
                                        ? Colors.amber
                                        : Colors.grey[300],
                                    size: 14,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          review['date'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      review['comment'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ✅ الشريط السفلي
  // ============================================================
  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.white,
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
            // ✅ زر الاتصال
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _callHospital,
                icon: const Icon(Icons.phone, color: AppColors.primary),
                label: const Text(
                  'اتصال',
                  style: TextStyle(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ زر حجز موعد
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _showAppointmentDialog,
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text(
                  'حجز موعد',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
    );
  }

  // ============================================================
  // ✅ دوال مساعدة
  // ============================================================
  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
