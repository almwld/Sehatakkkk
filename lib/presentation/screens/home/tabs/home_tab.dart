import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/health_score_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = 'مستخدم';
  int _currentBanner = 0;
  bool _hasError = false;
  String _errorMessage = '';
  double _healthScore = 0.0;
  
  final List<String> _bannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1, 'gender': 'male'},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2, 'gender': 'male'},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3, 'gender': 'female'},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4, 'gender': 'male'},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5, 'gender': 'female'},
  ];

  // ✅ أيقونات الخدمات السريعة - من مجلد services
  final List<Map<String, dynamic>> _quickServices = [
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية', 'color': AppColors.success, 'screen': const MedicinesScreen()},
    {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': 'assets/images/services/medical_community.png', 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
    {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': 'assets/images/services/health_tips.png', 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': 'assets/images/services/wallet.png', 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': 'assets/images/services/map_location.png', 'label': 'بالقرب منك', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
  ];

  // ✅ الإحصائيات
  final List<Map<String, dynamic>> _stats = [
    {'icon': Icons.local_fire_department, 'value': '2,450', 'label': 'سعرة حرارية', 'color': Colors.orange, 'subtitle': 'اليوم'},
    {'icon': Icons.directions_walk, 'value': '8,542', 'label': 'خطوة', 'color': Colors.green, 'subtitle': 'اليوم'},
    {'icon': Icons.bedtime, 'value': '7.5', 'label': 'ساعات النوم', 'color': Colors.purple, 'subtitle': 'الليلة الماضية'},
    {'icon': Icons.favorite, 'value': '72', 'label': 'نبضة/دقيقة', 'color': Colors.red, 'subtitle': 'الآن'},
  ];

  // ✅ النصائح اليومية
  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'color': AppColors.info, 'content': 'شرب 8 أكواب من الماء يومياً يحسن صحة البشرة ويساعد في التخلص من السموم ويحسن وظائف الكلى.'},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'color': AppColors.success, 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري ويعزز الصحة النفسية ويحسن جودة النوم.'},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'color': AppColors.purple, 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية ويساعد في تقوية الذاكرة والمناعة.'},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'color': AppColors.warning, 'content': 'تناول 5 حصص من الفواكه والخضار يومياً يوفر الفيتامينات والمعادن الضرورية للجسم ويعزز المناعة.'},
  ];

  // ✅ المنتجات
  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 20},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageKit.medicine2, 'category': 'فيتامينات', 'discount': 15},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة طبية', 'discount': 10},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageKit.medicine4, 'category': 'مضادات حيوية', 'discount': 0},
    {'name': 'ديكلوفيناك 50mg', 'price': 650, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 5},
    {'name': 'نابروكسين 250mg', 'price': 550, 'image': ImageKit.medicine2, 'category': 'مضادات التهابية', 'discount': 10},
    {'name': 'أسبرين 100mg', 'price': 300, 'image': ImageKit.medicine3, 'category': 'مسكنات', 'discount': 0},
    {'name': 'إيبوبروفين 400mg', 'price': 750, 'image': ImageKit.medicine4, 'category': 'مسكنات', 'discount': 5},
  ];

  // ✅ مستشفيات مميزة
  final List<Map<String, dynamic>> _featuredHospitals = [
    {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء', 'image': ImageKit.hospital1, 'rating': 4.9, 'phone': '01-234571', 'specialty': 'عام', 'open': true},
    {'id': '2', 'name': 'مستشفى آزال', 'location': 'صنعاء', 'image': ImageKit.hospital2, 'rating': 4.8, 'phone': '01-234572', 'specialty': 'خاص', 'open': true},
    {'id': '3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageKit.hospital3, 'rating': 4.7, 'phone': '01-234573', 'specialty': 'أطفال وولادة', 'open': true},
    {'id': '4', 'name': 'مستشفى الكويت', 'location': 'صنعاء', 'image': ImageKit.hospital4, 'rating': 4.8, 'phone': '01-234574', 'specialty': 'جراحة', 'open': true},
    {'id': '5', 'name': 'المستشفى الجمهوري', 'location': 'صنعاء', 'image': ImageKit.hospital5, 'rating': 4.6, 'phone': '01-234575', 'specialty': 'حكومي', 'open': true},
    {'id': '6', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'image': ImageKit.hospital6, 'rating': 4.5, 'phone': '01-234576', 'specialty': 'حكومي', 'open': true},
  ];

  // ✅ مختبرات مميزة
  final List<Map<String, dynamic>> _featuredLabs = [
    {'id': '1', 'name': 'مختبرات الرازي', 'location': 'صنعاء - باب اليمن', 'image': ImageKit.lab1, 'rating': 4.9, 'phone': '01-234567', 'open': true},
    {'id': '2', 'name': 'مختبرات العولقي', 'location': 'صنعاء - شارع الستين', 'image': ImageKit.lab2, 'rating': 4.8, 'phone': '01-234568', 'open': true},
    {'id': '3', 'name': 'مختبرات المأمون', 'location': 'صنعاء - حدة', 'image': ImageKit.lab3, 'rating': 4.7, 'phone': '01-234569', 'open': true},
    {'id': '4', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء - شارع الأصبحي', 'image': ImageKit.lab1, 'rating': 4.6, 'phone': '01-234570', 'open': true},
    {'id': '5', 'name': 'مختبرات النخبة', 'location': 'صنعاء - التحرير', 'image': ImageKit.lab2, 'rating': 4.5, 'phone': '01-234571', 'open': true},
    {'id': '6', 'name': 'مختبرات اليمن الحديثة', 'location': 'صنعاء - شارع الزبيري', 'image': ImageKit.lab3, 'rating': 4.4, 'phone': '01-234572', 'open': true},
  ];

  // ✅ صيدليات مميزة
  final List<Map<String, dynamic>> _featuredPharmacies = [
    {'id': '1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء - شارع حدة', 'image': ImageKit.pharmacy1, 'rating': 4.9, 'phone': '01-234580', 'open': true},
    {'id': '2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء - شارع الستين', 'image': ImageKit.pharmacy2, 'rating': 4.8, 'phone': '01-234581', 'open': true},
    {'id': '3', 'name': 'صيدلية النهضة', 'location': 'صنعاء - باب اليمن', 'image': ImageKit.pharmacy3, 'rating': 4.7, 'phone': '01-234582', 'open': true},
    {'id': '4', 'name': 'صيدلية اليمن الحديثة', 'location': 'صنعاء - شارع الزبيري', 'image': ImageKit.pharmacy1, 'rating': 4.6, 'phone': '01-234583', 'open': true},
    {'id': '5', 'name': 'صيدلية الشفاء', 'location': 'صنعاء - حدة', 'image': ImageKit.pharmacy2, 'rating': 4.5, 'phone': '01-234584', 'open': false},
    {'id': '6', 'name': 'صيدلية الأمانة', 'location': 'صنعاء - التحرير', 'image': ImageKit.pharmacy3, 'rating': 4.4, 'phone': '01-234585', 'open': true},
  ];

  // ✅ مقالات صحية
  final List<Map<String, dynamic>> _healthArticles = [
    {'title': 'فوائد المشي اليومي', 'category': 'صحة عامة', 'time': 'منذ ساعة', 'image': ImageKit.morningWalk},
    {'title': 'نصائح لتقوية المناعة', 'category': 'تغذية', 'time': 'منذ 3 ساعات', 'image': ImageKit.immuneBoost},
    {'title': 'أهمية النوم الصحي', 'category': 'صحة نفسية', 'time': 'منذ 5 ساعات', 'image': ImageKit.sleepTips},
    {'title': 'العناية بالبشرة في الصيف', 'category': 'جلدية', 'time': 'منذ يوم', 'image': ImageKit.skinCare},
  ];

  // ✅ منشورات المجتمع
  final List<Map<String, dynamic_communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': 'س', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'time': 'منذ ساعة', 'liked': false, 'commentList': ['نصائح رائعة!', 'شكراً دكتورة', 'مفيد جداً']},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': 'خ', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'time': 'منذ 3 ساعات', 'liked': false, 'commentList': ['معلومة قيمة', 'سأطبقها']},
    {'id': 3, 'author': 'د. أحمد المؤيد', 'avatar': 'أ', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'time': 'منذ 5 ساعات', 'liked': true, 'commentList': ['أحسنت', 'مفيد جداً', 'شكراً دكتور']},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': 'ه', 'image': ImageKit.immuneBoost, 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.', 'likes': 78, 'comments': 5, 'shares': 3, 'time': 'منذ يوم', 'liked': false, 'commentList': ['معلومات مفيدة', 'شكراً']},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': 'م', 'image': ImageKit.sleepTips, 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.', 'likes': 150, 'comments': 12, 'shares': 7, 'time': 'منذ يومين', 'liked': false, 'commentList': ['سأطبق هذه النصائح', 'مفيد']},
  ];

  double _caloriesAnim = 0;
  double _stepsAnim = 0;
  double _sleepAnim = 0;
  double _heartAnim = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _loadUserData();
      await _loadHealthScore();
      _startAnimation();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في التهيئة: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'حدث خطأ في تحميل البيانات';
        });
      }
    }
  }

  void _loadUserData() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          if (user != null) {
            _userName = user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم';
          }
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل بيانات المستخدم: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userName = 'مستخدم';
        });
      }
    }
  }

  Future<void> _loadHealthScore() async {
    try {
      final score = await HealthScoreService.calculateHealthScore();
      if (mounted) {
        setState(() => _healthScore = score);
      }
    } catch (e) {
      debugPrint('❌ خطأ في حساب درجة الصحة: $e');
      if (mounted) {
        setState(() => _healthScore = 0.0);
      }
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _caloriesAnim = 2450;
          _stepsAnim = 8542;
          _sleepAnim = 7.5;
          _heartAnim = 72;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      _loadUserData();
      await Future.delayed(const Duration(seconds: 1));
      await _loadHealthScore();
      if (mounted) {
        setState(() {
          _hasError = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'حدث خطأ في تحديث البيانات';
          _isLoading = false;
        });
      }
    }
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ✅ دوال المجتمع
  void _toggleLike(int index) {
    setState(() {
   _communityPosts[index]['liked'] _communityPosts[index]['liked'];
   _communityPosts[index]['likes'] _communityPosts[index]['liked'] ? 1 : -1;
    });
  }

  void _sharePost(int index) {
    final post_communityPosts[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم مشاركة: ${post['title']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComments(Map<String, dynamic> post, int index) {
    final TextEditingController _commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التعليقات (${post['comments']})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: (post['commentList'] as List).length,
                    itemBuilder: (context, i) {
                      final comment = (post['commentList'] as List)[i];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            'م',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          comment,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          'منذ دقيقة',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'أضف تعليقاً...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              setStateModal(() {
                                (post['commentList'] as List).add(_commentController.text);
                                post['comments'] = (post['comments'] as int) + 1;
                              });
                              _commentController.clear();
                            }
                          },
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
    );
  }

  void _showTipDetails(Map<String, dynamic> tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(tip['icon'] as IconData, color: tip['color'] as Color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip['subtitle'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 24),
            Text(
              tip['content'] as String,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('أغلقت'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دوال بناء الواجهة
  Widget _buildServiceIcon(String iconPath, Color color, {double size = 32}) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return AppImage(url: iconPath, width: size, height: size);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildShimmerLoader();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('منتجات صيدلية', isDark, 'عرض الكل', 
                    () => _goTo(context, const MedicinesScreen())),
                  const SizedBox(height: 8),
                  _buildProductsRow(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('مستشفيات مميزة', isDark, 'عرض الكل', 
                    () => _goTo(context, const HospitalScreen())),
                  const SizedBox(height: 8),
                  _buildFeaturedHospitalsGrid(isDark),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('مختبرات مميزة', isDark, 'عرض الكل', 
                    () => _goTo(context, const LabsListScreen())),
                  const SizedBox(height: 8),
                  _buildFeaturedLabsGrid(isDark),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('صيدليات مميزة', isDark, 'عرض الكل', 
                    () => _goTo(context, const PharmacyScreen())),
                  const SizedBox(height: 8),
                  _buildFeaturedPharmaciesGrid(isDark),
                  const SizedBox(height: 16),
                  _buildSectionTitle('أحدث المقالات', isDark),
                  const SizedBox(height: 8),
                  _buildArticlesGrid(isDark),
                  const SizedBox(height: 16),
                  _buildSectionTitle('نصائح يومية', isDark),
                  const SizedBox(height: 8),
                  _buildDailyTipsGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('مجتمع صحتك', isDark),
                  const SizedBox(height: 8),
                  _communityPosts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final post = entry.value;
                    return _buildCommunityPostCard(post, index, isDark);
                  }),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دوال البناء
  Widget _buildSearchBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔍 فتح شاشة البحث'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/icons/search/Search button.png', width: 26, height: 26, color: isDark ? Colors.grey[400] : Colors.grey[500], errorBuilder: (context, error, stackTrace) => Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[500])),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ابحث عن طبيب، دواء، أو خدمة...',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
            Image.asset('assets/images/chat/microphone.png', width: 26, height: 26, color: isDark ? Colors.grey[500] : Colors.grey[400], errorBuilder: (context, error, stackTrace) => Icon(Icons.mic, color: isDark ? Colors.grey[500] : Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(bool isDark) {
    if (_bannerImages.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('لا توجد بانرات')),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.95,
            onPageChanged: (index, reason) => setState(() => _currentBanner = index),
          ),
          items: _bannerImages.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  url: url,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 12,
          left: 16,
          child: Row(
            children: _bannerImages.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = _currentBanner == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final statsData = [
      {'icon': Icons.local_fire_department, 'value': _caloriesAnim, 'label': 'سعرة حرارية', 'color': Colors.orange, 'subtitle': 'اليوم', 'format': 'int'},
      {'icon': Icons.directions_walk, 'value': _stepsAnim, 'label': 'خطوة', 'color': Colors.green, 'subtitle': 'اليوم', 'format': 'int'},
      {'icon': Icons.bedtime, 'value': _sleepAnim, 'label': 'ساعات النوم', 'color': Colors.purple, 'subtitle': 'الليلة الماضية', 'format': 'double'},
      {'icon': Icons.favorite, 'value': _heartAnim, 'label': 'نبضة/دقيقة', 'color': Colors.red, 'subtitle': 'الآن', 'format': 'int'},
    ];

    return Row(
      children: statsData.map((stat) {
        final color = stat['color'] as Color;
        final value = stat['value'] as double;
        final isInt = stat['format'] == 'int';
        
        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              final displayVal = isInt ? val.toInt().toString() : val.toStringAsFixed(1);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(stat['icon'] as IconData, color: color, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          displayVal,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                    Text(
                      stat['subtitle'] as String,
                      style: const TextStyle(fontSize: 7, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
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

  Widget _buildSectionTitleWithAction(String title, bool isDark, String action, VoidCallback onTap) {
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
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickServicesRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          return _buildQuickServiceIcon(service, isDark);
        },
      ),
    );
  }

  Widget _buildQuickServiceIcon(Map<String, dynamic> service, bool isDark) {
    final color = service['color'] as Color;
    final iconPath = service['icon'] as String;
    
    return GestureDetector(
      onTap: () => _goTo(context, service['screen'] as Widget),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.2),
                ),
              ),
              child: _buildServiceIcon(iconPath, color),
            ),
            const SizedBox(height: 6),
            Text(
              service['label'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDoctorsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: _topDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _topDoctors[index];
        return _buildDoctorCard(doctor, isDark);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isDark) {
    return GestureDetector(
      onTap: () => _goTo(
        context,
        DoctorDetailsScreen(doctorId: doctor['id'] as String),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AppImage(
                    url: doctor['image'] as String,
                    height: 90,
                    width: double.infinity,
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
                          doctor['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                    doctor['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    doctor['specialty'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goTo(
                        context,
                        DoctorDetailsScreen(doctorId: doctor['id'] as String),
                      ),
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsRow() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => _goTo(context, const MedicinesScreen()),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(
                    url: product['image'] as String,
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                if (product['discount'] > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product['discount']}%',
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
            const SizedBox(height: 8),
            Text(
              product['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product['category'] as String,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
            const Spacer(),
            Text(
              '${product['price']} ر.ي',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHospitalsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _featuredHospitals.length,
      itemBuilder: (context, index) {
        final hospital = _featuredHospitals[index];
        return _buildHospitalCard(hospital, isDark);
      },
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, bool isDark) {
    return GestureDetector(
      onTap: () => _goTo(context, const HospitalScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AppImage(
                    url: hospital['image'] as String,
                    height: 90,
                    width: double.infinity,
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
                          hospital['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
                      color: hospital['open'] == true 
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hospital['open'] == true ? 'مفتوح' : 'مغلق',
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
                    hospital['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hospital['location'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goTo(context, const HospitalScreen()),
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
                        'حجز',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedLabsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _featuredLabs.length,
      itemBuilder: (context, index) {
        final lab = _featuredLabs[index];
        return _buildLabCard(lab, isDark);
      },
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark) {
    return GestureDetector(
      onTap: () => _goTo(context, const LabsListScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AppImage(
                url: lab['image'] as String,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lab['location'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goTo(context, const LabsListScreen()),
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
                        'حجز',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPharmaciesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _featuredPharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = _featuredPharmacies[index];
        return _buildPharmacyCard(pharmacy, isDark);
      },
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy, bool isDark) {
    return GestureDetector(
      onTap: () => _goTo(context, const PharmacyScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AppImage(
                url: pharmacy['image'] as String,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    pharmacy['location'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goTo(context, const PharmacyScreen()),
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
                        'طلب',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: _healthArticles.length,
      itemBuilder: (context, index) {
        final article = _healthArticles[index];
        return _buildArticleCard(article, isDark);
      },
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, bool isDark) {
    return GestureDetector(
      onTap: () => _goTo(context, const ArticlesScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AppImage(
                url: article['image'] as String,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article['category'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    article['time'] as String,
                    style: TextStyle(
                      fontSize: 8,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        return GestureDetector(
          onTap: () => _showTipDetails(tip),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (tip['color'] as Color).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (tip['color'] as Color).withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tip['icon'] as IconData, color: tip['color'] as Color, size: 32),
                const SizedBox(height: 6),
                Text(
                  tip['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  tip['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (tip['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'اقرأ المزيد',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityPostCard(Map<String, dynamic> post, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  post['avatar'] as String,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
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
                      post['author'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      post['time'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            post['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post['content'] as String,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          if (post['image'] != null)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: AppImage(
                    url: post['image'] as String,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppImage(
                  url: post['image'] as String,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(index),
                child: Row(
                  children: [
                    Icon(
                      post['liked'] == true ? Icons.favorite : Icons.favorite_border,
                      color: post['liked'] == true ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _showComments(post, index),
                child: Row(
                  children: [
                    Icon(Icons.comment, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${post['comments']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _sharePost(index),
                child: Row(
                  children: [
                    Icon(Icons.share, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${post['shares']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                _buildShimmerBox(height: 80),
                const SizedBox(height: 24),
                _buildShimmerBox(height: 90),
                const SizedBox(height: 24),
                _buildShimmerBox(height: 110),
                const SizedBox(height: 24),
                _buildShimmerBox(height: 200),
                const SizedBox(height: 24),
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

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
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
}
  )
}
