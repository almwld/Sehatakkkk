import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/bloc/home_bloc/home_bloc.dart';
import 'package:sehatak/presentation/bloc/home_bloc/home_event.dart';
import 'package:sehatak/presentation/bloc/home_bloc/home_state.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_header.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_search_bar.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_banner.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_stats.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_quick_services.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_health_score.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_doctors.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_products.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_hospitals.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_labs.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_pharmacies.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_articles.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_daily_tips.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_community.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;
  final ValueNotifier<bool>? isBottomBarVisible;

  const HomeTab({super.key, this.scrollController, this.isBottomBarVisible});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoggedIn = false;
  String _userName = 'مستخدم';
  int _currentBanner = 0;
  final List<String> _bannerImages = ImageKit.bannerList;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _isLoggedIn = user != null;
        if (user != null) {
          _userName = user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم';
        }
      });
    }
  }

  void _handleScroll() {
    if (widget.scrollController == null || !widget.scrollController!.hasClients) return;

    final position = widget.scrollController!.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    if (widget.isBottomBarVisible != null) {
      if (currentScroll <= 10 || currentScroll >= maxScroll - 10) {
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

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  List<QuickServiceModel> _getQuickServices() {
    return const [
      QuickServiceModel(
        icon: 'assets/images/services/pharmacy.png',
        label: 'صيدلية',
        screen: MedicinesScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/emergency.png',
        label: 'طوارئ',
        screen: EmergencyNumbers(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/medical_community.png',
        label: 'خدمات منزلية',
        screen: ServicesScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/blood_donation.png',
        label: 'تبرع بالدم',
        screen: BloodDonationScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/consultation.png',
        label: 'أطباء',
        screen: DoctorsListScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/laboratory.png',
        label: 'مختبرات',
        screen: LabsListScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/health_tips.png',
        label: 'صحة',
        screen: HealthDashboard(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/wallet.png',
        label: 'محفظة',
        screen: WalletScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/consultation.png',
        label: 'استشارة',
        screen: ConsultationScreen(),
      ),
      QuickServiceModel(
        icon: 'assets/images/services/map_location.png',
        label: 'بالقرب منك',
        screen: InteractiveMapScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController != null) {
        widget.scrollController!.addListener(_handleScroll);
      }
    });

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildShimmerLoader();
        }

        if (state.hasError) {
          return _buildErrorScreen(state.errorMessage ?? 'حدث خطأ');
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(RefreshHomeData());
          },
          color: AppColors.primary,
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
            body: CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                // ✅ 1. SliverAppBar مع HomeHeader
                SliverAppBar(
                  expandedHeight: 90,
                  floating: true,
                  snap: true,
                  pinned: false,
                  backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: HomeHeader(
                      isLoggedIn: _isLoggedIn,
                      userName: _userName,
                      onProfileTap: () => _goTo(context, const PatientProfile()),
                    ),
                  ),
                ),

                // ✅ 2. شريط البحث
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: HomeSearchBar(isDark: isDark),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 3. البانر
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: HomeBanner(
                      images: _bannerImages,
                      onPageChanged: (index) => setState(() => _currentBanner = index),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 4. مؤشر الصحة
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: HomeHealthScore(
                      score: state.healthScore,
                      isDark: isDark,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 5. الإحصائيات
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: HomeStats(isDark: isDark),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 6. الخدمات السريعة
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: HomeQuickServices(
                      isDark: isDark,
                      services: _getQuickServices(),
                      onServiceTap: (screen) => _goTo(context, screen),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 7. الأطباء - مع Lazy Loading
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('أفضل الأطباء', isDark, () => _goTo(context, const DoctorsListScreen())),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.doctors.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildDoctorCard(state.doctors[index], isDark),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 8. المنتجات - SliverGrid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('منتجات صيدلية', isDark, () => _goTo(context, const MedicinesScreen())),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildProductCard(state.products[index], isDark);
                      },
                      childCount: state.products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 9. المستشفيات - SliverGrid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('مستشفيات مميزة', isDark, () => _goTo(context, const HospitalScreen())),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildHospitalCard(state.hospitals[index], isDark);
                      },
                      childCount: state.hospitals.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 10. المختبرات - SliverGrid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('مختبرات مميزة', isDark, () => _goTo(context, const LabsListScreen())),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildLabCard(state.labs[index], isDark);
                      },
                      childCount: state.labs.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 11. الصيدليات - SliverGrid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('صيدليات مميزة', isDark, () => _goTo(context, const PharmacyScreen())),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildPharmacyCard(state.pharmacies[index], isDark);
                      },
                      childCount: state.pharmacies.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 12. المقالات - SliverList
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('أحدث المقالات', isDark, () => _goTo(context, const ArticlesScreen())),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildArticleCard(state.articles[index], isDark);
                      },
                      childCount: state.articles.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 13. النصائح اليومية
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('نصائح يومية', isDark, null),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return HomeDailyTips(isDark: isDark);
                      },
                      childCount: 1,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ✅ 14. مجتمع صحتك
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildSectionHeader('مجتمع صحتك', isDark, null),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return HomeCommunity(
                          isDark: isDark,
                          posts: state.posts,
                          onToggleLike: (id) => context.read<HomeBloc>().add(ToggleLikeEvent(id)),
                        );
                      },
                      childCount: 1,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ دوال بناء البطاقات
  Widget _buildSectionHeader(String title, bool isDark, VoidCallback? onTap) {
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
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text('عرض الكل'),
          ),
      ],
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, bool isDark) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: AppImage(
              imageUrl: doctor.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doctor.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            doctor.specialty,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 12),
              Text(
                ' ${doctor.rating} (${doctor.reviews})',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => _goTo(context, DoctorDetailsScreen(doctorId: doctor.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: const Size(0, 28),
              ),
              child: const Text(
                'حجز موعد',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  imageUrl: product.image,
                  width: double.infinity,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              if (product.discount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${product.discount}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            product.category,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${product.price} ر.ي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(HospitalModel hospital, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: AppImage(
                  imageUrl: hospital.image,
                  width: double.infinity,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        hospital.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: hospital.open ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hospital.open ? 'مفتوح' : 'مغلق',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  hospital.location,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(LabModel lab, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AppImage(
              imageUrl: lab.image,
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lab.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  lab.location,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(PharmacyModel pharmacy, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AppImage(
              imageUrl: pharmacy.image,
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacy.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  pharmacy.location,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(ArticleModel article, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: AppImage(
              imageUrl: article.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.category,
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ دوال التحميل والخطأ
  Widget _buildShimmerLoader() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 16, color: Colors.white)),
                      Container(width: 40, height: 40, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(width: 40, height: 40, color: Colors.white),
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
                _buildShimmerBox(height: 50, radius: 25),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 160),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 80),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 100),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 180),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 200),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({double width = double.infinity, double height = 200, double radius = 16}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<HomeBloc>().add(LoadHomeData()),
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

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_handleScroll);
    }
    super.dispose();
  }
}
