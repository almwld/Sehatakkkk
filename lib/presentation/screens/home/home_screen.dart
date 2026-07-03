import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
    {
      'title': 'رعاية صحية متميزة',
      'sub': 'احجز موعدك الآن مع أفضل الأطباء في اليمن',
      'image': ImageService.banner1,
    },
    {
      'title': 'صيدليتك في راحة يدك',
      'sub': 'اطلب أدويتك وتصلك في أسرع وقت',
      'image': ImageService.banner2,
    },
    {
      'title': 'استشارات طبية فورية',
      'sub': 'تحدث مع طبيبك عبر الفيديو والصوت',
      'image': ImageService.banner3,
    },
    {
      'title': 'مختبرات متطورة',
      'sub': 'نتائج دقيقة وسريعة في مختبراتنا',
      'image': ImageService.lab1,
    },
  ];

  final List<Map<String, dynamic>> _communityPosts = List.generate(40, (index) {
    final titles = [
      'نصائح للعناية بالبشرة في الصيف',
      'أهمية الفيتامينات للجسم',
      'كيف تحافظ على صحة قلبك',
      'فوائد المشي اليومي',
      'أفضل الأطعمة لتقوية المناعة',
      'كيف تتغلب على الأرق',
      'فوائد شرب الماء',
      'الرياضة وصحة العظام',
      'التغذية السليمة للاطفال',
      'كيف تدير التوتر والقلق',
    ];
    final names = [
      'د. أحمد المولد',
      'د. سارة العمري',
      'د. خالد النخلاني',
      'د. أسماء الهندي',
      'د. محمد العلاي',
      'د. فاطمة صديقي',
      'د. عمر الجابري',
      'د. ليلى الكبسي',
      'د. ناصر الحمزي',
      'د. رنا الحوثي',
    ];
    final avatars = [
      ImageService.doctor1,
      ImageService.doctor2,
      ImageService.doctor3,
      ImageService.doctor4,
      ImageService.doctor1,
      ImageService.doctor2,
      ImageService.doctor3,
      ImageService.doctor4,
      ImageService.doctor1,
      ImageService.doctor2,
    ];
    final images = [
      ImageService.banner1,
      ImageService.banner2,
      ImageService.banner3,
      ImageService.pharmacy1,
      ImageService.pharmacy2,
      ImageService.medicine1,
      ImageService.medicine2,
      ImageService.medicine3,
      ImageService.medicine4,
      ImageService.medicine5,
    ];
    return {
      'id': index + 1,
      'title': titles[index % titles.length],
      'author': names[index % names.length],
      'avatar': avatars[index % avatars.length],
      'image': images[index % images.length],
      'likes': (50 + index * 7) % 200,
      'comments': (10 + index * 3) % 80,
      'time': '${(index % 24) + 1} ساعة',
    };
  });

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
              if (logged) {
                _go(context, const PatientProfile());
              } else {
                _go(
                  context,
                  BlocProvider(
                    create: (_) => AuthBloc(),
                    child: const LoginScreen(),
                  ),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: user?.photoURL ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          logged ? 'مرحباً، $name' : 'منصة صحتك',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
            onPressed: () => _go(context, const CartScreen()),
          ),
          if (!logged)
            TextButton(
              onPressed: () => _go(
                context,
                BlocProvider(
                  create: (_) => AuthBloc(),
                  child: const LoginScreen(),
                ),
              ),
              child: const Text(
                'تسجيل',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            _quickServices(context),
            const SizedBox(height: 22),
            _sectionTitle('جميع الخدمات'),
            const SizedBox(height: 10),
            _allServices(context),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('أفضل الأطباء'),
                TextButton(
                  onPressed: () => _go(context, const DoctorsListScreen()),
                  child: const Text('عرض الكل ›'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _docCard('د. علي المولد', 'استشاري باطنية', '4.9', '1', context),
            const SizedBox(height: 8),
            _docCard('د. فاطمة صديقي', 'طبيبة أطفال', '4.8', '3', context),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('منتجات صيدلية'),
                TextButton(
                  onPressed: () => _go(context, const PharmacyScreen()),
                  child: const Text('عرض الكل ›'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _pharmacyRow(context),
            const SizedBox(height: 22),
            _sectionTitle('مجتمع صحتك'),
            const SizedBox(height: 10),
            _communityPostsList(context, isDark),
            const SizedBox(height: 22),
            _sectionTitle('نصائح يومية'),
            const SizedBox(height: 10),
            _tip('شرب الماء', '8 أكواب يومياً للحفاظ على صحة الجسم', Icons.water_drop, AppColors.info),
            const SizedBox(height: 8),
            _tip('المشي اليومي', '30 دقيقة تقلل من أمراض القلب', Icons.directions_walk, AppColors.success),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
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
                hintText: 'بحث عن أطباء، أدوية، خدمات...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        onPageChanged: (index, reason) {
          setState(() {
            _currentBanner = index;
          });
        },
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
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.1),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  banner['sub'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _quickServices(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _qs('أطباء', Icons.medical_services, AppColors.primary,
            () => _go(context, const DoctorsListScreen())),
        _qs('صيدلية', Icons.local_pharmacy, AppColors.success,
            () => _go(context, const PharmacyScreen())),
        _qs('مختبرات', Icons.science, AppColors.purple,
            () => _go(context, const LabsListScreen())),
        _qs('طوارئ', Icons.emergency, AppColors.error,
            () => _go(context, const EmergencyNumbers())),
        _qs('خريطة', Icons.map, AppColors.info,
            () => _go(context, const ServicesScreen())),
        _qs('صحة', Icons.favorite, AppColors.pink,
            () => _go(context, const HealthDashboard())),
        _qs('محفظة', Icons.account_balance_wallet, AppColors.amber,
            () => _go(context, const WalletScreen())),
        _qs('استشارة', Icons.chat, AppColors.teal,
            () => _go(context, const ConsultationScreen())),
      ],
    );
  }

  Widget _qs(String label, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.12) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _allServices(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.medical_services, 'label': 'الأطباء', 'color': AppColors.primary,
        'screen': const DoctorsListScreen()},
      {'icon': Icons.local_pharmacy, 'label': 'الصيدلية', 'color': AppColors.success,
        'screen': const PharmacyScreen()},
      {'icon': Icons.science, 'label': 'المختبرات', 'color': AppColors.purple,
        'screen': const LabsListScreen()},
      {'icon': Icons.map, 'label': 'المرافق الصحية', 'color': AppColors.info,
        'screen': const ServicesScreen()},
      {'icon': Icons.emergency, 'label': 'الطوارئ', 'color': AppColors.error,
        'screen': const EmergencyNumbers()},
      {'icon': Icons.favorite, 'label': 'الصحة', 'color': AppColors.pink,
        'screen': const HealthDashboard()},
      {'icon': Icons.wallet, 'label': 'المحفظة', 'color': AppColors.amber,
        'screen': const WalletScreen()},
      {'icon': Icons.chat, 'label': 'استشارات', 'color': AppColors.teal,
        'screen': const ConsultationScreen()},
      {'icon': Icons.calendar_month, 'label': 'المواعيد', 'color': AppColors.primaryDark,
        'screen': const PatientAppointments()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () => _go(context, service['screen'] as Widget),
          child: Container(
            decoration: BoxDecoration(
              color: (service['color'] as Color).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  service['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: service['color'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _docCard(String name, String specialty, String rating, String id, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(specialty, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.amber, size: 14),
                  Text(' $rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _go(context, DoctorDetailsScreen(doctorId: id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'حجز',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pharmacyRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _prodCard('باراسيتامول', '500mg', '500 ر.ي', Icons.medication, AppColors.info,
              () => _go(context, const PharmacyScreen())),
          _prodCard('فيتامين د', '1000IU', '1200 ر.ي', Icons.vaccines, AppColors.success,
              () => _go(context, const PharmacyScreen())),
          _prodCard('خافض حرارة', 'للأطفال', '350 ر.ي', Icons.medical_services, AppColors.warning,
              () => _go(context, const PharmacyScreen())),
        ],
      ),
    );
  }

  Widget _prodCard(String name, String detail, String price, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center),
            Text(detail, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _communityPostsList(BuildContext context, bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _communityPosts.length,
        itemBuilder: (context, index) {
          final post = _communityPosts[index];
          return _communityPostCard(post, isDark);
        },
      ),
    );
  }

  Widget _communityPostCard(Map<String, dynamic> post, bool isDark) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: post['image'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 100,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, color: Colors.grey)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 100,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: CachedNetworkImageProvider(post['avatar']),
                      child: const Icon(Icons.person, size: 14),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        post['author'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post['title'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 12),
                    const SizedBox(width: 2),
                    Text('${post['likes']}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 8),
                    const Icon(Icons.comment, color: Colors.grey, size: 12),
                    const SizedBox(width: 2),
                    Text('${post['comments']}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const Spacer(),
                    Text(post['time'], style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(String title, String subtitle, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
