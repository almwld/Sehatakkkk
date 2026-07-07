import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomBarVisible = true;

  final List<Widget> _screens = [
    const HomeTab(),
    const DoctorsListScreen(),
    const PharmacyScreen(),
    const ChatScreen(),
    const PatientAppointments(),
    const PatientDashboard(),
    const MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isBottomBarVisible) {
          setState(() => _isBottomBarVisible = false);
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isBottomBarVisible) {
          setState(() => _isBottomBarVisible = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _logged => FirebaseAuth.instance.currentUser != null;

  void _auth(VoidCallback a) {
    if (_logged) {
      a();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  void _goTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        height: _isBottomBarVisible
            ? kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 10
            : 0,
        child: ClipRect(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 3 || index == 4 || index == 5) {
                _auth(() => setState(() => _selectedIndex = index));
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: [
              _buildNavItem('home', 'الرئيسية', 0),
              _buildNavItem('doctor', 'الأطباء', 1),
              _buildNavItem('pharmacy', 'الصيدلية', 2),
              _buildNavItem('chat', 'الدردشة', 3, isSpecial: true),
              _buildNavItem('calendar', 'المواعيد', 4),
              _buildNavItem('health_record', 'صحتي', 5),
              _buildNavItem('more', 'المزيد', 6),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconName, String label, int index, {bool isSpecial = false}) {
    final isSelected = _selectedIndex == index;
    final iconPath = 'assets/icons/navigation/$iconName.svg';

    return BottomNavigationBarItem(
      icon: isSpecial
          ? Container(
              margin: const EdgeInsets.only(top: 8),
              child: SvgPicture.asset(
                iconPath,
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            )
          : SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.primary : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
      label: label,
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _currentBanner = 0;
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;

  final List<Map<String, dynamic>> _banners = [
    {'title': 'رعاية صحية متميزة', 'sub': 'احجز موعدك الآن مع أفضل الأطباء', 'image': ImageService.banner1},
    {'title': 'صيدليتك في راحة يدك', 'sub': 'اطلب أدويتك وتصلك في أسرع وقت', 'image': ImageService.banner2},
    {'title': 'مختبرات متطورة', 'sub': 'نتائج دقيقة وسريعة', 'image': ImageService.lab1},
    {'title': 'استشارات طبية فورية', 'sub': 'تحدث مع طبيبك عبر الفيديو والصوت', 'image': ImageService.banner3},
  ];

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageService.doctor1, 'available': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageService.doctor2, 'available': true},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageService.doctor3, 'available': true},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageService.doctor4, 'available': false},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageService.doctor1, 'available': true},
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': Icons.medical_services, 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': Icons.local_pharmacy, 'label': 'صيدلية', 'color': AppColors.success, 'screen': const PharmacyScreen()},
    {'icon': Icons.science, 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': Icons.emergency, 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': Icons.favorite, 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': Icons.wallet, 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': Icons.chat, 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': Icons.calendar_month, 'label': 'مواعيد', 'color': AppColors.primaryDark, 'screen': const PatientAppointments()},
    {'icon': Icons.map, 'label': 'خريطة', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
    {'icon': Icons.shield, 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
    {'icon': Icons.bloodtype, 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
    {'icon': Icons.home_work, 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
  ];

  List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': ImageService.doctor2, 'image': ImageService.banner1, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': ['تعليق 1', 'تعليق 2'], 'shares': 15, 'time': 'منذ ساعة', 'liked': false, 'bookmarked': false},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': ImageService.doctor2, 'image': ImageService.banner2, 'title': 'أهمية الفيتامينات', 'content': 'الفيتامينات عناصر أساسية لصحة الجسم، تأكد من تناولها.', 'likes': 95, 'comments': ['تعليق 1'], 'shares': 8, 'time': 'منذ 3 ساعات', 'liked': false, 'bookmarked': false},
    {'id': 3, 'author': 'د. أحمد المولد', 'avatar': ImageService.doctor1, 'image': ImageService.banner3, 'title': 'صحة القلب', 'content': 'القلب محرك الحياة، احرص على الرياضة والأكل الصحي.', 'likes': 210, 'comments': ['تعليق 1', 'تعليق 2', 'تعليق 3'], 'shares': 22, 'time': 'منذ 5 ساعات', 'liked': true, 'bookmarked': true},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': ImageService.doctor3, 'image': ImageService.pharmacy1, 'title': 'فوائد المشي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 78, 'comments': [], 'shares': 5, 'time': 'منذ يوم', 'liked': false, 'bookmarked': false},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': ImageService.doctor4, 'image': ImageService.pharmacy2, 'title': 'تقوية المناعة', 'content': 'الطعام الصحي هو أساس المناعة القوية.', 'likes': 150, 'comments': ['تعليق 1', 'تعليق 2'], 'shares': 12, 'time': 'منذ يومين', 'liked': false, 'bookmarked': false},
  ];

  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'color': AppColors.info},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'color': AppColors.success},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'color': AppColors.purple},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'color': AppColors.warning},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageService.medicine1, 'category': 'مسكنات'},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageService.medicine2, 'category': 'فيتامينات'},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageService.medicine3, 'category': 'أجهزة طبية'},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageService.medicine4, 'category': 'مضادات حيوية'},
  ];

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _toggleLike(int index) {
    setState(() {
      _communityPosts[index]['liked'] = !_communityPosts[index]['liked'];
      _communityPosts[index]['likes'] += _communityPosts[index]['liked'] ? 1 : -1;
    });
  }

  void _toggleBookmark(int index) {
    setState(() {
      _communityPosts[index]['bookmarked'] = !_communityPosts[index]['bookmarked'];
    });
  }

  void _sharePost(int index) {
    final post = _communityPosts[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم مشاركة: ${post['title']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComments(int index) {
    final post = _communityPosts[index];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التعليقات (${post['comments'].length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            if (post['comments'].isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد تعليقات', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: post['comments'].length,
                  itemBuilder: (context, i) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary)),
                    ),
                    title: Text('تعليق ${i + 1}'),
                    subtitle: Text('منذ دقيقة'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقاً...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
            foregroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Opacity(
                opacity: _appBarOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (logged) _goTo(context, const PatientProfile());
                          else _goTo(context, const LoginScreen());
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: user?.photoURL ?? '',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _shimmerPlaceholder(40, 40, 14),
                            errorWidget: (_, __, ___) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.person, color: primaryColor, size: 22),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          logged ? 'مرحباً، $name' : 'منصة صحتك',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: primaryColor),
                        onPressed: () => _goTo(context, const NotificationsScreen()),
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined, color: primaryColor),
                        onPressed: () => _goTo(context, const CartScreen()),
                      ),
                      if (!logged)
                        TextButton(
                          onPressed: () => _goTo(context, const LoginScreen()),
                          child: Text('تسجيل', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchBar(isDark),
                const SizedBox(height: 16),
                _buildBannerPlaceholder(isDark, primaryColor),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildSectionTitle('خدمات سريعة', isDark),
                const SizedBox(height: 10),
                _buildQuickServicesRow(),
                const SizedBox(height: 24),
                _buildSectionTitle('أفضل الأطباء', isDark),
                const SizedBox(height: 10),
                _buildTopDoctorsRow(),
                const SizedBox(height: 24),
                _buildSectionTitle('منتجات صيدلية', isDark),
                const SizedBox(height: 10),
                _buildProductsRow(),
                const SizedBox(height: 24),
                _buildSectionTitle('نصائح يومية', isDark),
                const SizedBox(height: 10),
                _buildDailyTipsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('مجتمع صحتك', isDark),
                const SizedBox(height: 10),
                ..._communityPosts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final post = entry.value;
                  return _buildCommunityPostCard(post, index, isDark);
                }),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerPlaceholder(double width, double height, double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'ابحث عن طبيب، دواء، أو خدمة...',
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPlaceholder(bool isDark, Color primaryColor) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, color: Colors.white, size: 48),
            const SizedBox(height: 8),
            Text(
              'صحتك - منصة صحتك الشاملة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'icon': Icons.medical_services, 'value': '150+', 'label': 'أطباء', 'color': AppColors.primary},
      {'icon': Icons.people, 'value': '10K+', 'label': 'مرضى', 'color': AppColors.success},
      {'icon': Icons.chat, 'value': '5K+', 'label': 'استشارات', 'color': AppColors.info},
      {'icon': Icons.star, 'value': '4.8', 'label': 'تقييم', 'color': Colors.amber},
    ];

    return Row(
      children: stats.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
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
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildQuickServicesRow() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          final color = service['color'] as Color;
          return GestureDetector(
            onTap: () => _goTo(context, service['screen'] as Widget),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(service['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['label'] as String,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopDoctorsRow() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _topDoctors[index];
          return GestureDetector(
            onTap: () => _goTo(context, DoctorDetailsScreen(doctorId: doctor['id'] as String)),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: doctor['image'],
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _shimmerPlaceholder(55, 55, 12),
                      errorWidget: (_, __, ___) => Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          doctor['specialty'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${doctor['rating']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${doctor['reviews']})',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: doctor['available'] ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
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
        },
      ),
    );
  }

  Widget _buildProductsRow() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product['image'],
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _shimmerPlaceholder(50, 50, 12),
                    errorWidget: (_, __, ___) => Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.medication, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product['category'],
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ),
                const Spacer(),
                Text(
                  '${product['price']} ر.ي',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0D5257),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyTipsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: _dailyTips.length,
      itemBuilder: (context, index) {
        final tip = _dailyTips[index];
        final color = tip['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tip['icon'] as IconData, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                tip['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                tip['subtitle'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityPostCard(Map<String, dynamic> post, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(post['avatar']),
                  child: const Icon(Icons.person, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        post['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          ClipRRect(
            child: CachedNetworkImage(
              imageUrl: post['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(index),
                  child: Icon(
                    post['liked'] ? Icons.favorite : Icons.favorite_border,
                    color: post['liked'] ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post['likes']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _showComments(index),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post['comments'].length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _sharePost(index),
                  child: Icon(
                    Icons.repeat,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post['shares']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleBookmark(index),
                  child: Icon(
                    post['bookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                    color: post['bookmarked'] ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GestureDetector(
              onTap: () => _showComments(index),
              child: Text(
                'عرض جميع التعليقات (${post['comments'].length})',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
