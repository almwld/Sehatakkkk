import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/nearby_clinics/nearby_clinics_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  final List<Widget> _screens = const [_HomeTab(), DoctorsListScreen(), PharmacyScreen(), ChatScreen(), PatientAppointments(), PatientDashboard(), MoreScreen()];

  void _requireAuth(VoidCallback action) {
    if (_isLoggedIn) { action(); }
    else { Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()))); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(body: _screens[_currentIndex], bottomNavigationBar: _buildBottomNav(isDark));
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(height: 70, decoration: BoxDecoration(color: isDark ? const Color(0xFF111D33) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _navItem(0, Icons.home_rounded, 'الرئيسية'), _navItem(1, Icons.person_search_rounded, 'الأطباء'), _navItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'), _centerChatButton(),
      _navItem(4, Icons.calendar_month_rounded, 'المواعيد'), _navItem(5, Icons.folder_rounded, 'صحتي'), _navItem(6, Icons.grid_view_rounded, 'المزيد'),
    ])));
  }

  Widget _navItem(int index, IconData icon, String label) {
    final sel = _currentIndex == index;
    final color = sel ? AppColors.primary : AppColors.grey;
    return GestureDetector(onTap: () { if (index==3||index==4||index==5) { _requireAuth(()=>setState(()=>_currentIndex=index)); } else { setState(()=>_currentIndex=index); } }, child: Column(mainAxisSize:MainAxisSize.min, children: [Icon(icon, color:color, size:22), Text(label, style:TextStyle(fontSize:10, color:color))]));
  }

  Widget _centerChatButton() => GestureDetector(onTap: () => _requireAuth(() => setState(() => _currentIndex = 3)), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width:48,height:48,decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),shape:BoxShape.circle),child:const Icon(Icons.chat_rounded,color:Colors.white,size:26))]));
}

