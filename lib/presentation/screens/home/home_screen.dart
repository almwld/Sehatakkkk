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
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
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
    ChatScreen(
      chatId: 'default_chat',
      doctorName: 'الطبيب',
      doctorId: '1',
    ),
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

// ============================================
// 🏠 _HomeTab - الصفحة الرئيسية
// ============================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            _searchBar(),
            const SizedBox(height: 16),
            _heroBanner(context),
            const SizedBox(height: 16),
            _sectionTitle('خدمات سريعة'),
            const SizedBox(height: 10),
            _quickServices(context),
            const SizedBox(height: 22),
            _sectionTitle('أفضل الأطباء'),
            const SizedBox(height: 10),
            _docCard('د. علي المولد', 'استشاري باطنية', '4.9', '1', context),
            const SizedBox(height: 8),
            _docCard('د. فاطمة صديقي', 'طبيبة أطفال', '4.8', '3', context),
            const SizedBox(height: 22),
            _sectionTitle('منتجات صيدلية'),
            const SizedBox(height: 10),
            _pharmacyRow(context),
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

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'بحث عن أطباء، أدوية، خدمات...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00796B), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'منصة صحتك، أولويتنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'رعاية موثوقة في أي وقت وأي مكان',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _go(context, const DoctorsListScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'احصل على استشارة',
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.health_and_safety, color: Colors.white, size: 45),
          ),
        ],
      ),
    );
  }

  Widget _quickServices(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _qs('صيدلية', Icons.local_pharmacy, AppColors.success, () => _go(context, const PharmacyScreen())),
        _qs('طوارئ', Icons.emergency, AppColors.error, () => _go(context, const EmergencyNumbers())),
        _qs('تحاليل', Icons.science, AppColors.purple, () => _go(context, const LabsListScreen())),
        _qs('تأمين', Icons.shield_moon, AppColors.indigo, () => _go(context, const InsuranceCompanies())),
        _qs('صحة', Icons.favorite, AppColors.pink, () => _go(context, const HealthDashboard())),
        _qs('محفظة', Icons.account_balance_wallet, AppColors.amber, () => _go(context, const WalletScreen())),
        _qs('سلة', Icons.shopping_cart, AppColors.orange, () => _go(context, const CartScreen())),
        _qs('استشارة', Icons.chat, AppColors.primary, () => _go(context, const ConsultationScreen())),
      ],
    );
  }

  Widget _qs(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
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

  Widget _docCard(String name, String specialty, String rating, String id, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _prodCard('باراسيتامول', '500mg', '500 ر.ي', Icons.medication, AppColors.info, () => _go(context, const PharmacyScreen())),
          _prodCard('فيتامين د', '1000IU', '1200 ر.ي', Icons.vaccines, AppColors.success, () => _go(context, const PharmacyScreen())),
          _prodCard('خافض حرارة', 'للأطفال', '350 ر.ي', Icons.medical_services, AppColors.warning, () => _go(context, const PharmacyScreen())),
        ],
      ),
    );
  }

  Widget _prodCard(String name, String detail, String price, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
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

  Widget _tip(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
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
