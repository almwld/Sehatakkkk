import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
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
import 'package:sehatak/presentation/screens/nearby_clinics/nearby_clinics_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';

// ============================================
// 🏠 HOMESCREEN - شريط التنقل السفلي
// ============================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  bool get _logged => FirebaseAuth.instance.currentUser != null;
  final _screens = const [_HomeTab(), DoctorsListScreen(), PharmacyScreen(), ChatScreen(), PatientAppointments(), PatientDashboard(), MoreScreen()];

  void _auth(VoidCallback a) => _logged ? a() : Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())));

  @override
  Widget build(BuildContext c) {
    final d = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(body: _screens[_idx], bottomNavigationBar: _nav(d));
  }

  Widget _nav(bool d) => Container(height: 70, decoration: BoxDecoration(color: d ? const Color(0xFF111D33) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
    _ni(0, Icons.home_rounded, 'الرئيسية'), _ni(1, Icons.person_search_rounded, 'الأطباء'), _ni(2, Icons.local_pharmacy_rounded, 'الصيدلية'), _chat(), _ni(4, Icons.calendar_month_rounded, 'المواعيد'), _ni(5, Icons.folder_rounded, 'صحتي'), _ni(6, Icons.grid_view_rounded, 'المزيد'),
  ])));

  Widget _ni(int i, IconData ic, String l) {
    final s = _idx == i;
    return GestureDetector(onTap: () => (i==3||i==4||i==5) ? _auth(() => setState(() => _idx = i)) : setState(() => _idx = i), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(ic, color: s ? AppColors.primary : AppColors.grey, size: 22), Text(l, style: TextStyle(fontSize: 10, color: s ? AppColors.primary : AppColors.grey))]));
  }

  Widget _chat() => GestureDetector(onTap: () => _auth(() => setState(() => _idx = 3)), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), shape: BoxShape.circle), child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26))]));
}

