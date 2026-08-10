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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ مراقبة التمرير
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      HomeSearchBar(isDark: isDark),
                      const SizedBox(height: 16),
                      HomeBanner(
                        images: _bannerImages,
                        onPageChanged: (index) => setState(() => _currentBanner = index),
                      ),
                      const SizedBox(height: 16),
                      HomeHealthScore(
                        score: state.healthScore,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      HomeStats(isDark: isDark),
                      const SizedBox(height: 16),
                      HomeQuickServices(
                        isDark: isDark,
                        services: _getQuickServices(),
                        onServiceTap: (screen) => _goTo(context, screen),
                      ),
                      const SizedBox(height: 16),
                      HomeDoctors(
                        isDark: isDark,
                        doctors: state.doctors,
                        onDoctorTap: (id) => _goTo(context, DoctorDetailsScreen(doctorId: id)),
                      ),
                      const SizedBox(height: 16),
                      HomeProducts(
                        isDark: isDark,
                        products: state.products,
                      ),
                      const SizedBox(height: 16),
                      HomeHospitals(
                        isDark: isDark,
                        hospitals: state.hospitals,
                      ),
                      const SizedBox(height: 16),
                      HomeLabs(
                        isDark: isDark,
                        labs: state.labs,
                      ),
                      const SizedBox(height: 16),
                      HomePharmacies(
                        isDark: isDark,
                        pharmacies: state.pharmacies,
                      ),
                      const SizedBox(height: 16),
                      HomeArticles(
                        isDark: isDark,
                        articles: state.articles,
                      ),
                      const SizedBox(height: 16),
                      HomeDailyTips(isDark: isDark),
                      const SizedBox(height: 16),
                      HomeCommunity(
                        isDark: isDark,
                        posts: state.posts,
                        onToggleLike: (id) => context.read<HomeBloc>().add(ToggleLikeEvent(id)),
                      ),
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
                _buildShimmerBox(height: 180),
                const SizedBox(height: 20),
                _buildShimmerBox(height: 100),
                const SizedBox(height: 20),
                _buildShimmerBox(height: 80),
                const SizedBox(height: 20),
                _buildShimmerBox(height: 90),
                const SizedBox(height: 20),
                _buildShimmerBox(height: 110),
                const SizedBox(height: 20),
                _buildShimmerBox(height: 200),
                const SizedBox(height: 20),
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