// ============================================
// 🏠 _HomeTab - الشاشة الرئيسية الغنية
// ============================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  void _go(BuildContext c, Widget p) => Navigator.push(c, MaterialPageRoute(builder: (_) => p));

  @override
  Widget build(BuildContext context) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0,
        title: Text(logged ? 'مرحباً، ${user?.displayName ?? user?.email?.split('@')[0] ?? "أحمد"}' : 'منصة صحتك', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary), onPressed: () {}),
          if (!logged) TextButton(onPressed: () => _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())), child: const Text('تسجيل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
        // 1. شريط تسجيل
        if (!logged) _loginBanner(context),
        const SizedBox(height: 14),

        // 2. بحث
        _searchBar(),
        const SizedBox(height: 16),

        // 3. Hero Banner
        _heroBanner(context),
        const SizedBox(height: 16),

        // 4. ServicesCarousel (متحرك)
        _servicesCarousel(context),
        const SizedBox(height: 16),

        // 5. خدمات سريعة (8 خدمات)
        _sectionTitle('خدمات سريعة'),
        const SizedBox(height: 10),
        _quickServicesRow1(context),
        const SizedBox(height: 8),
        _quickServicesRow2(context),
        const SizedBox(height: 22),

        // 6. عروض وخصومات
        _sectionTitle('عروض وخصومات'),
        const SizedBox(height: 10),
        _offersRow(context),
        const SizedBox(height: 22),

        // 7. أفضل الأطباء
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('أفضل الأطباء'), TextButton(onPressed: () => _go(context, const DoctorsListScreen()), child: const Text('عرض الكل ›'))]),
        const SizedBox(height: 10),
        _doctorCard('د. علي المولد', 'استشاري باطنية وأطفال', '20+ سنة', 4.9, 328, '1', context),
        const SizedBox(height: 8),
        _doctorCard('د. حسن رضا', 'طبيب عام', '8+ سنوات', 4.8, 235, '2', context),
        const SizedBox(height: 8),
        _doctorCard('د. فاطمة صديقي', 'طبيبة أطفال', '15+ سنة', 4.9, 412, '3', context),
        const SizedBox(height: 22),

        // 8. صيدلية - منتجات شائعة
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('منتجات صيدلية'), TextButton(onPressed: () => _go(context, const PharmacyScreen()), child: const Text('عرض الكل ›'))]),
        const SizedBox(height: 10),
        _pharmacyRow(context),
        const SizedBox(height: 22),

        // 9. تحاليل شائعة
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('تحاليل شائعة'), TextButton(onPressed: () => _go(context, const LabsListScreen()), child: const Text('عرض الكل ›'))]),
        const SizedBox(height: 10),
        _labsRow(context),
        const SizedBox(height: 22),

        // 10. إحصائيات
        _statsRow(),
        const SizedBox(height: 22),

        // 11. نصائح يومية
        _sectionTitle('نصائح يومية'),
        const SizedBox(height: 10),
        _healthTip('شرب الماء', '8 أكواب يومياً للحفاظ على صحة الجسم', Icons.water_drop, AppColors.info),
        const SizedBox(height: 8),
        _healthTip('المشي اليومي', '30 دقيقة تقلل من أمراض القلب بنسبة 30%', Icons.directions_walk, AppColors.success),
        const SizedBox(height: 8),
        _healthTip('النوم المبكر', '7-8 ساعات نوم تحسن المناعة والتركيز', Icons.bedtime, AppColors.purple),
        const SizedBox(height: 22),

        // 12. خدمات ذكاء اصطناعي
        _sectionTitle('تقنيات ذكية'),
        const SizedBox(height: 10),
        _aiServicesRow(context),
        const SizedBox(height: 50),
      ])),
    );
  }

  // ========== ويدجتس ==========
  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _loginBanner(BuildContext c) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.person, color: Colors.white, size: 22), const SizedBox(width: 10), const Expanded(child: Text('سجل دخولك للاستفادة من جميع الخدمات', style: TextStyle(color: Colors.white, fontSize: 13))), ElevatedButton(onPressed: () => _go(c, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary), child: const Text('تسجيل'))]));

  Widget _searchBar() => Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)), child: const Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 10), Expanded(child: TextField(decoration: InputDecoration(border: InputBorder.none, hintText: 'بحث عن أطباء، أدوية، خدمات...')))]));

  Widget _heroBanner(BuildContext c) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]), borderRadius: BorderRadius.circular(18)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('منصة صحتك، أولويتنا', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('رعاية موثوقة في أي وقت وأي مكان', style: TextStyle(color: Colors.white70, fontSize: 13)), const SizedBox(height: 12), GestureDetector(onTap: () => _go(c, const DoctorsListScreen()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text('احصل على استشارة', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)))),])), const SizedBox(width: 10), Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.health_and_safety, color: Colors.white, size: 45))]));

  Widget _servicesCarousel(BuildContext c) => SizedBox(height: 120, child: ListView(scrollDirection: Axis.horizontal, children: [
    _carouselCard('استشارة فورية', 'تحدث مع طبيب الآن', Icons.videocam, AppColors.primary, () => _go(c, const ChatScreen())),
    _carouselCard('توصيل دواء', 'يصل خلال ساعة', Icons.delivery_dining, AppColors.success, () => _go(c, const PharmacyScreen())),
    _carouselCard('تحليل منزلي', 'خدمة زيارة منزلية', Icons.home_repair_service, AppColors.orange, () => _go(c, const LabsListScreen())),
    _carouselCard('تأمين صحي', 'خطط تأمين متنوعة', Icons.shield, AppColors.purple, () => _go(c, const InsuranceCompanies())),
  ]));

  Widget _carouselCard(String t, String s, IconData i, Color c, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(width: 160, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: c, size: 30), const SizedBox(height: 8), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(s, style: TextStyle(color: AppColors.grey, fontSize: 11))])));

  Widget _quickServicesRow1(BuildContext c) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
    _qs('صيدلية', Icons.local_pharmacy, AppColors.success, () => _go(c, const PharmacyScreen())),
    _qs('طوارئ', Icons.emergency, AppColors.error, () => _go(c, const EmergencyNumbers())),
    _qs('قريب منك', Icons.near_me, AppColors.teal, () => _go(c, const NearbyClinicsScreen())),
    _qs('تحاليل', Icons.science, AppColors.purple, () => _go(c, const LabsListScreen())),
  ]);

  Widget _quickServicesRow2(BuildContext c) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
    _qs('تأمين', Icons.shield_moon, AppColors.indigo, () => _go(c, const InsuranceCompanies())),
    _qs('صحة', Icons.favorite, AppColors.pink, () => _go(c, const HealthDashboard())),
    _qs('محفظة', Icons.account_balance_wallet, AppColors.amber, () => _go(c, const WalletScreen())),
    _qs('سلة', Icons.shopping_cart, AppColors.orange, () => _go(c, const CartScreen())),
  ]);

  Widget _qs(String l, IconData i, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Column(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(i, color: c, size: 26)), const SizedBox(height: 6), Text(l, style: const TextStyle(fontSize: 10))]));

  Widget _offersRow(BuildContext c) => SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
    _offerCard('خصم 30%', 'على جميع الأدوية', 'للطلبات الأولى', AppColors.error),
    _offerCard('استشارة مجانية', 'مع طبيب مختص', 'للمستخدمين الجدد', AppColors.primary),
    _offerCard('توصيل مجاني', 'للطلبات فوق 5000', 'طوال الأسبوع', AppColors.success),
  ]));

  Widget _offerCard(String t, String s, String d, Color c) => Container(width: 180, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(s, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(d, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500))]));

  Widget _doctorCard(String n, String sp, String exp, double r, int rev, String id, BuildContext c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.primary, size: 30)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sp, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(exp, style: const TextStyle(color: AppColors.primary, fontSize: 11))])), Column(children: [Row(children: [const Icon(Icons.star, color: AppColors.amber, size: 14), Text(' $r', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]), Text('$rev تقييم', style: const TextStyle(color: AppColors.grey, fontSize: 9)), const SizedBox(height: 4), GestureDetector(onTap: () => _go(c, DoctorDetailsScreen(doctorId: id)), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Text('حجز', style: TextStyle(color: Colors.white, fontSize: 10))))])]));

  Widget _pharmacyRow(BuildContext c) => SizedBox(height: 160, child: ListView(scrollDirection: Axis.horizontal, children: [
    _productCard('باراسيتامول', '500mg', '500 ر.ي', Icons.medication, AppColors.info),
    _productCard('فيتامين د', '1000IU', '1200 ر.ي', Icons.vaccines, AppColors.success),
    _productCard('خافض حرارة', 'للأطفال', '350 ر.ي', Icons.medical_services, AppColors.warning),
    _productCard('مضاد حيوي', '500mg', '2200 ر.ي', Icons.biotech, AppColors.error),
  ]));

  Widget _productCard(String n, String d, String p, IconData i, Color c) => Container(width: 130, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: c, size: 28)), const SizedBox(height: 8), Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center), Text(d, style: const TextStyle(color: AppColors.grey, fontSize: 10)), const SizedBox(height: 4), Text(p, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))]));

  Widget _labsRow(BuildContext c) => SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
    _labCard('تحليل دم شامل', 'CBC', '2000 ر.ي', AppColors.info),
    _labCard('فيتامين د', 'Vit D', '3500 ر.ي', AppColors.success),
    _labCard('وظائف كبد', 'LFT', '2500 ر.ي', AppColors.warning),
    _labCard('سكر تراكمي', 'HbA1c', '1800 ر.ي', AppColors.purple),
  ]));

  Widget _labCard(String t, String c, String p, Color co) => Container(width: 140, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: co.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: co.withOpacity(0.2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 4), Text(c, style: TextStyle(color: AppColors.grey, fontSize: 11)), const SizedBox(height: 4), Text(p, style: TextStyle(color: co, fontWeight: FontWeight.bold, fontSize: 14))]));

  Widget _statsRow() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
    _stat('5000+', 'مستخدم'),
    _stat('800+', 'طبيب'),
    _stat('3000+', 'استشارة'),
    _stat('94%', 'رضا'),
  ]));

  Widget _stat(String v, String l) => Column(children: [Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11))]);

  Widget _aiServicesRow(BuildContext c) => Row(children: [
    Expanded(child: _aiCard('محلل الأعراض', 'ذكاء اصطناعي يحلل أعراضك', Icons.psychology, AppColors.purple)),
    const SizedBox(width: 10),
    Expanded(child: _aiCard('تذكير الدواء', 'منبه ذكي لمواعيد الأدوية', Icons.notifications_active, AppColors.primary)),
  ]);

  Widget _aiCard(String t, String s, IconData i, Color c) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.3))), child: Column(children: [Icon(i, color: c, size: 35), const SizedBox(height: 8), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 4), Text(s, style: TextStyle(color: AppColors.grey, fontSize: 10), textAlign: TextAlign.center)]));

  // ========== مجتمع صحتك ==========
  // ============================================
  // 🏘️ مجتمع صحتك - منشورات + تفاعلات كاملة
  // ============================================
  Widget _buildCommunitySection() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _sectionTitle('مجتمع صحتك'),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('الأحدث', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold))),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200]!, borderRadius: BorderRadius.circular(8)), child: const Text('الأكثر تفاعلاً', style: TextStyle(color: AppColors.grey, fontSize: 11))),
          const SizedBox(width: 6),
          TextButton(onPressed: () {}, child: const Text('عرض الكل ›')),
        ]),
      ]),
      const SizedBox(height: 12),
      _communityPost(
        'د. علي المولد', 'استشاري باطنية وأطفال', 'منذ 3 ساعات',
        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200',
        'نصيحة طبية مهمة: الإكثار من شرب الماء في فصل الصيف يحمي من الجفاف ويحسن وظائف الكلى. المعدل الطبيعي 8-10 أكواب يومياً. حافظوا على صحتكم 🌿💧',
        'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=400',
        256, 48, true),
      const SizedBox(height: 12),
      _communityPost(
        'أم أحمد', 'أم ومستخدمة', 'منذ 5 ساعات',
        'https://images.unsplash.com/photo-1584515933487-779824d29309?w=200',
        'الحمد لله ابني تعافى تماماً بعد استشارة الدكتور حسن رضا عبر التطبيق. الخدمة كانت سريعة جداً والدكتور متعاون. شكراً منصة صحتك على هالمنصة الرائعة 🙏❤️',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400',
        189, 32, false),
      const SizedBox(height: 12),
      _communityPost(
        'صيدلية الشفاء', 'شريك معتمد - صنعاء', 'منذ 8 ساعات',
        'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200',
        'وصلتنا شحنة جديدة من الأدوية المستوردة. خصم 20% على جميع الفيتامينات والمكملات الغذائية هذا الأسبوع فقط. سارعوا بالطلب قبل نفاذ الكمية 💊🎁',
        'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=400',
        432, 87, true),
      const SizedBox(height: 12),
      _communityPost(
        'مختبر الثقة', 'شريك معتمد - عدن', 'منذ 12 ساعة',
        'https://images.unsplash.com/photo-1581595220892-b0739db3ba8c?w=200',
        'خدمة السحب المنزلي متوفرة الآن في عدن! نتائج تحاليل خلال 4-6 ساعات فقط. تغطية شاملة لجميع أنواع التحاليل الطبية. احجز الآن 🧪✅',
        'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=400',
        567, 124, true),
      const SizedBox(height: 12),
      _communityPost(
        'أبو محمد', 'مستخدم نشط', 'منذ 15 ساعة',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        'أفضل تطبيق طبي في اليمن بلا منازع. حجزت موعد، وطلبت دواء، وسويت تحليل - كل شيء من بيتي وبدون عناء. الله يوفق القائمين على المنصة 🤲',
        '',
        321, 56, false),
      const SizedBox(height: 12),
      _communityPost(
        'د. فاطمة صديقي', 'طبيبة أطفال', 'منذ 18 ساعة',
        'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200',
        'تذكير للأمهات: تطعيمات الأطفال ضرورية جداً في مواعيدها. لا تهملوا جدول التطعيمات. استخدموا تطبيق صحتك لتتبع مواعيد تطعيم أطفالكم 📅👶',
        'https://images.unsplash.com/photo-1584516150906-c43483ee7932?w=400',
        892, 201, true),
      const SizedBox(height: 14),
      _communityStatsBar(),
    ]);
  }

  Widget _communityPost(String name, String role, String time, String avatar, String content, String image, int likes, int comments, bool isLiked) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(avatar, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.person, color: AppColors.primary, size: 22)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Row(children: [Text(role, style: const TextStyle(color: AppColors.grey, fontSize: 10)), const SizedBox(width: 6), Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.grey, shape: BoxShape.circle)), const SizedBox(width: 6), Text(time, style: const TextStyle(color: AppColors.grey, fontSize: 10))])])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Text('+متابعة', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
        if (image.isNotEmpty) ...[const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(image, width: double.infinity, height: 180, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()))],
        const SizedBox(height: 14),
        Row(children: [
          _reactionButton(isLiked ? Icons.favorite : Icons.favorite_border, '$likes', isLiked ? AppColors.error : AppColors.grey),
          const SizedBox(width: 20),
          _reactionButton(Icons.chat_bubble_outline, '$comments', AppColors.grey),
          const SizedBox(width: 20),
          _reactionButton(Icons.bookmark_outline, 'حفظ', AppColors.grey),
          const Spacer(),
          _reactionButton(Icons.share_outlined, 'مشاركة', AppColors.grey),
        ]),
      ]),
    );
  }

  Widget _reactionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontSize: 12))]),
    );
  }

  Widget _communityStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        const Text('انضم إلى مجتمع صحتك', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('شارك تجربتك الصحية واستفد من تجارب الآخرين', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text('انضم الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
      ]),
    );
  }
  Widget _healthTip(String t, String s, IconData i, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.2))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(i, color: c, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(s, style: const TextStyle(color: AppColors.grey, fontSize: 11))]))]));
}
