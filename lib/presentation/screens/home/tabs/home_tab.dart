import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/health_score_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:sehatak/presentation/screens/home/widgets/quick_services.dart';
import 'package:sehatak/presentation/screens/home/widgets/doctor_card.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  double _healthScore = 0.0;
  
  // ✅ البيانات
  final List<String> _bannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1, 'gender': 'male', 'price': 150, 'available': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2, 'gender': 'male', 'price': 180, 'available': true},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3, 'gender': 'female', 'price': 120, 'available': false},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4, 'gender': 'male', 'price': 140, 'available': true},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5, 'gender': 'female', 'price': 160, 'available': true},
    {'id': '6', 'name': 'د. سعيد العمري', 'specialty': 'جلدية', 'rating': 4.5, 'reviews': 145, 'image': ImageKit.doctor1, 'gender': 'male', 'price': 130, 'available': true},
  ];

  final List<QuickServiceItem> _quickServices = [
    QuickServiceItem(icon: ImageKit.pharmacyIcon, label: 'صيدلية', color: AppColors.success, screen: const MedicinesScreen()),
    QuickServiceItem(icon: ImageKit.emergencyIcon, label: 'طوارئ', color: AppColors.error, screen: const EmergencyNumbers()),
    QuickServiceItem(icon: ImageKit.homeMedical, label: 'خدمات منزلية', color: Colors.brown, screen: const ServicesScreen()),
    QuickServiceItem(icon: ImageKit.donateBlood, label: 'تبرع بالدم', color: Colors.red, screen: const BloodDonationScreen()),
    QuickServiceItem(icon: ImageKit.maleDoctorIcon, label: 'أطباء', color: AppColors.primary, screen: const DoctorsListScreen()),
    QuickServiceItem(icon: ImageKit.lab1, label: 'مختبرات', color: AppColors.purple, screen: const LabsListScreen()),
    QuickServiceItem(icon: ImageKit.medicine1, label: 'صحة', color: AppColors.pink, screen: const HealthDashboard()),
    QuickServiceItem(icon: ImageKit.cartIcon, label: 'محفظة', color: AppColors.amber, screen: const WalletScreen()),
    QuickServiceItem(icon: ImageKit.medicalIcon, label: 'استشارة', color: AppColors.teal, screen: const ConsultationScreen()),
    QuickServiceItem(icon: ImageKit.notificationsIcon, label: 'بالقرب منك', color: Colors.orange, screen: const InteractiveMapScreen()),
    QuickServiceItem(icon: ImageKit.placeholder, label: 'تأمين', color: Colors.blue, screen: const InsuranceCompanies()),
  ];

  // ✅ الإحصائيات
  final List<Map<String, dynamic>> _stats = [
    {'icon': Icons.medical_services, 'value': '150+', 'label': 'أطباء', 'color': AppColors.primary},
    {'icon': Icons.people, 'value': '10K+', 'label': 'مرضى', 'color': AppColors.success},
    {'icon': Icons.chat, 'value': '5K+', 'label': 'استشارات', 'color': AppColors.info},
    {'icon': Icons.star, 'value': '4.8', 'label': 'تقييم', 'color': Colors.amber},
  ];

  // ✅ النصائح اليومية
  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'color': AppColors.info},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'color': AppColors.success},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'color': AppColors.purple},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'color': AppColors.warning},
  ];

  // ✅ المنتجات
  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 20},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageKit.medicine2, 'category': 'فيتامينات', 'discount': 15},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة طبية', 'discount': 10},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageKit.medicine4, 'category': 'مضادات حيوية', 'discount': 0},
    {'name': 'ديكلوفيناك 50mg', 'price': 650, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 5},
    {'name': 'نابروكسين 250mg', 'price': 550, 'image': ImageKit.medicine2, 'category': 'مضادات التهابية', 'discount': 0},
  ];

  final List<Map<String, dynamic>> _featuredHospitals = [
    {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء', 'image': ImageKit.hospital1, 'rating': 4.9, 'phone': '01-234571', 'specialty': 'عام', 'open': true},
    {'id': '2', 'name': 'مستشفى الجمهورية', 'location': 'صنعاء', 'image': ImageKit.hospital2, 'rating': 4.8, 'phone': '01-234572', 'specialty': 'عام', 'open': true},
    {'id': '3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageKit.hospital3, 'rating': 4.7, 'phone': '01-234573', 'specialty': 'أطفال وولادة', 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredLabs = [
    {'id': '1', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء - شارع الأصبحي', 'image': ImageKit.lab1, 'rating': 4.9, 'phone': '01-234567', 'open': true},
    {'id': '2', 'name': 'مختبرات العولقي', 'location': 'صنعاء - شارع الستين', 'image': ImageKit.lab2, 'rating': 4.8, 'phone': '01-234568', 'open': true},
    {'id': '3', 'name': 'مختبرات المأمون', 'location': 'صنعاء - حدة', 'image': ImageKit.lab3, 'rating': 4.7, 'phone': '01-234569', 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredPharmacies = [
    {'id': '1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء - شارع حدة', 'image': ImageKit.pharmacy1, 'rating': 4.9, 'phone': '01-234580', 'open': true},
    {'id': '2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء - شارع الستين', 'image': ImageKit.pharmacy2, 'rating': 4.8, 'phone': '01-234581', 'open': true},
    {'id': '3', 'name': 'صيدلية النهضة', 'location': 'صنعاء - باب اليمن', 'image': ImageKit.pharmacy3, 'rating': 4.7, 'phone': '01-234582', 'open': true},
  ];

  final List<Map<String, dynamic>> _healthArticles = [
    {'title': 'فوائد المشي اليومي', 'category': 'صحة عامة', 'time': 'منذ ساعة', 'image': ImageKit.morningWalk},
    {'title': 'نصائح لتقوية المناعة', 'category': 'تغذية', 'time': 'منذ 3 ساعات', 'image': ImageKit.immuneBoost},
    {'title': 'أهمية النوم الصحي', 'category': 'صحة نفسية', 'time': 'منذ 5 ساعات', 'image': ImageKit.sleepTips},
    {'title': 'العناية بالبشرة في الصيف', 'category': 'جلدية', 'time': 'منذ يوم', 'image': ImageKit.skinCare},
  ];

  // ✅ منشورات المجتمع
  final List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'time': 'منذ ساعة', 'liked': false},
    {'id': 2, 'author': 'د. خالد النخلاني', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'time': 'منذ 3 ساعات', 'liked': false},
    {'id': 3, 'author': 'د. أحمد المولد', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'time': 'منذ 5 ساعات', 'liked': true},
  ];

  @override
  void initState() {
    super.initState();
    _loadHealthScore();
  }

  Future<void> _loadHealthScore() async {
    final score = await HealthScoreService.calculateHealthScore();
    setState(() => _healthScore = score);
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await _loadHealthScore();
    setState(() => _isLoading = false);
  }

  void _toggleLike(int index) {
    setState(() {
      _communityPosts[index]['liked'] = !_communityPosts[index]['liked'];
      _communityPosts[index]['likes'] += _communityPosts[index]['liked'] ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 📊 الإحصائيات
                  _buildStatsRow(),
                  const SizedBox(height: 20),

                  // 🎯 البانر
                  BannerCarousel(images: _bannerImages),
                  const SizedBox(height: 20),

                  // 🚀 الخدمات السريعة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'خدمات سريعة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ServicesScreen()),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  QuickServices(services: _quickServices),
                  const SizedBox(height: 24),

                  // 👨‍⚕️ أفضل الأطباء
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'أفضل الأطباء',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DoctorsListScreen()),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _topDoctors.length > 6 ? 6 : _topDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _topDoctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailsScreen(doctorId: doctor['id'] as String),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 💊 منتجات صيدلية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'منتجات صيدلية',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MedicinesScreen()),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _products.length > 6 ? 6 : _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product, isDark);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 💡 نصائح يومية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نصائح يومية',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _dailyTips.length,
                    itemBuilder: (context, index) {
                      final tip = _dailyTips[index];
                      return _buildDailyTipCard(tip, isDark);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 🏥 مستشفيات مميزة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مستشفيات مميزة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HospitalScreen()),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _featuredHospitals.length > 6 ? 6 : _featuredHospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = _featuredHospitals[index];
                      return _buildHospitalCard(hospital, isDark);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 🧪 مختبرات مميزة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مختبرات مميزة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LabsListScreen()),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _featuredLabs.length > 6 ? 6 : _featuredLabs.length,
                    itemBuilder: (context, index) {
                      final lab = _featuredLabs[index];
                      return _buildLabCard(lab, isDark);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 💊 صيدليات مميزة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'صيدليات مميزة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                        ),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _featuredPharmacies.length > 6 ? 6 : _featuredPharmacies.length,
                    itemBuilder: (context, index) {
                      final pharmacy = _featuredPharmacies[index];
                      return _buildPharmacyCard(pharmacy, isDark);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 📰 مقالات صحية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'أحدث المقالات',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _healthArticles.length,
                    itemBuilder: (context, index) {
                      final article = _healthArticles[index];
                      return _buildArticleCard(article, isDark);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 💬 مجتمع صحتك
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مجتمع صحتك',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._communityPosts.map((post) => _buildCommunityPostCard(post, isDark)),
                  const SizedBox(height: 50),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 الإحصائيات
  Widget _buildStatsRow() {
    return Row(
      children: _stats.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
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
                    fontSize: 14,
                    color: color,
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 💊 بطاقة المنتج
  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicinesScreen())),
      child: Container(
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
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: AppImage(
                      url: product['image'] as String,
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (product['discount'] > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'خصم ${product['discount']}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product['category'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product['price']} ريال',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: AppColors.primary,
                          size: 18,
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
    );
  }

  // 💡 بطاقة النصائح اليومية
  Widget _buildDailyTipCard(Map<String, dynamic> tip, bool isDark) {
    final color = tip['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tip['icon'] as IconData, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            tip['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            tip['subtitle'] as String,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🏥 بطاقة المستشفى
  Widget _buildHospitalCard(Map<String, dynamic> hospital, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalScreen())),
      child: Container(
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AppImage(
                    url: hospital['image'] as String,
                    height: 120,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          hospital['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hospital['open'] == true 
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hospital['open'] == true ? 'مفتوح' : 'مغلق',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hospital['location'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HospitalScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'حجز',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧪 بطاقة المختبر
  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabsListScreen())),
      child: Container(
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AppImage(
                url: lab['image'] as String,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lab['location'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LabsListScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'حجز',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💊 بطاقة الصيدلية
  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen())),
      child: Container(
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AppImage(
                url: pharmacy['image'] as String,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    pharmacy['location'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'طلب',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📰 بطاقة المقال
  Widget _buildArticleCard(Map<String, dynamic> article, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesScreen())),
      child: Container(
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AppImage(
                url: article['image'] as String,
                height: 100,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article['category'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    article['time'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💬 بطاقة منشور المجتمع
  Widget _buildCommunityPostCard(Map<String, dynamic> post, bool isDark) {
    final index = _communityPosts.indexOf(post);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  post['author'][0],
                  style: TextStyle(color: AppColors.primary, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      post['time'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post['content'] as String,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          if (post['image'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                url: post['image'] as String,
                height: 150,
                width: double.infinity,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(index),
                child: Row(
                  children: [
                    Icon(
                      post['liked'] == true ? Icons.favorite : Icons.favorite_border,
                      color: post['liked'] == true ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(Icons.comment, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${post['comments']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(Icons.share, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${post['shares']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
