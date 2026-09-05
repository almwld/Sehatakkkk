// ============================================================
// 📁 lib/presentation/screens/home/tabs/home_tab.dart
// 🏠 التاب الرئيسي - الإصدار النهائي
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/app_search_delegate.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;
  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>();
    _bloc.add(const HomeStarted());
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final currentScroll = controller.position.pixels;
    final maxScroll = controller.position.maxScrollExtent;
    final opacity = maxScroll <= 0 ? 1.0 : 1.0 - (currentScroll / maxScroll).clamp(0.0, 0.65);
    final showButton = currentScroll > 400;

    // تحديث حالة التمرير عبر BLoC
    // ملاحظة: تم إزالة HomeScrollUpdate لأن HomeState لا يحتوي على هذه الحقول
    // بدلاً من ذلك، نستخدم setState محلياً أو نضيفها إلى HomeState
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildShimmerLoader(isDark);
        }

        if (state.hasError && !state.isLoaded) {
          return _buildErrorScreen(isDark, state.errorMessage);
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF6F8FA),
          body: RefreshIndicator(
            onRefresh: () async => _bloc.add(const HomeDataRefreshed()),
            color: AppColors.primary,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: _buildCurvedAppBar(state, isDark)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildBannerCarousel(state, isDark),
                      const SizedBox(height: 18),
                      if (state.isLoggedIn) _buildHealthSummary(state, isDark),
                      const SizedBox(height: 20),
                      _buildSectionTitle('الخدمات السريعة', isDark),
                      const SizedBox(height: 8),
                      _buildQuickServices(isDark),
                      const SizedBox(height: 20),
                      if (state.doctors.isNotEmpty) _buildDoctors(state, isDark),
                      if (state.hospitals.isNotEmpty) _buildHospitals(state, isDark),
                      if (state.pharmacies.isNotEmpty) _buildPharmacies(state, isDark),
                      if (state.labs.isNotEmpty) _buildLabs(state, isDark),
                      if (state.articles.isNotEmpty) _buildArticles(state, isDark),
                      if (state.tips.isNotEmpty) _buildTips(state, isDark),
                      if (state.communityPosts.isNotEmpty) _buildCommunity(state, isDark),
                      const SizedBox(height: 80),
                    ]),
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
  // Shimmer Loader
  // ============================================================
  Widget _buildShimmerLoader(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 185, width: double.infinity, color: Colors.white),
            const SizedBox(height: 15),
            Container(height: 165, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
            const SizedBox(height: 20),
            SizedBox(height: 90, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 6, itemBuilder: (_, __) => Container(width: 70, margin: const EdgeInsets.symmetric(horizontal: 5), child: Column(children: [Container(width: 58, height: 58, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), const SizedBox(height: 7), Container(width: 50, height: 8, color: Colors.white)])))),
            const SizedBox(height: 20),
            ...List.generate(4, (_) => Container(height: 190, margin: const EdgeInsets.fromLTRB(16, 0, 16, 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)))),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Error Screen
  // ============================================================
  Widget _buildErrorScreen(bool isDark, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(errorMessage ?? 'حدث خطأ في تحميل البيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text('يرجى التحقق من اتصالك بالإنترنت', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _bloc.add(const HomeDataRefreshed()),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AppBar
  // ============================================================
  Widget _buildCurvedAppBar(HomeState state, bool isDark) {
    return ClipPath(
      clipper: _SideCurvedClipper(),
      child: Container(
        height: 185,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        state.isLoggedIn ? state.userName[0].toUpperCase() : 'م',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isLoggedIn ? '${_getGreeting()}، ${state.userName}' : 'مرحباً بك في صحتك',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.isLoggedIn ? 'كيف تشعر اليوم؟' : 'سجل دخولك للاستفادة',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white, size: 26),
                          onPressed: () {},
                        ),
                        if (state.notificationCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${state.notificationCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => showSearch(context: context, delegate: AppSearchDelegate()),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white, size: 21),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'ابحث عن طبيب، دواء أو خدمة',
                            style: TextStyle(color: Colors.white.withOpacity(0.76), fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.mic_none_rounded, color: Colors.white, size: 21),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء الخير 🌤️';
    return 'مساء الخير 🌙';
  }

  // ============================================================
  // Banner
  // ============================================================
  Widget _buildBannerCarousel(HomeState state, bool isDark) {
    if (state.bannerImages.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('لا توجد بانرات')),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 0.92,
            onPageChanged: (index, reason) => _bloc.add(HomeBannerChanged(index: index)),
          ),
          items: state.bannerImages.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(imageUrl: url, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            state.bannerImages.length,
            (index) {
              final active = index == state.currentBanner;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 20 : 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Health Summary
  // ============================================================
  Widget _buildHealthSummary(HomeState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151F35) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _buildStatItem(Icons.local_fire_department, 'سعرة', state.calories.toInt().toString(), Colors.orange, isDark),
          _buildStatItem(Icons.directions_walk, 'خطوة', state.steps.toInt().toString(), Colors.green, isDark),
          _buildStatItem(Icons.bedtime, 'نوم', state.sleep.toStringAsFixed(1), Colors.deepPurple, isDark),
          _buildStatItem(Icons.favorite, 'نبض', state.heartRate.toInt().toString(), Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF263238))),
          Text(label, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  // ============================================================
  // Section Title
  // ============================================================
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
    );
  }

  // ============================================================
  // Quick Services
  // ============================================================
  Widget _buildQuickServices(bool isDark) {
    final services = [
      {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية'},
      {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ'},
      {'icon': 'assets/images/services/medical_community.png', 'label': 'خدمات منزلية'},
      {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم'},
      {'icon': 'assets/images/services/consultation.png', 'label': 'أطباء'},
      {'icon': 'assets/images/services/laboratory.png', 'label': 'مختبرات'},
      {'icon': 'assets/images/services/health_tips.png', 'label': 'صحة'},
      {'icon': 'assets/images/services/wallet.png', 'label': 'محفظة'},
      {'icon': 'assets/images/services/consultation.png', 'label': 'استشارة'},
      {'icon': 'assets/images/services/map_location.png', 'label': 'بالقرب منك'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  service['icon'] as String,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 40),
                ),
                const SizedBox(height: 6),
                Text(
                  service['label'] as String,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[400] : Colors.grey[800]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // Doctors
  // ============================================================
  Widget _buildDoctors(HomeState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('أفضل الأطباء', isDark),
        const SizedBox(height: 8),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.doctors.length,
            itemBuilder: (context, index) {
              final doctor = state.doctors[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: AppImage(imageUrl: doctor.photoUrl ?? ImageKit.doctor1, height: 90, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(doctor.specialty, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                minimumSize: const Size(0, 28),
                              ),
                              child: const Text('حجز موعد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
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
  // Hospitals
  // ============================================================
  Widget _buildHospitals(HomeState state, bool isDark) {
    return _buildPlaceGrid(
      items: state.hospitals.map((h) => ({
        'id': h.id,
        'name': h.name,
        'location': h.address ?? '',
        'image': h.imageUrl ?? ImageKit.hospital1,
        'rating': h.rating ?? 0,
      })).toList(),
      isDark: isDark,
      title: 'مستشفيات مميزة',
    );
  }

  // ============================================================
  // Pharmacies
  // ============================================================
  Widget _buildPharmacies(HomeState state, bool isDark) {
    return _buildPlaceGrid(
      items: state.pharmacies.map((p) => ({
        'id': p.id,
        'name': p.name,
        'location': p.address ?? '',
        'image': p.imageUrl ?? ImageKit.pharmacy1,
        'rating': p.rating ?? 0,
      })).toList(),
      isDark: isDark,
      title: 'صيدليات مميزة',
    );
  }

  // ============================================================
  // Labs
  // ============================================================
  Widget _buildLabs(HomeState state, bool isDark) {
    return _buildPlaceGrid(
      items: state.labs.map((l) => ({
        'id': l.id,
        'name': l.name,
        'location': l.address ?? '',
        'image': l.imageUrl ?? ImageKit.lab1,
        'rating': l.rating ?? 0,
      })).toList(),
      isDark: isDark,
      title: 'مختبرات مميزة',
    );
  }

  // ============================================================
  // Place Grid
  // ============================================================
  Widget _buildPlaceGrid({
    required List<Map<String, dynamic>> items,
    required bool isDark,
    required String title,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, isDark),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: AppImage(imageUrl: item['image'] as String, height: 90, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(item['location'] as String, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // Articles
  // ============================================================
  Widget _buildArticles(HomeState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('أحدث المقالات', isDark),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: state.articles.length,
          itemBuilder: (context, index) {
            final article = state.articles[index];
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: AppImage(imageUrl: article.imageUrl ?? ImageKit.morningWalk, height: 80, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(article.category ?? 'صحة عامة', style: TextStyle(fontSize: 8, color: AppColors.primary)),
                        ),
                        const SizedBox(height: 4),
                        Text(article.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(article.timeAgo, style: TextStyle(fontSize: 8, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // Tips
  // ============================================================
  Widget _buildTips(HomeState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('نصائح يومية', isDark),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: state.tips.length,
          itemBuilder: (context, index) {
            final tip = state.tips[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    tip.icon ?? 'assets/images/tracking/health.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => Icon(Icons.image, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(tip.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary), textAlign: TextAlign.center),
                  Text(tip.subtitle ?? '', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]), textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // Community
  // ============================================================
  Widget _buildCommunity(HomeState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('مجتمع صحتك', isDark),
        const SizedBox(height: 8),
        ...state.communityPosts.map((post) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(post.userAvatar ?? post.userName[0], style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                          Text(post.timeAgo, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(post.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                if (post.content != null) ...[
                  const SizedBox(height: 4),
                  Text(post.content!, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700]), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppImage(imageUrl: post.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.contain),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                    const SizedBox(width: 4),
                    Text('${post.likes}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.comment, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                    const SizedBox(width: 4),
                    Text('${post.comments}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.share, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                    const SizedBox(width: 4),
                    Text('${post.shares}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    const Spacer(),
                    Icon(Icons.remove_red_eye, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text('${post.views}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================
// Custom Clipper
// ============================================================
class _SideCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 22);
    path.quadraticBezierTo(size.width - 12, size.height, size.width - 34, size.height);
    path.lineTo(34, size.height);
    path.quadraticBezierTo(12, size.height, 0, size.height - 22);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
