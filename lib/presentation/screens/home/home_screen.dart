import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import 'package:sehatak/presentation/widgets/service_icon_widget.dart';
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
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
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
// 🏠 _HomeTab - الصفحة الرئيسية
// ============================================================
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _currentBanner = 0;

  final List<Map<String, dynamic>> _banners = [
    {'title': 'رعاية صحية متميزة', 'sub': 'احجز موعدك الآن مع أفضل الأطباء في اليمن', 'image': ImageService.banner1},
    {'title': 'صيدليتك في راحة يدك', 'sub': 'اطلب أدويتك وتصلك في أسرع وقت', 'image': ImageService.banner2},
    {'title': 'استشارات طبية فورية', 'sub': 'تحدث مع طبيبك عبر الفيديو والصوت', 'image': ImageService.banner3},
    {'title': 'مختبرات متطورة', 'sub': 'نتائج دقيقة وسريعة في مختبراتنا', 'image': ImageService.lab1},
  ];

  // ✅ الخدمات السريعة
  final List<Map<String, dynamic>> _services = [
    {'icon': AppIcons.doctor, 'label': 'أطباء', 'screen': const DoctorsListScreen()},
    {'icon': AppIcons.pharmacy, 'label': 'صيدلية', 'screen': const PharmacyScreen()},
    {'icon': AppIcons.labBlood, 'label': 'مختبرات', 'screen': const LabsListScreen()},
    {'icon': AppIcons.navEmergency, 'label': 'طوارئ', 'screen': const EmergencyNumbers()},
    {'icon': AppIcons.navVideoCall, 'label': 'استشارة', 'screen': const ConsultationScreen()},
    {'icon': AppIcons.navHealthRecord, 'label': 'صحة', 'screen': const HealthDashboard()},
    {'icon': AppIcons.moreMenu, 'label': 'خدمات', 'screen': const ServicesScreen()},
  ];

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
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
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                ),
              ),
            ),
          ),
        ),
        title: Text(logged ? 'مرحباً، $name' : 'منصة صحتك', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () => _go(context, const NotificationsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
            onPressed: () => _go(context, const CartScreen()),
          ),
          if (!logged)
            TextButton(
              onPressed: () => _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())),
              child: const Text('تسجيل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(isDark),
            const SizedBox(height: 16),
            _bannerCarousel(isDark),
            const SizedBox(height: 16),
            _sectionTitle('خدمات سريعة'),
            const SizedBox(height: 10),
            _quickServicesRow(),
            const SizedBox(height: 22),
            _sectionTitle('أفضل الأطباء'),
            const SizedBox(height: 10),
            _doctorsRow(),
            const SizedBox(height: 22),
            _sectionTitle('نصائح يومية'),
            const SizedBox(height: 10),
            _dailyTipsGrid(),
            const SizedBox(height: 22),
            _sectionTitle('مجتمع صحتك'),
            const SizedBox(height: 10),
            _communityPostsRow(),
            const SizedBox(height: 50),
          ],
        ),
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

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _searchBar(bool isDark) => Container(
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
              hintText: 'بحث عن أطباء، أدوية، خدمات...',
              hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _bannerCarousel(bool isDark) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 170,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
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
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.1)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(banner['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                const SizedBox(height: 4),
                Text(banner['sub'], style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12), textAlign: TextAlign.right),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ✅ خدمات سريعة
  Widget _quickServicesRow() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          final color = AppColors.primary;
          return ServiceIconWidget(
            iconPath: service['icon'] as String,
            label: service['label'] as String,
            onTap: () => _go(context, service['screen'] as Widget),
            iconColor: color,
          );
        },
      ),
    );
  }

  // ✅ أفضل الأطباء
  Widget _doctorsRow() {
    final doctors = [
      {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'image': ImageService.doctor1},
      {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'image': ImageService.doctor2},
      {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'image': ImageService.doctor3},
      {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'عظام', 'rating': 4.6, 'image': ImageService.doctor4},
      {'id': '5', 'name': 'د. سارة العمري', 'specialty': 'نساء وولادة', 'rating': 4.8, 'image': ImageService.doctor1},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return GestureDetector(
            onTap: () => _go(context, DoctorDetailsScreen(doctorId: doctor["id"] as String)),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: doctor["image"] as String,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _shimmerPlaceholder(50, 50, 10),
                      errorWidget: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(doctor["name"] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(doctor["specialty"] as String, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Row(children: [const Icon(Icons.star, color: Colors.amber, size: 12), const SizedBox(width: 2), Text('${doctor['rating']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
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

  // ✅ نصائح يومية
  Widget _dailyTipsGrid() {
    final tips = [
      {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'color': AppColors.info},
      {'title': 'المشي اليومي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'color': AppColors.success},
      {'title': 'النوم الكافي', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'color': AppColors.purple},
      {'title': 'تناول الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'color': AppColors.warning},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
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
              Icon(tip['icon'] as IconData, color: color, size: 30),
              const SizedBox(height: 8),
              Text(tip['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(tip['subtitle'] as String, style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  // ✅ منشورات المجتمع
  Widget _communityPostsRow() {
    final posts = List.generate(10, (index) {
      final titles = ['نصائح للعناية بالبشرة', 'أهمية الفيتامينات', 'صحة القلب', 'فوائد المشي', 'تقوية المناعة'];
      final names = ['د. سارة العمري', 'د. خالد النخلاني', 'د. أحمد المولد', 'د. أسماء الهندي', 'د. محمد العلاي'];
      final images = [ImageService.banner1, ImageService.banner2, ImageService.banner3, ImageService.pharmacy1, ImageService.pharmacy2];
      return {
        'id': index + 1,
        'title': titles[index % titles.length],
        'author': names[index % names.length],
        'avatar': ImageService.doctor1,
        'image': images[index % images.length],
        'likes': (50 + index * 7) % 200,
        'comments': (10 + index * 3) % 80,
        'time': '${(index % 24) + 1} ساعة',
      };
    });

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: CachedNetworkImage(
                    imageUrl: post["image"] as String,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _shimmerPlaceholder(double.infinity, 100, 0),
                    errorWidget: (_, __, ___) => Container(height: 100, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, color: Colors.grey))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 14, backgroundImage: CachedNetworkImageProvider(post["avatar"] as String), child: const Icon(Icons.person, size: 14)),
                          const SizedBox(width: 6),
                          Expanded(child: Text(post["author"] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(post["title"] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 12),
                          const SizedBox(width: 2),
                          Text('${post['likes']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(width: 8),
                          const Icon(Icons.comment, color: Colors.grey, size: 12),
                          const SizedBox(width: 2),
                          Text('${post['comments']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const Spacer(),
                          Text(post["time"] as String, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
