import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/core/services/toast_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // ✅ بيانات افتراضية تظهر فوراً
  final List<String> _bannerImages = [
    'assets/images/services/consultation.png',
    'assets/images/services/emergency.png',
    'assets/images/services/hospital.png',
    'assets/images/services/pharmacy.png',
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية'},
    {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ'},
    {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم'},
    {'icon': 'assets/images/services/consultation.png', 'label': 'أطباء'},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'مختبرات'},
    {'icon': 'assets/images/services/health_tips.png', 'label': 'صحة'},
    {'icon': 'assets/images/services/wallet.png', 'label': 'محفظة'},
  ];

  final List<Map<String, dynamic>> _topDoctors = [
    {'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9},
    {'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8},
    {'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7},
  ];

  bool _isLoggedIn = false;
  String _userName = 'مستخدم';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ محاولة تحميل بيانات المستخدم بأمان
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم';
        _isLoggedIn = true;
      }
    } catch (e) {
      print('⚠️ Error loading user: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء الخير 🌤️';
    return 'مساء الخير 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ✅ AppBar
          SliverToBoxAdapter(
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              _userName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_getGreeting()}، $_userName 👋',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ابحث عن طبيب، دواء...',
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ المحتوى
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ✅ البانر
                CarouselSlider(
                  options: CarouselOptions(height: 150, autoPlay: true, viewportFraction: 0.9),
                  items: _bannerImages.map((url) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(url, fit: BoxFit.cover, width: double.infinity),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ✅ الخدمات السريعة
                const Text('خدمات سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickServices.length,
                    itemBuilder: (context, index) {
                      final service = _quickServices[index];
                      return Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(service['icon'] as String, width: 35, height: 35),
                            const SizedBox(height: 4),
                            Text(service['label'] as String, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ الأطباء
                const Text('أفضل الأطباء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._topDoctors.map((doctor) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(doctor['name'][0], style: TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(doctor['specialty'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(doctor['rating'].toString()),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
