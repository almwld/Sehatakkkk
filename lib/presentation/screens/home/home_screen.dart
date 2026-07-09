import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
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
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomBarVisible = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

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
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();

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
    _animationController.dispose();
    super.dispose();
  }

  bool get _logged => FirebaseAuth.instance.currentUser != null;

  void _auth(VoidCallback a) {
    if (_logged) { a(); } 
    else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  void _goTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _onTabTap(int index) {
    if (index == 3 || index == 4 || index == 5) {
      _auth(() => setState(() => _selectedIndex = index));
    } else {
      setState(() => _selectedIndex = index);
    }
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        height: _isBottomBarVisible
            ? kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 12
            : 0,
        child: ClipRect(
          child: FadeTransition(
            opacity: _isBottomBarVisible 
                ? const AlwaysStoppedAnimation(1.0) 
                : const AlwaysStoppedAnimation(0.0),
            child: SlideTransition(
              position: _isBottomBarVisible 
                  ? _slideAnimation 
                  : const AlwaysStoppedAnimation(Offset(0, 1)),
              child: ScaleTransition(
                scale: _isBottomBarVisible 
                    ? _scaleAnimation 
                    : const AlwaysStoppedAnimation(0.8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B1121) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: _onTabTap,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: Colors.grey,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    selectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'NotoSansArabicUI',
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'NotoSansArabicUI',
                    ),
                    items: [
                      _buildNavItem('home', 'الرئيسية', 0),
                      _buildNavItem('doctor', 'الأطباء', 1),
                      _buildNavItem('pharmacy', 'الصيدلية', 2),
                      _buildNavItem('chat', 'الدردشة', 3, true),
                      _buildNavItem('calendar', 'مواعيدي', 4),
                      _buildNavItem('health_record', 'صحتي', 5),
                      _buildNavItem('more', 'المزيد', 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String name, String label, int index, [bool special = false]) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(top: special ? 8 : 0),
        transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
        child: ImageService.svgIcon(
          'assets/icons/navigation/$name.svg',
          size: special ? 30 : 24,
          color: color,
        ),
      ),
      label: label,
    );
  }
}

// ============================================================
// 🏠 HomeTab - الشاشة الرئيسية
// ============================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  int _currentBanner = 0;
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // ✅ مؤشر تحميل البانرات
  bool _bannersLoaded = false;

  // ✅ البانر مع Shimmer
  final List<Map<String, dynamic>> _banners = [
    {'title': 'رعاية صحية متميزة', 'sub': 'احجز موعدك الآن مع أفضل الأطباء', 'image': ImageService.banner1},
    {'title': 'صيدليتك في راحة يدك', 'sub': 'اطلب أدويتك وتصلك في أسرع وقت', 'image': ImageService.banner2},
    {'title': 'مختبرات متطورة', 'sub': 'نتائج دقيقة وسريعة', 'image': ImageService.banner3},
  ];

  // ✅ أفضل الأطباء
  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageService.doctor1, 'available': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageService.doctor2, 'available': true},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageService.doctor3, 'available': true},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageService.doctor4, 'available': false},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageService.doctor5, 'available': true},
  ];

  // ✅ الخدمات السريعة
  final List<Map<String, dynamic>> _quickServices = [
    {'icon': Icons.medical_services, 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': Icons.local_pharmacy, 'label': 'صيدلية', 'color': AppColors.success, 'screen': const PharmacyScreen()},
    {'icon': Icons.science, 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': Icons.emergency, 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': Icons.favorite, 'label': 'صحتي', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': Icons.wallet, 'label': 'محفظتي', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': Icons.chat, 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': Icons.calendar_month, 'label': 'مواعيد', 'color': AppColors.primaryDark, 'screen': const PatientAppointments()},
    {'icon': Icons.map, 'label': 'خريطة', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
    {'icon': Icons.shield, 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
    {'icon': Icons.bloodtype, 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
    {'icon': Icons.home_work, 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
  ];

  // ✅ منشورات المجتمع
  List<Map<String, dynamic>> _communityPosts = [
    {
      'id': 1,
      'author': 'د. سارة العمري',
      'avatar': ImageService.doctor2,
      'image': ImageService.banner1,
      'title': 'نصائح للعناية بالبشرة في الصيف',
      'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس الطبيعي والمناسب لبشرتك لتفادي التصبغات الحادة والتجاعيد المبكرة.',
      'likes': 120,
      'comments': [
        {'author': 'أحمد', 'text': 'نصائح رائعة جداً!', 'time': 'منذ 5 دقائق'},
        {'author': 'سارة', 'text': 'شكراً دكتورة على المعلومات القيمة', 'time': 'منذ 10 دقائق'},
      ],
      'shares': 15,
      'time': 'منذ ساعة',
      'liked': false,
      'bookmarked': false,
    },
    {
      'id': 2,
      'author': 'د. خالد النخلاني',
      'avatar': ImageService.doctor2,
      'image': ImageService.banner2,
      'title': 'أهمية الفيتامينات لصحة الجسم',
      'content': 'الفيتامينات والمعادن عناصر أساسية لصحة الجسم وعمل الخلايا، تأكد من إجراء فحص دوري كل 6 أشهر لنسب الفيتامينات الأساسية خاصة D و B12.',
      'likes': 95,
      'comments': [
        {'author': 'محمد', 'text': 'معلومات مفيدة جداً', 'time': 'منذ ساعة'},
      ],
      'shares': 8,
      'time': 'منذ 3 ساعات',
      'liked': false,
      'bookmarked': false,
    },
    {
      'id': 3,
      'author': 'د. أحمد المولد',
      'avatar': ImageService.doctor1,
      'image': ImageService.banner3,
      'title': 'صحة القلب - عادات يومية',
      'content': 'القلب هو محرك الحياة الأساسي، احرص على ممارسة رياضة المشي السريع لمدة نصف ساعة على الأقل يومياً والابتعاد الكامل عن الأطعمة الغنية بالدهون المهدرجة.',
      'likes': 210,
      'comments': [
        {'author': 'ليلى', 'text': 'دائماً تقدم معلومات قيمة', 'time': 'منذ 30 دقيقة'},
        {'author': 'ناصر', 'text': 'شكراً دكتور، ننتظر المزيد', 'time': 'منذ ساعتين'},
        {'author': 'منى', 'text': 'أفضل طبيب قلب في اليمن', 'time': 'منذ 3 ساعات'},
      ],
      'shares': 22,
      'time': 'منذ 5 ساعات',
      'liked': true,
      'bookmarked': true,
    },
    {
      'id': 4,
      'author': 'د. أسماء الهندي',
      'avatar': ImageService.doctor3,
      'image': ImageService.pharmacy1,
      'title': 'فوائد المشي 30 دقيقة يومياً',
      'content': 'المشي المنتظم لمدة 30 دقيقة يومياً يقلل من خطر الإصابة بأمراض القلب والسكري من النوع الثاني، ويحسن المزاج ويساعد في فقدان الوزن.',
      'likes': 78,
      'comments': [],
      'shares': 5,
      'time': 'منذ يوم',
      'liked': false,
      'bookmarked': false,
    },
    {
      'id': 5,
      'author': 'د. محمد العلاي',
      'avatar': ImageService.doctor4,
      'image': ImageService.pharmacy2,
      'title': 'تقوية المناعة بالأغذية الطبيعية',
      'content': 'الطعام الصحي هو أساس المناعة القوية. احرص على تناول الثوم، الزنجبيل، الفواكه الغنية بفيتامين C، والخضروات الورقية الداكنة بشكل يومي.',
      'likes': 150,
      'comments': [
        {'author': 'ريما', 'text': 'وصفات رائعة جربتها وفعلاً مفيدة', 'time': 'منذ ساعة'},
        {'author': 'سامي', 'text': 'شكراً على النصائح القيمة', 'time': 'منذ ساعتين'},
      ],
      'shares': 12,
      'time': 'منذ يومين',
      'liked': false,
      'bookmarked': false,
    },
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
    final comments = post['comments'] as List<dynamic>;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التعليقات (${comments.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: comments.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تعليقات بعد',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (context, i) {
                          final comment = comments[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Text(
                                    comment['author'][0],
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['author'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        comment['text'],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      Text(
                                        comment['time'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
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
              const Divider(),
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
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            final newComment = {
                              'author': 'مستخدم',
                              'text': value,
                              'time': 'الآن',
                            };
                            _communityPosts[index]['comments'].add(newComment);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إضافة تعليقك!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
    
    // ✅ محاكاة تحميل البانرات
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _bannersLoaded = true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
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
                          else _goTo(context, const AuthScreen());
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            name.isNotEmpty ? name[0] : 'م',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                _buildBannerCarousel(isDark, primaryColor),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildSectionTitleWithAction('خدمات سريعة', 'عرض الكل', isDark, () {
                  _goTo(context, const ServicesScreen());
                }),
                const SizedBox(height: 10),
                _buildQuickServicesRow(),
                const SizedBox(height: 24),
                _buildSectionTitleWithAction('أفضل الأطباء', 'عرض الكل', isDark, () {
                  _goTo(context, const DoctorsListScreen());
                }),
                const SizedBox(height: 10),
                _buildTopDoctorsRow(),
                const SizedBox(height: 24),
                _buildSectionTitleWithAction('منتجات صيدلية', 'عرض الكل', isDark, () {
                  _goTo(context, const PharmacyScreen());
                }),
                const SizedBox(height: 10),
                _buildProductsRow(),
                const SizedBox(height: 24),
                _buildSectionTitleWithAction('نصائح يومية', '', isDark, null),
                const SizedBox(height: 10),
                _buildDailyTipsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitleWithAction('مجتمع صحتك', 'عرض الكل', isDark, () {
                  _goTo(context, const HealthCommunityScreen());
                }),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _goTo(context, const HealthCommunityScreen());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_comment_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ✅ دالة البحث
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

  // ✅ البانر المتحرك مع Shimmer
  Widget _buildBannerCarousel(bool isDark, Color primaryColor) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
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
                  image: AssetImage(banner['image']),
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
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
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
          mainAxisAlignment: MainAxisAlignment.center,
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

  // ✅ عنوان القسم مع زر "عرض الكل"
  Widget _buildSectionTitleWithAction(String title, String actionLabel, bool isDark, VoidCallback? onTap) {
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
        if (actionLabel.isNotEmpty && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ✅ الخدمات السريعة
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

  // ✅ أفضل الأطباء
  Widget _buildTopDoctorsRow() {
    if (_topDoctors.isEmpty) {
      return _buildEmptyState('لا يوجد أطباء حالياً');
    }
    
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
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 55,
                          height: 55,
                          color: Colors.grey[300],
                        ),
                      ),
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

  // ✅ المنتجات
  Widget _buildProductsRow() {
    if (_products.isEmpty) {
      return _buildEmptyState('لا توجد منتجات حالياً');
    }
    
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
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Colors.grey[300],
                      ),
                    ),
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

  // ✅ النصائح اليومية
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

  // ✅ حالة فارغة
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  // ✅ منشورات المجتمع
  Widget _buildCommunityPostCard(Map<String, dynamic> post, int index, bool isDark) {
    final comments = post['comments'] as List<dynamic>;
    
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
                  radius: 22,
                  backgroundImage: CachedNetworkImageProvider(post['avatar']),
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
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: post['image'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: post['image'],
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 280,
                  color: Colors.grey[300],
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 280,
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
                  onTap: () => _toggleLike(index),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      post['liked'] ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(post['liked']),
                      color: post['liked'] ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${post['likes']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _showComments(index),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 26,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${comments.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _sharePost(index),
                  child: Icon(
                    Icons.repeat,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 26,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${post['shares']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleBookmark(index),
                  child: Icon(
                    post['bookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                    color: post['bookmarked'] ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          // ✅ النص
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post['likes']} إعجاب',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: '${post['author']} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: post['title'],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                if (comments.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showComments(index),
                    child: Text(
                      'عرض جميع التعليقات (${comments.length})',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                if (comments.isNotEmpty)
                  ...comments.take(2).map((comment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: '${comment['author']} ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: comment['text'],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