// ============================================
// 🏠 _HomeTab - الصفحة الرئيسية المتكاملة
// ============================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();
  void _go(BuildContext c, Widget p) => Navigator.push(c, MaterialPageRoute(builder: (_) => p));

  @override
  Widget build(BuildContext c) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';

    return Scaffold(
      // ========== APPBAR ==========
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0,
        leading: Padding(padding: const EdgeInsets.all(8), child: GestureDetector(
          onTap: () => logged ? _go(c, const PatientProfile()) : _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())),
          child: ClipRRect(borderRadius: BorderRadius.circular(14), child: CachedNetworkImage(imageUrl: user?.photoURL ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=00796B&color=fff', width: 40, height: 40, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.person, color: AppColors.primary, size: 22)))),
        )),
        title: Text(logged ? 'مرحباً، $name' : 'منصة صحتك', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary), onPressed: () => _go(c, const CartScreen())),
          if (!logged) TextButton(onPressed: () => _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())), child: const Text('تسجيل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
        ],
      ),

      // ========== BODY ==========
      body: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
        // 1. شريط بحث
        _searchBar(),
        const SizedBox(height: 16),

        // 2. Hero Banner
        _heroBanner(c),
        const SizedBox(height: 16),

        // 3. ServicesCarousel
        _servicesCarousel(c),
        const SizedBox(height: 16),

        // 4. 8 خدمات سريعة
        _sectionTitle('خدمات سريعة'),
        const SizedBox(height: 10),
        _quickServices(c),
        const SizedBox(height: 22),

        // 5. عروض وخصومات
        _sectionTitle('عروض وخصومات'),
        const SizedBox(height: 10),
        _offersRow(c),
        const SizedBox(height: 22),

        // 6. أفضل الأطباء
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('أفضل الأطباء'), TextButton(onPressed: () => _go(c, const DoctorsListScreen()), child: const Text('عرض الكل ›'))]),
        const SizedBox(height: 10),
        _docCard('د. علي المولد', 'استشاري باطنية وأطفال', '20+ سنة', 4.9, 328, '1', c),
        const SizedBox(height: 8),
        _docCard('د. حسن رضا', 'طبيب عام', '8+ سنوات', 4.8, 235, '2', c),
        const SizedBox(height: 8),
        _docCard('د. فاطمة صديقي', 'طبيبة أطفال', '15+ سنة', 4.9, 412, '3', c),
        const SizedBox(height: 22),

        // 7. منتجات صيدلية
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('منتجات صيدلية'), TextButton(onPressed: () => _go(c, const PharmacyScreen()), child: const Text('عرض الكل ›'))]),
        const SizedBox(height: 10),
        _pharmacyRow(c),
        const SizedBox(height: 22),

        // 8. تحاليل شائعة
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('تحاليل شائعة'), TextButton(onPressed: () => _go(c, const LabsListScreen()), child: const Text('عرض الكل ›'))]),
        const SizedBox(height: 10),
        _labsRow(c),
        const SizedBox(height: 22),

        // 9. مجتمع صحتك
        _buildCommunitySection(c),
        const SizedBox(height: 22),

        // 10. إحصائيات
        _statsRow(),
        const SizedBox(height: 22),

        // 11. تقنيات ذكية
        _sectionTitle('تقنيات ذكية'),
        const SizedBox(height: 10),
        _aiRow(c),
        const SizedBox(height: 22),

        // 12. نصائح يومية
        _sectionTitle('نصائح يومية'),
        const SizedBox(height: 10),
        _tip('شرب الماء', '8 أكواب يومياً للحفاظ على صحة الجسم', Icons.water_drop, AppColors.info),
        const SizedBox(height: 8),
        _tip('المشي اليومي', '30 دقيقة تقلل من أمراض القلب بنسبة 30%', Icons.directions_walk, AppColors.success),
        const SizedBox(height: 8),
        _tip('النوم المبكر', '7-8 ساعات نوم تحسن المناعة والتركيز', Icons.bedtime, AppColors.purple),
        const SizedBox(height: 50),
      ])),
    );
  }

  // ========== WIDGETS ==========
  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _searchBar() => Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)), child: const Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 10), Expanded(child: TextField(decoration: InputDecoration(border: InputBorder.none, hintText: 'بحث عن أطباء، أدوية، خدمات...')))]));

  Widget _heroBanner(BuildContext c) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]), borderRadius: BorderRadius.circular(18)), child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('منصة صحتك، أولويتنا', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('رعاية موثوقة في أي وقت وأي مكان', style: TextStyle(color: Colors.white70, fontSize: 13)), const SizedBox(height: 12), GestureDetector(onTap: () => _go(c, const DoctorsListScreen()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text('احصل على استشارة', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold))))])),
    const SizedBox(width: 10), Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.health_and_safety, color: Colors.white, size: 45)),
  ]));

  Widget _servicesCarousel(BuildContext c) => SizedBox(height: 120, child: ListView(scrollDirection: Axis.horizontal, children: [
    _carCard('استشارة فورية', 'تحدث مع طبيب الآن', Icons.videocam, AppColors.primary, () => _go(c, const ChatScreen())),
    _carCard('توصيل دواء', 'يصل خلال ساعة', Icons.delivery_dining, AppColors.success, () => _go(c, const PharmacyScreen())),
    _carCard('تحليل منزلي', 'زيارة منزلية', Icons.home_repair_service, AppColors.orange, () => _go(c, const LabsListScreen())),
    _carCard('تأمين صحي', 'خطط متنوعة', Icons.shield, AppColors.purple, () => _go(c, const InsuranceCompanies())),
  ]));

  Widget _carCard(String t, String s, IconData i, Color co, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(width: 160, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: co.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: co.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: co, size: 30), const SizedBox(height: 8), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(s, style: TextStyle(color: AppColors.grey, fontSize: 11))])));

  Widget _quickServices(BuildContext c) => Wrap(spacing: 12, runSpacing: 12, children: [
    _qs('صيدلية', Icons.local_pharmacy, AppColors.success, () => _go(c, const PharmacyScreen())),
    _qs('طوارئ', Icons.emergency, AppColors.error, () => _go(c, const EmergencyNumbers())),
    _qs('قريب منك', Icons.near_me, AppColors.teal, () => _go(c, const NearbyClinicsScreen())),
    _qs('تحاليل', Icons.science, AppColors.purple, () => _go(c, const LabsListScreen())),
    _qs('تأمين', Icons.shield_moon, AppColors.indigo, () => _go(c, const InsuranceCompanies())),
    _qs('صحة', Icons.favorite, AppColors.pink, () => _go(c, const HealthDashboard())),
    _qs('محفظة', Icons.account_balance_wallet, AppColors.amber, () => _go(c, const WalletScreen())),
    _qs('سلة', Icons.shopping_cart, AppColors.orange, () => _go(c, const CartScreen())),
  ]);

  Widget _qs(String l, IconData i, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Container(width: 72, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(14)), child: Column(children: [Icon(i, color: c, size: 26), const SizedBox(height: 4), Text(l, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w500))])));

  Widget _offersRow(BuildContext c) => SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
    _offerCard('خصم 30%', 'على جميع الأدوية', 'للطلبات الأولى', AppColors.error, () => _go(c, const PharmacyScreen())),
    _offerCard('استشارة مجانية', 'مع طبيب مختص', 'للمستخدمين الجدد', AppColors.primary, () => _go(c, const DoctorsListScreen())),
    _offerCard('توصيل مجاني', 'للطلبات فوق 5000', 'طوال الأسبوع', AppColors.success, () => _go(c, const CartScreen())),
  ]));

  Widget _offerCard(String t, String s, String d, Color c, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(width: 180, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(s, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(d, style: const TextStyle(color: Colors.white, fontSize: 10))])));

  Widget _docCard(String n, String sp, String exp, double r, int rev, String id, BuildContext c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Row(children: [
    Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.primary, size: 30)),
    const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sp, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(exp, style: const TextStyle(color: AppColors.primary, fontSize: 11))])),
    Column(children: [Row(children: [const Icon(Icons.star, color: AppColors.amber, size: 14), Text(' $r', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]), Text('$rev تقييم', style: const TextStyle(color: AppColors.grey, fontSize: 9)), const SizedBox(height: 4), GestureDetector(onTap: () => _go(c, DoctorDetailsScreen(doctorId: id)), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Text('حجز', style: TextStyle(color: Colors.white, fontSize: 10))))])]),
  );

  Widget _pharmacyRow(BuildContext c) => SizedBox(height: 160, child: ListView(scrollDirection: Axis.horizontal, children: [
    _prodCard('باراسيتامول', '500mg', '500 ر.ي', Icons.medication, AppColors.info, () => _go(c, const PharmacyScreen())),
    _prodCard('فيتامين د', '1000IU', '1200 ر.ي', Icons.vaccines, AppColors.success, () => _go(c, const PharmacyScreen())),
    _prodCard('خافض حرارة', 'للأطفال', '350 ر.ي', Icons.medical_services, AppColors.warning, () => _go(c, const PharmacyScreen())),
    _prodCard('مضاد حيوي', '500mg', '2200 ر.ي', Icons.biotech, AppColors.error, () => _go(c, const PharmacyScreen())),
  ]));

  Widget _prodCard(String n, String d, String p, IconData i, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Container(width: 130, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: c, size: 28)), const SizedBox(height: 8), Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center), Text(d, style: const TextStyle(color: AppColors.grey, fontSize: 10)), const SizedBox(height: 4), Text(p, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))])));

  Widget _labsRow(BuildContext c) => SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
    _labCard('تحليل دم شامل', 'CBC', '2000 ر.ي', AppColors.info, () => _go(c, const LabsListScreen())),
    _labCard('فيتامين د', 'Vit D', '3500 ر.ي', AppColors.success, () => _go(c, const LabsListScreen())),
    _labCard('وظائف كبد', 'LFT', '2500 ر.ي', AppColors.warning, () => _go(c, const LabsListScreen())),
    _labCard('سكر تراكمي', 'HbA1c', '1800 ر.ي', AppColors.purple, () => _go(c, const LabsListScreen())),
  ]));

  Widget _labCard(String t, String code, String p, Color c, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(width: 140, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 4), Text(code, style: TextStyle(color: AppColors.grey, fontSize: 11)), const SizedBox(height: 4), Text(p, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 14))])));

  Widget _statsRow() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
    _stat('5000+', 'مستخدم'), _stat('800+', 'طبيب'), _stat('3000+', 'استشارة'), _stat('94%', 'رضا'),
  ]));

  Widget _stat(String v, String l) => Column(children: [Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)), Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 11))]);

  Widget _aiRow(BuildContext c) => Row(children: [
    Expanded(child: _aiCard('محلل الأعراض', 'ذكاء اصطناعي يحلل أعراضك', Icons.psychology, AppColors.purple, () => _go(c, const ConsultationScreen()))),
    const SizedBox(width: 10),
    Expanded(child: _aiCard('تذكير الدواء', 'منبه ذكي للأدوية', Icons.notifications_active, AppColors.primary, () => _go(c, const ConsultationScreen()))),
  ]);

  Widget _aiCard(String t, String s, IconData i, Color c, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.3))), child: Column(children: [Icon(i, color: c, size: 35), const SizedBox(height: 8), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 4), Text(s, style: TextStyle(color: AppColors.grey, fontSize: 10), textAlign: TextAlign.center)])));

  Widget _tip(String t, String s, IconData i, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.2))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(i, color: c, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(s, style: const TextStyle(color: AppColors.grey, fontSize: 11))]))]));

  // ========== مجتمع صحتك ==========
  Widget _buildCommunitySection(BuildContext c) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('مجتمع صحتك'), TextButton(onPressed: () {}, child: const Text('عرض الكل ›'))]),
      const SizedBox(height: 10),
      SizedBox(height: 220, child: ListView(scrollDirection: Axis.horizontal, children: [
        _postCard('د. علي المولد', 'استشاري باطنية', 'نصيحة اليوم: الإكثار من شرب الماء في فصل الصيف يحمي من الجفاف 🌿', 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200', 256, 48),
        _postCard('أم محمد', 'مستخدمة', 'الحمد لله ابني تعافى بعد استشارة الدكتور حسن. شكراً منصة صحتك 🙏', 'https://images.unsplash.com/photo-1584515933487-779824d29309?w=200', 189, 32),
        _postCard('صيدلية الشفاء', 'شريك معتمد', 'وصلتنا شحنة جديدة من الأدوية المستوردة. خصم 20% 💊', 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 432, 87),
        _postCard('مختبر الثقة', 'شريك معتمد', 'نتائج تحاليل كورونا خلال 4 ساعات فقط 🧪', 'https://images.unsplash.com/photo-1581595220892-b0739db3ba8c?w=200', 567, 124),
        _postCard('أبو محمد', 'مستخدم', 'أفضل تطبيق طبي في اليمن بلا منازع 🤲', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200', 321, 56),
      ])),
      const SizedBox(height: 14),
      _communityStatsBar(),
    ]);
  }

  Widget _postCard(String name, String role, String content, String avatar, int likes, int comments) => Container(width: 260, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: avatar, width: 36, height: 36, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.primary, size: 18)))), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(role, style: const TextStyle(color: AppColors.grey, fontSize: 10))]))]),
    const SizedBox(height: 8), Expanded(child: Text(content, style: const TextStyle(fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis)),
    Row(children: [const Icon(Icons.favorite_border, size: 16, color: AppColors.grey), const SizedBox(width: 4), Text('$likes', style: const TextStyle(color: AppColors.grey, fontSize: 11)), const SizedBox(width: 16), const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.grey), const SizedBox(width: 4), Text('$comments', style: const TextStyle(color: AppColors.grey, fontSize: 11)), const Spacer(), const Icon(Icons.share_outlined, size: 16, color: AppColors.grey)]),
  ]));

  Widget _communityStatsBar() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(18)), child: Column(children: [
    const Text('انضم إلى مجتمع صحتك', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    const Text('شارك تجربتك الصحية واستفد من تجارب الآخرين', style: TextStyle(color: Colors.white70, fontSize: 12)),
    const SizedBox(height: 14),
    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text('انضم الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
  ]));
}
