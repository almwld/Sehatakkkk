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
  final CarouselSliderController _carouselController = CarouselSliderController();

  final List<String> _bannerImages = ImageKit.bannerList;

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
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم';
        _isLoggedIn = true;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء الخير 🌤️';
    return 'مساء الخير 🌙';
  }

  Widget _buildBannerCarousel(bool isDark) {
    if (_bannerImages.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text('لا توجد بانرات', style: TextStyle(color: Colors.grey)),
      );
    }

    final safeIndex = _currentBanner.clamp(0, _bannerImages.length - 1);

    return Stack(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: _bannerImages.length,
          itemBuilder: (context, index, realIndex) {
            final isActive = index == safeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              transform: Matrix4.identity()..scale(isActive ? 1.02 : 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isActive ? 0.18 : 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      imageUrl: _bannerImages[index],
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      memCacheWidth: 1200,
                      memCacheHeight: 600,
                      placeholder: Container(
                        color: isDark ? const Color(0xFF1A2540) : Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.45),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 12,
                      left: 12,
                      child: Text(
                        'صحتك معك في كل خطوة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 180,
            initialPage: 0,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enlargeFactor: 0.03,
            autoPlay: _bannerImages.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: _bannerImages.length > 1,
            onPageChanged: (index, reason) {
              if (mounted) setState(() => _currentBanner = index);
            },
          ),
        ),
        if (_bannerImages.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _bannerArrow(
                icon: Icons.arrow_back_ios_new,
                onTap: () => _carouselController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _bannerArrow(
                icon: Icons.arrow_forward_ios,
                onTap: () => _carouselController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.32),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _bannerImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isActive = safeIndex == index;
                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 20 : 8,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${safeIndex + 1}/${_bannerImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _bannerArrow({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
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
                            child: Text(_userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text('${_getGreeting()}، $_userName 👋', style: const TextStyle(color: Colors.white, fontSize: 16))),
                          IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('ابحث عن طبيب، دواء...', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13))),
                          ],
                        ),
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
                _buildBannerCarousel(isDark),
                const SizedBox(height: 16),
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
                const Text('أفضل الأطباء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._topDoctors.map((doctor) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(doctor['name'][0], style: TextStyle(color: AppColors.primary))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor['name'], style: const TextStyle(fontWeight: FontWeight.bold)), Text(doctor['specialty'], style: TextStyle(fontSize: 12, color: Colors.grey))])),
                        Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(doctor['rating'].toString())]),
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
