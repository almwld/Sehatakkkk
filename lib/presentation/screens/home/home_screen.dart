import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  bool get _logged => FirebaseAuth.instance.currentUser != null;

  final List<Widget> _screens = const [
    _HomeTab(),
    DoctorsListScreen(),
    PharmacyScreen(),
    ChatScreen(),
    PatientAppointments(),
    PatientDashboard(),
    MoreScreen(),
  ];

  void _auth(VoidCallback a) {
    if (_logged) {
      a();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AuthBloc(),
            child: const LoginScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: _nav(d),
    );
  }

  Widget _nav(bool d) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: d ? const Color(0xFF111D33) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ni(0, Icons.home_rounded, 'الرئيسية'),
            _ni(1, Icons.person_search_rounded, 'الأطباء'),
            _ni(2, Icons.local_pharmacy_rounded, 'الصيدلية'),
            _chat(),
            _ni(4, Icons.calendar_month_rounded, 'المواعيد'),
            _ni(5, Icons.folder_rounded, 'صحتي'),
            _ni(6, Icons.grid_view_rounded, 'المزيد'),
          ],
        ),
      ),
    );
  }

  Widget _ni(int i, IconData ic, String l) {
    final s = _idx == i;
    return GestureDetector(
      onTap: () {
        if (i == 3 || i == 4 || i == 5) {
          _auth(() => setState(() => _idx = i));
        } else {
          setState(() => _idx = i);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, color: s ? AppColors.primary : AppColors.grey, size: 22),
          Text(
            l,
            style: TextStyle(
              fontSize: 10,
              color: s ? AppColors.primary : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chat() {
    return GestureDetector(
      onTap: () => _auth(() => setState(() => _idx = 3)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🏠 _HomeTab - الصفحة الرئيسية اللانهائية
// ============================================================
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _currentBanner = 0;
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;

  // ✅ البانر
  final List<Map<String, dynamic>> _banners = [
    {'title': 'رعاية صحية متميزة', 'sub': 'احجز موعدك الآن مع أفضل الأطباء في اليمن', 'image': ImageService.banner1},
    {'title': 'صيدليتك في راحة يدك', 'sub': 'اطلب أدويتك وتصلك في أسرع وقت', 'image': ImageService.banner2},
    {'title': 'مختبرات متطورة', 'sub': 'نتائج دقيقة وسريعة في مختبراتنا', 'image': ImageService.lab1},
    {'title': 'استشارات طبية فورية', 'sub': 'تحدث مع طبيبك عبر الفيديو والصوت', 'image': ImageService.banner3},
  ];

  // ✅ 6 أطباء نخبة
  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'استشاري باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageService.doctor1, 'available': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'أمراض قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageService.doctor2, 'available': true},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال وحديثي الولادة', 'rating': 4.9, 'reviews': 189, 'image': ImageService.doctor3, 'available': true},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.7, 'reviews': 89, 'image': ImageService.doctor4, 'available': false},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageService.doctor1, 'available': true},
    {'id': '6', 'name': 'د. عمر الجابري', 'specialty': 'عظام ومفاصل', 'rating': 4.6, 'reviews': 145, 'image': ImageService.doctor2, 'available': true},
  ];

  // ✅ الخدمات السريعة (12 خدمة)
  final List<Map<String, dynamic>> _quickServices = [
    {'icon': Icons.medical_services, 'label': 'استشارة', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': Icons.local_pharmacy, 'label': 'صيدلية', 'color': AppColors.success, 'screen': const PharmacyScreen()},
    {'icon': Icons.science, 'label': 'مختبر', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': Icons.emergency, 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': Icons.favorite, 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': Icons.wallet, 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': Icons.chat, 'label': 'استشارة فورية', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': Icons.calendar_month, 'label': 'مواعيد', 'color': AppColors.primaryDark, 'screen': const PatientAppointments()},
    {'icon': Icons.map, 'label': 'خريطة', 'color': Colors.orange, 'screen': const ServicesScreen()},
    {'icon': Icons.shield, 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
    {'icon': Icons.bloodtype, 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const EmergencyNumbers()},
    {'icon': Icons.home_work, 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
  ];

  // ✅ منشورات المجتمع (12 منشور)
  final List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': ImageService.doctor2, 'image': ImageService.banner1, 'title': 'نصائح للعناية بالبشرة في الصيف', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس المناسب.', 'likes': 120, 'comments': 15, 'time': 'منذ ساعة', 'liked': false},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': ImageService.doctor2, 'image': ImageService.banner2, 'title': 'أهمية الفيتامينات للجسم', 'content': 'الفيتامينات عناصر أساسية لصحة الجسم، تأكد من تناولها عبر الطعام أو المكملات.', 'likes': 95, 'comments': 8, 'time': 'منذ 3 ساعات', 'liked': false},
    {'id': 3, 'author': 'د. أحمد المولد', 'avatar': ImageService.doctor1, 'image': ImageService.banner3, 'title': 'كيف تحافظ على صحة قلبك', 'content': 'القلب هو محرك الحياة، احرص على ممارسة الرياضة وتناول الأطعمة الصحية.', 'likes': 210, 'comments': 22, 'time': 'منذ 5 ساعات', 'liked': true},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': ImageService.doctor3, 'image': ImageService.pharmacy1, 'title': 'فوائد المشي اليومي', 'content': 'المشي لمدة 30 دقيقة يومياً يقلل من خطر الإصابة بأمراض القلب والسكري.', 'likes': 78, 'comments': 5, 'time': 'منذ يوم', 'liked': false},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': ImageService.doctor4, 'image': ImageService.pharmacy2, 'title': 'أفضل الأطعمة لتقوية المناعة', 'content': 'الطعام الصحي هو أساس المناعة القوية، احرص على تناول الفواكه والخضروات.', 'likes': 150, 'comments': 12, 'time': 'منذ يومين', 'liked': false},
    {'id': 6, 'author': 'د. فاطمة صديقي', 'avatar': ImageService.doctor1, 'image': ImageService.medicine1, 'title': 'كيف تتغلب على الأرق', 'content': 'النوم الجيد أساس الصحة النفسية والجسدية، اتبع نصائح بسيطة لتحسين جودة نومك.', 'likes': 67, 'comments': 3, 'time': 'منذ 3 أيام', 'liked': false},
    {'id': 7, 'author': 'د. عمر الجابري', 'avatar': ImageService.doctor2, 'image': ImageService.medicine2, 'title': 'فوائد شرب الماء', 'content': 'شرب 8 أكواب من الماء يومياً يحسن صحة الكلى ويقي من الجفاف.', 'likes': 300, 'comments': 30, 'time': 'منذ 4 أيام', 'liked': false},
    {'id': 8, 'author': 'د. ليلى الكبسي', 'avatar': ImageService.doctor3, 'image': ImageService.medicine3, 'title': 'الرياضة وصحة العظام', 'content': 'ممارسة الرياضة بانتظام تقوي العظام وتقلل من خطر الإصابة بهشاشة العظام.', 'likes': 88, 'comments': 7, 'time': 'منذ 5 أيام', 'liked': false},
    {'id': 9, 'author': 'د. ناصر الحمزي', 'avatar': ImageService.doctor4, 'image': ImageService.medicine4, 'title': 'التغذية السليمة للأطفال', 'content': 'التغذية المتوازنة ضرورية لنمو الأطفال بشكل صحي وسليم.', 'likes': 135, 'comments': 18, 'time': 'منذ 6 أيام', 'liked': false},
    {'id': 10, 'author': 'د. رنا الحوثي', 'avatar': ImageService.doctor1, 'image': ImageService.medicine5, 'title': 'كيف تدير التوتر والقلق', 'content': 'التوتر والقلق يمكن السيطرة عليهما من خلال التنفس العميق والتأمل.', 'likes': 99, 'comments': 9, 'time': 'منذ أسبوع', 'liked': false},
    {'id': 11, 'author': 'د. ياسر القبلي', 'avatar': ImageService.doctor2, 'image': ImageService.banner1, 'title': 'فوائد الزنجبيل للهضم', 'content': 'الزنجبيل يساعد في تحسين الهضم وتخفيف الغثيان والالتهابات.', 'likes': 210, 'comments': 25, 'time': 'منذ 8 أيام', 'liked': false},
    {'id': 12, 'author': 'د. منى العرشي', 'avatar': ImageService.doctor3, 'image': ImageService.banner2, 'title': 'كيف توقف التدخين', 'content': 'الإقلاع عن التدخين يحسن الصحة العامة ويقلل من خطر الأمراض المزمنة.', 'likes': 450, 'comments': 50, 'time': 'منذ 10 أيام', 'liked': false},
  ];

  // ✅ المنتجات (4 منتجات)
  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageService.medicine1, 'category': 'مسكنات'},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageService.medicine2, 'category': 'فيتامينات'},
    {'name': 'خافض حرارة للأطفال', 'price': 350, 'image': ImageService.medicine3, 'category': 'أطفال'},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageService.medicine4, 'category': 'أجهزة طبية'},
  ];

  // ✅ النصائح اليومية (6 نصائح)
  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً للحفاظ على صحة الجسم', 'icon': Icons.water_drop, 'color': AppColors.info},
    {'title': 'المشي اليومي', 'subtitle': '30 دقيقة تقلل من أمراض القلب', 'icon': Icons.directions_walk, 'color': AppColors.success},
    {'title': 'النوم الكافي', 'subtitle': '7-8 ساعات ليلاً لصحة أفضل', 'icon': Icons.nights_stay, 'color': AppColors.purple},
    {'title': 'تناول الفواكه', 'subtitle': '5 حصص يومياً لتقوية المناعة', 'icon': Icons.apple, 'color': AppColors.warning},
    {'title': 'الابتعاد عن التدخين', 'subtitle': 'يحسن صحة الرئة والقلب', 'icon': Icons.smoke_free, 'color': Colors.red},
    {'title': 'شرب الشاي الأخضر', 'subtitle': 'مضاد للأكسدة ويحسن التركيز', 'icon': Icons.emoji_nature, 'color': Colors.green},
  ];

  // ✅ الإحصائيات السريعة (4 إحصائيات)
  final List<Map<String, dynamic>> _stats = [
    {'label': 'أطباء', 'value': '150+', 'icon': Icons.medical_services, 'color': AppColors.primary},
    {'label': 'مرضى', 'value': '10K+', 'icon': Icons.people, 'color': AppColors.success},
    {'label': 'استشارات', 'value': '5K+', 'icon': Icons.chat, 'color': AppColors.info},
    {'label': 'تقييم', 'value': '4.8', 'icon': Icons.star, 'color': Colors.amber},
  ];

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _toggleLike(int index) {
    setState(() {
      _communityPosts[index]['liked'] = !_communityPosts[index]['liked'];
      _communityPosts[index]['likes'] += _communityPosts[index]['liked'] ? 1 : -1;
    });
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
          // ✅ AppBar يختفي تدريجياً
          SliverAppBar(
            expandedHeight: 90,
            floating: true,
            pinned: true,
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
                          if (logged) _go(context, const PatientProfile());
                          else _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()));
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              logged ? 'مرحباً، $name' : 'منصة صحتك',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (logged)
                              Text(
                                'حالتك الصحية جيدة',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: primaryColor),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined, color: primaryColor),
                        onPressed: () => _go(context, const CartScreen()),
                      ),
                      if (!logged)
                        TextButton(
                          onPressed: () => _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())),
                          child: Text('تسجيل', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ المحتوى الرئيسي (كل شيء في واجهة واحدة لا نهائية)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1️⃣ حقل البحث
                _searchBar(isDark),
                const SizedBox(height: 16),

                // 2️⃣ البانر المتحرك
                _bannerCarousel(isDark, primaryColor),
                const SizedBox(height: 20),

                // 3️⃣ الإحصائيات السريعة
                _statsRow(),
                const SizedBox(height: 20),

                // 4️⃣ الخدمات السريعة
                _sectionTitle('خدمات سريعة', isDark),
                const SizedBox(height: 10),
                _quickServicesRow(),
                const SizedBox(height: 24),

                // 5️⃣ أفضل الأطباء
                _sectionTitle('أفضل الأطباء', isDark),
                const SizedBox(height: 10),
                _topDoctorsRow(),
                const SizedBox(height: 24),

                // 6️⃣ منتجات صيدلية
                _sectionTitle('منتجات صيدلية', isDark),
                const SizedBox(height: 10),
                _productsRow(),
                const SizedBox(height: 24),

                // 7️⃣ نصائح يومية
                _sectionTitle('نصائح يومية', isDark),
                const SizedBox(height: 10),
                _dailyTipsGrid(),
                const SizedBox(height: 24),

                // 8️⃣ مجتمع صحتك
                _sectionTitle('مجتمع صحتك', isDark),
                const SizedBox(height: 10),
                ..._communityPosts.map((post) => _communityPostCard(post, isDark)),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Shimmer
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

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _searchBar(bool isDark) {
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
            ),
          ),
        ],
      ),
    );
  }

  // ✅ البانر
  Widget _bannerCarousel(bool isDark, Color primaryColor) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
            onPageChanged: (index, reason) => setState(() => _currentBanner = index),
          ),
          items: _banners.map((banner) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(banner['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      banner['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner['sub'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _banners.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _currentBanner = entry.key),
              child: Container(
                width: _currentBanner == entry.key ? 24 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _currentBanner == entry.key
                      ? primaryColor
                      : isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ✅ الإحصائيات
  Widget _statsRow() {
    return Row(
      children: _stats.map((stat) {
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

  // ✅ الخدمات السريعة
  Widget _quickServicesRow() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          final color = service['color'] as Color;
          return GestureDetector(
            onTap: () => _go(context, service['screen'] as Widget),
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(service['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['label'] as String,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ أفضل الأطباء
  Widget _topDoctorsRow() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _topDoctors[index];
          return GestureDetector(
            onTap: () => _go(context, DoctorDetailsScreen(doctorId: doctor['id'])),
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
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _shimmerPlaceholder(60, 60, 12),
                      errorWidget: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
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
                        const SizedBox(height: 2),
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

  // ✅ المنتجات
  Widget _productsRow() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Container(
            width: 130,
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
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _shimmerPlaceholder(60, 60, 12),
                    errorWidget: (_, __, ___) => Container(
                      height: 60,
                      width: 60,
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

  // ✅ النصائح اليومية
  Widget _dailyTipsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: _dailyTips.length,
      itemBuilder: (context, index) {
        final tip = _dailyTips[index];
        final color = tip['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tip['icon'] as IconData, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                tip['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                tip['subtitle'] as String,
                style: TextStyle(
                  fontSize: 8,
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

  // ✅ منشورات المجتمع (نمط إنستغرام)
  Widget _communityPostCard(Map<String, dynamic> post, bool isDark) {
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
          // ✅ رأس المنشور
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

          // ✅ صورة المنشور
          ClipRRect(
            child: CachedNetworkImage(
              imageUrl: post['image'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
          ),

          // ✅ أزرار التفاعل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(_communityPosts.indexOf(post)),
                  child: Icon(
                    post['liked'] ? Icons.favorite : Icons.favorite_border,
                    color: post['liked'] ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.share_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 24,
                ),
                const Spacer(),
                Icon(
                  Icons.bookmark_border,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),

          // ✅ عدد الإعجابات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${post['likes']} إعجاباً',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // ✅ المحتوى
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

          // ✅ عرض التعليقات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'عرض جميع التعليقات (${post['comments']})',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
