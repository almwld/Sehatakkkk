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
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/nearby_clinics/nearby_clinics_screen.dart';
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
  int _idx = 0;
  bool get _logged => FirebaseAuth.instance.currentUser != null;
  final _screens = const [_HomeTab(), DoctorsListScreen(), PharmacyScreen(), ChatScreen(), PatientAppointments(), PatientDashboard(), MoreScreen()];

  void _auth(VoidCallback a) { _logged ? a() : Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()))); }

  @override
  Widget build(BuildContext c) {
    final d = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(body: _screens[_idx], bottomNavigationBar: Container(height: 70, decoration: BoxDecoration(color: d ? const Color(0xFF111D33) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _nav(0, Icons.home_rounded, 'الرئيسية'), _nav(1, Icons.person_search_rounded, 'الأطباء'), _nav(2, Icons.local_pharmacy_rounded, 'الصيدلية'), _chat(), _nav(4, Icons.calendar_month_rounded, 'المواعيد'), _nav(5, Icons.folder_rounded, 'صحتي'), _nav(6, Icons.grid_view_rounded, 'المزيد'),
    ]))));
  }

  Widget _nav(int i, IconData ic, String l) {
    final s = _idx == i;
    return GestureDetector(onTap: () => (i==3||i==4||i==5) ? _auth(() => setState(() => _idx = i)) : setState(() => _idx = i), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(ic, color: s ? AppColors.primary : AppColors.grey, size: 22), Text(l, style: TextStyle(fontSize: 10, color: s ? AppColors.primary : AppColors.grey))]));
  }

  Widget _chat() => GestureDetector(onTap: () => _auth(() => setState(() => _idx = 3)), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), shape: BoxShape.circle), child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26))]));
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  void _go(BuildContext c, Widget p) => Navigator.push(c, MaterialPageRoute(builder: (_) => p));

  @override
  Widget build(BuildContext c) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0,
        leading: Padding(padding: const EdgeInsets.all(8), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: CachedNetworkImage(imageUrl: user?.photoURL ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.email?.split('@')[0] ?? 'مستخدم')}&background=00796B&color=fff', width: 40, height: 40, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.person, color: AppColors.primary, size: 22))))),
        title: Text(logged ? 'مرحباً، ${user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم'}' : 'منصة صحتك', style: const TextStyle(color: AppColors.primary, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary), onPressed: () => _go(c, const CartScreen())),
          if (!logged) TextButton(onPressed: () => _go(c, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())), child: const Text('تسجيل', style: TextStyle(color: AppColors.primary))),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _searchBar(),
        const SizedBox(height: 16),
        _heroBanner(c),
        const SizedBox(height: 22),
        const Text('خدمات سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _quickServices(c),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('أفضل الأطباء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton(onPressed: () => _go(c, const DoctorsListScreen()), child: const Text('عرض الكل ›'))]),
        _docCard('د. علي المولد', 'استشاري باطنية وأطفال', '20+ سنة', 4.9, 328, '1', c),
        const SizedBox(height: 8),
        _docCard('د. حسن رضا', 'طبيب عام', '8+ سنوات', 4.8, 235, '2', c),
        const SizedBox(height: 50),
      ])),
    );
  }

  Widget _searchBar() => Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)), child: const Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 10), Expanded(child: TextField(decoration: InputDecoration(border: InputBorder.none, hintText: 'بحث عن أطباء، أدوية، خدمات...')))]));

  Widget _heroBanner(BuildContext c) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]), borderRadius: BorderRadius.circular(18)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('منصة صحتك، أولويتنا', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('رعاية موثوقة في أي وقت وأي مكان', style: TextStyle(color: Colors.white70, fontSize: 13)), const SizedBox(height: 12), GestureDetector(onTap: () => _go(c, const DoctorsListScreen()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text('احصل على استشارة', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold))))])), const SizedBox(width: 10), Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.health_and_safety, color: Colors.white, size: 45))]));

  Widget _quickServices(BuildContext c) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
    _qs('صيدلية', Icons.local_pharmacy, AppColors.success, () => _go(c, const PharmacyScreen())),
    _qs('طوارئ', Icons.emergency, AppColors.error, () => _go(c, const EmergencyNumbers())),
    _qs('قريب منك', Icons.near_me, AppColors.teal, () => _go(c, const NearbyClinicsScreen())),
    _qs('تحاليل', Icons.science, AppColors.purple, () => _go(c, const LabsListScreen())),
    _qs('تأمين', Icons.shield, AppColors.indigo, () => _go(c, const InsuranceCompanies())),
    _qs('صحة', Icons.favorite, AppColors.pink, () => _go(c, const HealthDashboard())),
    _qs('محفظة', Icons.wallet, AppColors.amber, () => _go(c, const WalletScreen())),
    _qs('سلة', Icons.shopping_cart, AppColors.orange, () => _go(c, const CartScreen())),
  ]);

  Widget _qs(String l, IconData i, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Column(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(i, color: c, size: 26)), const SizedBox(height: 6), Text(l, style: const TextStyle(fontSize: 10))]));

  Widget _docCard(String n, String s, String e, double r, int rev, String id, BuildContext c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.primary, size: 30)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(s, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(e, style: const TextStyle(color: AppColors.primary, fontSize: 11))])), Column(children: [Row(children: [const Icon(Icons.star, color: AppColors.amber, size: 14), Text(' $r', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]), Text('$rev تقييم', style: const TextStyle(color: AppColors.grey, fontSize: 9)), const SizedBox(height: 4), GestureDetector(onTap: () => _go(c, DoctorDetailsScreen(doctorId: id)), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Text('حجز', style: TextStyle(color: Colors.white, fontSize: 10))))])]));
}
