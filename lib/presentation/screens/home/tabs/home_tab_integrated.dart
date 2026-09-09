import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';

class HomeTabIntegrated extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTabIntegrated({super.key, required this.scrollController});

  @override
  State<HomeTabIntegrated> createState() => _HomeTabIntegratedState();
}

class _HomeTabIntegratedState extends State<HomeTabIntegrated>
    with AutomaticKeepAliveClientMixin<HomeTabIntegrated> {
  static const Color _background = Color(0xFFF6F9F9);
  static const Color _darkBackground = Color(0xFF081A1A);
  static const Color _darkCard = Color(0xFF102A2A);
  static const Color _ink = Color(0xFF173131);
  static const Color _muted = Color(0xFF718181);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeBloc>().add(HomeStarted());
    });
  }

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(HomeDataRefreshed());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  void _go(String route, {bool requiresAuth = false}) {
    if (requiresAuth && FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }
    context.push(route);
  }

  String _value(Map<String, dynamic> data, List<String> keys, [String fallback = '']) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  String _initial(String text) {
    final clean = text.trim();
    return clean.isEmpty ? 'ص' : clean.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return ColoredBox(
          color: dark ? _darkBackground : _background,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header(context, state)),
                SliverToBoxAdapter(child: _banner(state, dark)),
                SliverToBoxAdapter(child: _quickServices(dark)),
                SliverToBoxAdapter(child: _healthOverview(state, dark)),
                SliverToBoxAdapter(child: _doctors(state, dark)),
                SliverToBoxAdapter(child: _facilities('مستشفيات مميزة', state.hospitals, Icons.local_hospital_outlined, AppRouter.labs, dark)),
                SliverToBoxAdapter(child: _facilities('مختبرات مميزة', state.labs, Icons.biotech_outlined, AppRouter.labs, dark)),
                SliverToBoxAdapter(child: _facilities('صيدليات مميزة', state.pharmacies, Icons.local_pharmacy_outlined, AppRouter.pharmacy, dark)),
                SliverToBoxAdapter(child: _articles(state.articles, dark)),
                SliverToBoxAdapter(child: _tips(state.tips, dark)),
                SliverToBoxAdapter(child: _discover(dark)),
                SliverToBoxAdapter(child: _community(state.communityPosts, dark)),
                if (state.isLoading) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))),
                if (state.hasError) SliverToBoxAdapter(child: _error(state.errorMessage ?? 'تعذر تحميل بعض بيانات الرئيسية', dark)),
                const SliverToBoxAdapter(child: SizedBox(height: 36)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : hour < 18 ? 'مساء الخير' : 'مساء الخير';
    final name = state.userName.trim().isEmpty ? 'مرحباً بك في صحتك' : state.userName.trim();
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 12, 18, 18),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Colors.white24,
                child: Text(_initial(name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 3),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ])),
              _circleAction(Icons.notifications_none_rounded, AppRouter.notifications, state.notificationCount),
              const SizedBox(width: 8),
              _circleAction(Icons.shopping_cart_outlined, AppRouter.cart),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _go(AppRouter.search),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: const Row(children: [
                Icon(Icons.search_rounded, color: AppColors.primary, size: 25),
                SizedBox(width: 10),
                Expanded(child: Text('ابحث عن طبيب، دواء أو خدمة...', style: TextStyle(color: _muted, fontSize: 13))),
                Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 23),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAction(IconData icon, String route, [int badge = 0]) {
    return Stack(clipBehavior: Clip.none, children: [
      InkWell(
        onTap: () => _go(route),
        borderRadius: BorderRadius.circular(24),
        child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 21)),
      ),
      if (badge > 0)
        Positioned(right: -2, top: -3, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary, width: 1.5)), child: Text(badge > 99 ? '99+' : '$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)))),
    ]);
  }

  Widget _banner(HomeState state, bool dark) {
    if (state.bannerImages.isEmpty) {
      return Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: Container(height: 150, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(22)), alignment: Alignment.center, child: Text('صحتك معك كل يوم', style: TextStyle(color: dark ? Colors.white : _ink, fontSize: 18, fontWeight: FontWeight.w900))));
    }
    return Padding(padding: const EdgeInsets.only(top: 14), child: BannerCarousel(images: state.bannerImages, height: 180, autoPlay: true));
  }

  Widget _quickServices(bool dark) {
    const items = <Map<String, dynamic>>[
      {'i': Icons.medical_services_outlined, 'n': 'الأطباء', 'r': AppRouter.doctors},
      {'i': Icons.local_pharmacy_outlined, 'n': 'الصيدلية', 'r': AppRouter.pharmacy},
      {'i': Icons.biotech_outlined, 'n': 'المختبرات', 'r': AppRouter.labs},
      {'i': Icons.local_hospital_outlined, 'n': 'المستشفيات', 'r': AppRouter.labs},
      {'i': Icons.video_call_outlined, 'n': 'استشارة', 'r': AppRouter.consultation, 'a': true},
      {'i': Icons.emergency_outlined, 'n': 'الطوارئ', 'r': AppRouter.emergency},
      {'i': Icons.home_work_outlined, 'n': 'منزلية', 'r': AppRouter.services},
      {'i': Icons.bloodtype_outlined, 'n': 'تبرع بالدم', 'r': AppRouter.bloodDonation},
      {'i': Icons.account_balance_wallet_outlined, 'n': 'المحفظة', 'r': AppRouter.wallet, 'a': true},
      {'i': Icons.location_on_outlined, 'n': 'بالقرب منك', 'r': AppRouter.map},
    ];
    return _section('الخدمات السريعة', dark, SizedBox(height: 96, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) {
      final item = items[index];
      return InkWell(onTap: () => _go(item['r'] as String, requiresAuth: item['a'] == true), borderRadius: BorderRadius.circular(17), child: Container(width: 78, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 10, offset: const Offset(0, 3))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(item['i'] as IconData, color: AppColors.primary, size: 23)), const SizedBox(height: 6), Text(item['n'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : _ink))])));
    })));
  }

  Widget _healthOverview(HomeState state, bool dark) {
    final score = state.healthScore.clamp(0, 100).toDouble();
    final stats = [
      ('الخطوات', state.steps, 'خطوة', Icons.directions_walk_outlined),
      ('السعرات', state.calories, 'kcal', Icons.local_fire_department_outlined),
      ('النوم', state.sleep, 'ساعة', Icons.bedtime_outlined),
      ('النبض', state.heartRate, 'bpm', Icons.favorite_outline),
    ];
    return _section('ملخصك الصحي', dark, Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
      InkWell(onTap: () => _go(AppRouter.dashboard, requiresAuth: true), borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(22)), child: Row(children: [SizedBox(width: 78, height: 78, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: score / 100, strokeWidth: 8, backgroundColor: AppColors.primary.withOpacity(.10), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)), Text('${score.round()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink))])), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مؤشر صحتك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink)), const SizedBox(height: 5), Text(score >= 80 ? 'ممتاز — استمر على نمطك الصحي' : score >= 60 ? 'جيد — لديك فرصة للتحسن' : 'ابدأ بخطوة صغيرة اليوم', style: TextStyle(color: dark ? Colors.white70 : _muted, fontSize: 12)), const SizedBox(height: 8), const Text('عرض الملف الصحي ←', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11))]))])),
      const SizedBox(height: 10),
      SizedBox(height: 88, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: stats.length, separatorBuilder: (_, __) => const SizedBox(width: 9), itemBuilder: (_, index) { final s = stats[index]; return Container(width: 122, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(s.$4, color: AppColors.primary, size: 20), const Spacer(), Text(s.$1, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)), Text(s.$2 == 0 ? '—' : '${s.$2 % 1 == 0 ? s.$2.toInt() : s.$2.toStringAsFixed(1)} ${s.$3}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink))])); }))
    ])));
  }

  Widget _doctors(List<Map<String, dynamic>> doctors, bool dark) {
    final items = doctors.take(6).toList();
    return _section('أفضل الأطباء', dark, Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('أطباء موثوقون', style: TextStyle(color: dark ? Colors.white70 : _muted, fontSize: 11)), TextButton(onPressed: () => _go(AppRouter.doctors), child: const Text('عرض الكل'))])), if (items.isEmpty) _empty('لا توجد بيانات أطباء حالياً', dark) else SizedBox(height: 198, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, index) { final d = items[index]; final name = _value(d, ['name', 'fullName', 'doctorName'], 'طبيب صحتك'); final specialty = _value(d, ['specialty', 'specialization', 'category'], 'طب عام'); final id = _value(d, ['id', 'doctorId'], ''); final photo = _value(d, ['photoUrl', 'imageUrl', 'image', 'photo']); return InkWell(onTap: () { if (id.isNotEmpty) { _go('/doctor/$id'); } else { _go(AppRouter.doctors); } }, borderRadius: BorderRadius.circular(20), child: Container(width: 158, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: CircleAvatar(radius: 35, backgroundColor: AppColors.primary.withOpacity(.10), backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? Text(_initial(name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 20)) : null)), const SizedBox(height: 9), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink)), const SizedBox(height: 3), Text(specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 10.5, fontWeight: FontWeight.w700)), const Spacer(), SizedBox(width: double.infinity, height: 32, child: OutlinedButton(onPressed: () { if (id.isNotEmpty) _go('/doctor/$id'); else _go(AppRouter.doctors); }, child: const Text('عرض الطبيب', style: TextStyle(fontSize: 10))))]))); })))]));
  }

  Widget _facilities(String title, List<Map<String, dynamic>> data, IconData icon, String route, bool dark) {
    final items = data.take(5).toList();
    return _section(title, dark, Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => _go(route), child: const Text('عرض الكل')))), if (items.isEmpty) _empty('لا توجد بيانات متاحة حالياً', dark) else SizedBox(height: 126, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) { final item = items[index]; final name = _value(item, ['name', 'title', 'facilityName'], 'منشأة صحية'); final area = _value(item, ['address', 'location', 'area', 'city'], 'اليمن'); final photo = _value(item, ['photoUrl', 'imageUrl', 'image', 'photo']); return Container(width: 220, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(19)), child: Row(children: [CircleAvatar(radius: 27, backgroundColor: AppColors.primary.withOpacity(.10), backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? Icon(icon, color: AppColors.primary, size: 26) : null), const SizedBox(width: 10), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink, fontSize: 12)), const SizedBox(height: 5), Text(area, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white60 : _muted, fontSize: 10))]))])); }))]));
  }

  Widget _articles(List<Map<String, dynamic>> articles, bool dark) {
    final items = articles.take(6).toList();
    return _section('مقالات صحية', dark, Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => _go(AppRouter.services), child: const Text('المزيد')))), if (items.isEmpty) _empty('ستظهر المقالات الصحية هنا', dark) else SizedBox(height: 180, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, index) { final a = items[index]; final title = _value(a, ['title', 'name'], 'نصيحة صحية'); final summary = _value(a, ['summary', 'description', 'excerpt'], 'معلومة صحية مفيدة من صحتك'); final photo = _value(a, ['imageUrl', 'image', 'photoUrl']); return Container(width: 245, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (photo.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.network(photo, height: 70, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(Icons.article_outlined))) else _imageFallback(Icons.article_outlined), const SizedBox(height: 9), Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink, fontSize: 12)), const SizedBox(height: 4), Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white60 : _muted, fontSize: 10.5))])); }))]));
  }

  Widget _tips(List<Map<String, dynamic>> tips, bool dark) {
    final items = tips.take(4).toList();
    return _section('نصيحة اليوم', dark, Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: items.isEmpty ? _empty('اعتنِ بنومك، غذائك ونشاطك اليومي.', dark) : Column(children: items.map((tip) { final title = _value(tip, ['title', 'name', 'text'], 'نصيحة صحية'); return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17)), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary)), const SizedBox(width: 10), Expanded(child: Text(title, style: TextStyle(color: dark ? Colors.white : _ink, fontWeight: FontWeight.w700, fontSize: 12)))])); }).toList())));
  }

  Widget _discover(bool dark) {
    const items = <Map<String, dynamic>>[
      {'i': Icons.calendar_month_outlined, 't': 'مواعيدي', 'r': AppRouter.appointments, 'a': true},
      {'i': Icons.favorite_border_rounded, 't': 'ملفي الصحي', 'r': AppRouter.dashboard, 'a': true},
      {'i': Icons.account_balance_wallet_outlined, 't': 'المحفظة', 'r': AppRouter.wallet, 'a': true},
      {'i': Icons.map_outlined, 't': 'الخريطة', 'r': AppRouter.map},
      {'i': Icons.support_agent_outlined, 't': 'الدعم', 'r': AppRouter.more},
      {'i': Icons.settings_outlined, 't': 'الإعدادات', 'r': AppRouter.settings},
    ];
    return _section('اكتشف المزيد', dark, GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 86, crossAxisSpacing: 9, mainAxisSpacing: 9), itemBuilder: (_, index) { final item = items[index]; return InkWell(onTap: () => _go(item['r'] as String, requiresAuth: item['a'] == true), borderRadius: BorderRadius.circular(17), child: Container(decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(item['i'] as IconData, color: AppColors.primary, size: 25), const SizedBox(height: 7), Text(item['t'] as String, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: dark ? Colors.white : _ink))]))); }));
  }

  Widget _community(List<Map<String, dynamic>> posts, bool dark) {
    final items = posts.take(4).toList();
    return _section('مجتمع صحتك', dark, Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('محتوى من مجتمعك الصحي', style: TextStyle(color: dark ? Colors.white60 : _muted, fontSize: 10.5)), TextButton(onPressed: () => _go(AppRouter.more), child: const Text('عرض الكل'))])), if (items.isEmpty) _empty('شارك معلومة صحية مفيدة مع مجتمع صحتك', dark) else ...items.map((post) { final author = _value(post, ['authorName', 'userName', 'name'], 'عضو في صحتك'); final text = _value(post, ['text', 'content', 'body', 'description'], 'منشور صحي'); return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 9), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 19, backgroundColor: AppColors.primary.withOpacity(.10), child: Text(_initial(author), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(author, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: dark ? Colors.white : _ink)), const SizedBox(height: 4), Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.35, color: dark ? Colors.white70 : _muted))]))]))); })]));
  }

  Widget _section(String title, bool dark, Widget child) {
    return Padding(padding: const EdgeInsets.only(top: 19), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _ink))), const SizedBox(height: 10), child]));
  }

  Widget _empty(String text, bool dark) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white60 : _muted, fontSize: 11)));
  }

  Widget _imageFallback(IconData icon) {
    return Container(height: 70, width: double.infinity, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(13)), alignment: Alignment.center, child: Icon(icon, color: AppColors.primary, size: 28));
  }

  Widget _error(String message, bool dark) {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 0), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.info_outline_rounded, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(message, style: TextStyle(color: dark ? Colors.white70 : _muted, fontSize: 11)))])));
  }
}
