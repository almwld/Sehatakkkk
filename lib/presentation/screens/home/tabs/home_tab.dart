import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
import 'package:sehatak/core/services/pharmacy_service.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class HomeTab extends StatefulWidget {
  final ScrollController scrollController;
  const HomeTab({super.key, required this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  Timer? _loadTimer;
  late Future<List<ProductModel>> _products;
  late Future<Map<String, dynamic>> _weather;

  static const _bg = Color(0xFFF7FAFA);
  static const _darkBg = Color(0xFF081A1A);
  static const _darkCard = Color(0xFF102A2A);
  static const _text = Color(0xFF173131);
  static const _muted = Color(0xFF6B7D7D);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _products = PharmacyService().getPopularProducts(limit: 8);
    _weather = _loadWeather();
    _loadTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) context.read<HomeBloc>().add(HomeStarted());
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadWeather() async {
    try {
      final uri = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=15.3694&longitude=44.1910&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m&timezone=Asia%2FAden');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw Exception('weather_${response.statusCode}');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final current = (json['current'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final code = (current['weather_code'] as num?)?.toInt() ?? -1;
      return {'temp': (current['temperature_2m'] as num?)?.toStringAsFixed(0), 'condition': _weatherText(code), 'humidity': current['relative_humidity_2m'], 'wind': current['wind_speed_10m']};
    } catch (_) {
      return {'temp': null, 'condition': 'تعذر تحديث الطقس الآن'};
    }
  }

  String _weatherText(int code) {
    if (code == 0) return 'صحو';
    if (code <= 3) return 'غائم جزئياً';
    if (code <= 48) return 'ضباب';
    if (code <= 67) return 'أمطار';
    if (code <= 77) return 'ثلوج';
    if (code <= 82) return 'زخات مطر';
    if (code <= 99) return 'عواصف رعدية';
    return 'غير متاح';
  }

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(HomeDataRefreshed());
    setState(() {
      _products = PharmacyService().getPopularProducts(limit: 8);
      _weather = _loadWeather();
    });
  }

  void _go(String route) => context.push(route);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        color: dark ? _darkBg : _bg,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _hero(context, state)),
              SliverToBoxAdapter(child: _banner(state, dark)),
              SliverToBoxAdapter(child: _quickServices(dark)),
              SliverToBoxAdapter(child: _healthOverview(state, dark)),
              SliverToBoxAdapter(child: _doctors(state, dark)),
              SliverToBoxAdapter(child: _productsSection(dark)),
              SliverToBoxAdapter(child: _places('مستشفيات مميزة', state.hospitals, Icons.local_hospital_outlined, dark)),
              SliverToBoxAdapter(child: _places('مختبرات مميزة', state.labs, Icons.biotech_outlined, dark)),
              SliverToBoxAdapter(child: _places('صيدليات مميزة', state.pharmacies, Icons.local_pharmacy_outlined, dark)),
              SliverToBoxAdapter(child: _articles(state.articles, dark)),
              SliverToBoxAdapter(child: _tips(dark)),
              SliverToBoxAdapter(child: _discover(dark)),
              SliverToBoxAdapter(child: _weatherAndRecommendation(state, dark)),
              SliverToBoxAdapter(child: _community(state.communityPosts, dark)),
              if (state.isLoading) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))),
              if (state.hasError) SliverToBoxAdapter(child: _error(state.errorMessage, dark)),
              const SliverToBoxAdapter(child: SizedBox(height: 34)),
            ],
          ),
        ),
      );
    });
  }

  Widget _hero(BuildContext context, HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير ☀️' : hour < 17 ? 'مساء الخير 🌤️' : 'مساء الخير 🌙';
    final name = state.userName.trim().isEmpty ? 'مرحباً بك في صحتك' : state.userName.trim();
    return Container(
      height: 194,
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 10, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.primary, AppColors.primary.withOpacity(.82)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.20), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 23, backgroundColor: Colors.white.withOpacity(.20), child: Text(name.characters.first, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))])),
          _headerAction(Icons.notifications_none_rounded, AppRouter.notifications),
          const SizedBox(width: 8),
          _headerAction(Icons.shopping_cart_outlined, AppRouter.cart),
        ]),
        const SizedBox(height: 18),
        InkWell(onTap: () => _go(AppRouter.search), borderRadius: BorderRadius.circular(18), child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.13), blurRadius: 16, offset: const Offset(0, 6))]), child: const Row(children: [Icon(Icons.search_rounded, color: AppColors.primary, size: 25), SizedBox(width: 10), Expanded(child: Text('ابحث عن طبيب، دواء أو خدمة...', style: TextStyle(color: _muted, fontSize: 13))), Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 23)]))),
      ]),
    );
  }

  Widget _headerAction(IconData icon, String route) => InkWell(onTap: () => _go(route), borderRadius: BorderRadius.circular(22), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(.15), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 21)));

  Widget _banner(HomeState state, bool dark) {
    if (state.bannerImages.isEmpty) return Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: Container(height: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.primary.withOpacity(.08), border: Border.all(color: AppColors.primary.withOpacity(.12))), child: Center(child: Text('صحتك معك كل يوم', style: TextStyle(color: dark ? Colors.white : _text, fontSize: 18, fontWeight: FontWeight.w900))));
    return Padding(padding: const EdgeInsets.only(top: 14), child: BannerCarousel(images: state.bannerImages, height: 180, autoPlay: true));
  }

  Widget _quickServices(bool dark) {
    const items = <(IconData, String, String)>[(Icons.local_pharmacy_outlined, 'الصيدلية', AppRouter.pharmacy), (Icons.emergency_outlined, 'الطوارئ', AppRouter.emergency), (Icons.home_work_outlined, 'خدمات منزلية', AppRouter.services), (Icons.bloodtype_outlined, 'تبرع بالدم', AppRouter.services), (Icons.medical_services_outlined, 'الأطباء', AppRouter.doctors), (Icons.biotech_outlined, 'المختبرات', AppRouter.labs), (Icons.favorite_outline, 'صحتي', AppRouter.dashboard), (Icons.account_balance_wallet_outlined, 'المحفظة', AppRouter.wallet), (Icons.chat_bubble_outline, 'استشارة', AppRouter.consultation), (Icons.location_on_outlined, 'بالقرب منك', AppRouter.map)];
    return _section(title: 'الخدمات السريعة', dark: dark, child: SizedBox(height: 96, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final x = items[i]; return InkWell(onTap: () => _go(x.$3), borderRadius: BorderRadius.circular(17), child: Container(width: 78, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.primary.withOpacity(.10))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(x.$1, color: AppColors.primary, size: 23)), const SizedBox(height: 6), Text(x.$2, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : _text))]))); })));
  }

  Widget _healthOverview(HomeState state, bool dark) {
    final score = _score(state);
    final stats = <(String, double, String, IconData)>[('السعرات', state.calories, 'kcal', Icons.local_fire_department_outlined), ('الخطوات', state.steps, 'خطوة', Icons.directions_walk_outlined), ('النوم', state.sleep, 'ساعة', Icons.bedtime_outlined), ('النبض', state.heartRate, 'bpm', Icons.favorite_outline)];
    return _section(title: 'ملخصك الصحي', dark: dark, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.primary.withOpacity(.10))), child: Row(children: [SizedBox(width: 88, height: 88, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: score / 100, strokeWidth: 8, backgroundColor: AppColors.primary.withOpacity(.10), valueColor: const AlwaysStoppedAnimation(AppColors.primary)), Text('$score', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))])), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مؤشر صحتك اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), const SizedBox(height: 5), Text(score == 0 ? 'أضف قياساتك الصحية لاحتساب المؤشر.' : 'تابع نشاطك ونومك ومؤشراتك الحيوية باستمرار.', style: TextStyle(fontSize: 11.5, height: 1.4, color: dark ? Colors.white60 : _muted))]))])), const SizedBox(height: 10), Row(children: stats.map((s) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(13)), child: Column(children: [Icon(s.$4, color: AppColors.primary, size: 18), const SizedBox(height: 4), Text(s.$1, style: TextStyle(fontSize: 8.5, color: dark ? Colors.white60 : _muted)), const SizedBox(height: 2), Text('${_number(s.$2)} ${s.$3}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))]))).toList())])));
  }

  int _score(HomeState s) { final total = s.calories + s.steps + s.sleep + s.heartRate; if (total <= 0) return 0; final a = (s.steps / 10000 * 35).clamp(0, 35); final b = (s.sleep / 8 * 25).clamp(0, 25); final c = (s.calories / 3000 * 15).clamp(0, 15); final d = s.heartRate >= 50 && s.heartRate <= 100 ? 25 : 10; return (a + b + c + d).round().clamp(0, 100); }

  Widget _doctors(HomeState state, bool dark) {
    final items = state.doctors.take(6).toList();
    return _section(title: 'أفضل الأطباء', dark: dark, more: () => _go(AppRouter.doctors), child: items.isEmpty ? _empty('لا توجد أطباء موثقون متاحون حالياً', dark) : SizedBox(height: 230, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) { final d = items[i]; final image = (d['photoUrl'] ?? d['image'] ?? '').toString(); return Container(width: 168, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.primary.withOpacity(.10))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), child: image.isEmpty ? Container(height: 106, color: AppColors.primary.withOpacity(.08), child: const Center(child: Icon(Icons.person_rounded, color: AppColors.primary, size: 48))) : AppImage(imageUrl: image, height: 106, width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((d['name'] ?? 'طبيب').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), const SizedBox(height: 3), Text((d['specialty'] ?? 'طب عام').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: _muted)), const SizedBox(height: 8), SizedBox(width: double.infinity, height: 30, child: ElevatedButton(onPressed: () => _go(AppRouter.doctors), child: const Text('عرض الطبيب', style: TextStyle(fontSize: 10.5))))]))])); })));
  }

  Widget _productsSection(bool dark) => _section(title: 'منتجات الصيدلية', dark: dark, more: () => _go(AppRouter.pharmacy), child: FutureBuilder<List<ProductModel>>(future: _products, builder: (_, snap) { if (snap.connectionState == ConnectionState.waiting) return const SizedBox(height: 230, child: Center(child: CircularProgressIndicator(strokeWidth: 2))); final items = snap.data ?? const <ProductModel>[]; if (items.isEmpty) return _empty('لا توجد منتجات متاحة حالياً', dark); return SizedBox(height: 235, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final p = items[i]; return Container(width: 154, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(.10))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: p.imageUrl == null || p.imageUrl!.isEmpty ? Container(height: 88, width: 88, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(14)), child: Icon(p.categoryIcon, color: AppColors.primary, size: 38)) : AppImage(imageUrl: p.imageUrl!, height: 88, width: 88, fit: BoxFit.contain)), const SizedBox(height: 7), Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)), const SizedBox(height: 4), Text(p.categoryText, style: const TextStyle(fontSize: 9.5, color: _muted)), const Spacer(), Row(children: [if (p.isDiscounted) Text('${p.price.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontSize: 8.5, color: _muted, decoration: TextDecoration.lineThrough)), const SizedBox(width: 4), Text('${p.priceWithDiscount.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w900))])])); })) });

  Widget _places(String title, List<Map<String, dynamic>> data, IconData icon, bool dark) => _section(title: title, dark: dark, child: data.isEmpty ? _empty('لا توجد بيانات منشورة حالياً', dark) : SizedBox(height: 214, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: data.take(6).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final p = data[i]; final image = (p['imageUrl'] ?? p['image'] ?? '').toString(); return Container(width: 176, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.primary.withOpacity(.10))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(17)), child: image.isEmpty ? Container(height: 94, color: AppColors.primary.withOpacity(.07), child: Center(child: Icon(icon, color: AppColors.primary, size: 42))) : AppImage(imageUrl: image, height: 94, width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(9), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((p['name'] ?? p['title'] ?? 'مرفق صحي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), const SizedBox(height: 4), Text((p['address'] ?? p['location'] ?? p['city'] ?? 'اليمن').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: _muted)), const SizedBox(height: 8), SizedBox(width: double.infinity, height: 29, child: OutlinedButton(onPressed: () => _go(title.contains('مختبر') ? AppRouter.labs : AppRouter.pharmacy), child: Text(title.contains('مختبر') ? 'حجز' : title.contains('صيدليات') ? 'طلب' : 'تفاصيل', style: const TextStyle(fontSize: 10))))]))])); })));

  Widget _articles(List<Map<String, dynamic>> data, bool dark) => _section(title: 'أحدث المقالات', dark: dark, child: data.isEmpty ? _empty('لا توجد مقالات منشورة حالياً', dark) : GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.take(4).length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .92), itemBuilder: (_, i) { final a = data[i]; final image = (a['imageUrl'] ?? a['image'] ?? '').toString(); return Container(decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.primary.withOpacity(.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: image.isEmpty ? Container(height: 78, color: AppColors.primary.withOpacity(.07), child: const Center(child: Icon(Icons.article_outlined, color: AppColors.primary, size: 32))) : AppImage(imageUrl: image, height: 78, width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(9), child: Text((a['title'] ?? a['name'] ?? 'مقال صحي').toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.35, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text))) ])); });

  Widget _tips(bool dark) {
    const tips = [('شرب الماء', 'حافظ على ترطيب جسمك خلال اليوم.', Icons.water_drop_outlined), ('المشي', 'أضف حركة يومية مناسبة لقدرتك.', Icons.directions_walk_outlined), ('النوم', 'حافظ على روتين نوم منتظم.', Icons.bedtime_outlined), ('الفواكه', 'اجعل الفواكه والخضروات جزءاً من غذائك.', Icons.apple_outlined)];
    return _section(title: 'نصائح يومية', dark: dark, child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: tips.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.12), itemBuilder: (_, i) { final t = tips[i]; return InkWell(onTap: () => _showTip(t.$1, t.$2), borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.07), borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.primary.withOpacity(.14))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(t.$3, color: AppColors.primary, size: 31), const SizedBox(height: 8), Text(t.$1, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(t.$2, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 10.5, height: 1.3, color: dark ? Colors.white70 : _muted)), const SizedBox(height: 5), const Text('اقرأ المزيد', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w800))]))); }));
  }

  void _showTip(String title, String text) => showModalBottomSheet<void>(context: context, showDragHandle: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 38), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)), const SizedBox(height: 16), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')))]));

  Widget _discover(bool dark) => _section(title: 'اكتشف المزيد', dark: dark, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [('مقالات', Icons.article_outlined, AppRouter.more), ('تأمين', Icons.health_and_safety_outlined, AppRouter.more), ('فيديو', Icons.video_call_outlined, AppRouter.consultation), ('باقات', Icons.inventory_2_outlined, AppRouter.services)].map((x) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(onTap: () => _go(x.$3), borderRadius: BorderRadius.circular(12), child: Container(height: 82, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(.08))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(x.$2, color: AppColors.primary, size: 27), const SizedBox(height: 5), Text(x.$1, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : _text))])))))).toList()));

  Widget _weatherAndRecommendation(HomeState state, bool dark) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(children: [FutureBuilder<Map<String, dynamic>>(future: _weather, builder: (_, snap) { final d = snap.data ?? const <String, dynamic>{}; return _infoCard(dark, Icons.wb_sunny_outlined, 'الطقس في صنعاء', d['temp'] == null ? 'تحديث الطقس غير متاح الآن' : '${d['temp']}°C • ${d['condition']}', 'بيانات الطقس الحالية من مصدر مفتوح', Colors.cyan); }), const SizedBox(height: 10), _infoCard(dark, Icons.auto_awesome, 'توصية صحية', _recommendation(state), 'مبنية على القياسات المتاحة في حسابك', Colors.deepPurple)]));

  String _recommendation(HomeState s) { if (s.steps < 3000) return 'حاول إضافة مشي خفيف تدريجياً خلال اليوم.'; if (s.sleep > 0 && s.sleep < 6) return 'اجعل النوم المنتظم أولوية الليلة.'; return 'استمر على عاداتك الصحية المتوازنة.'; }

  Widget _infoCard(bool dark, IconData icon, String title, String main, String sub, Color accent) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: accent.withOpacity(.16))), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withOpacity(.10), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 22)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), const SizedBox(height: 3), Text(main, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent)), const SizedBox(height: 2), Text(sub, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white60 : _muted))]))]));

  Widget _community(List<Map<String, dynamic>> posts, bool dark) => _section(title: 'مجتمع صحتك', dark: dark, child: posts.isEmpty ? _empty('لا توجد منشورات مجتمعية حالياً', dark) : Column(children: posts.take(4).map((p) { final author = (p['userName'] ?? p['author'] ?? 'عضو في مجتمع صحتك').toString(); return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 10), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 17, backgroundColor: AppColors.primary.withOpacity(.10), child: Text(author.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizedBox(width: 9), Expanded(child: Text(author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), const Icon(Icons.more_horiz, color: _muted)]), const SizedBox(height: 8), Text((p['content'] ?? p['text'] ?? p['title'] ?? '').toString(), maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, height: 1.45, color: dark ? Colors.white70 : _text)), const SizedBox(height: 8), Row(children: [const Icon(Icons.favorite_border, size: 18, color: _muted), const SizedBox(width: 4), Text('${p['likes'] ?? p['likesCount'] ?? 0}', style: const TextStyle(fontSize: 10, color: _muted)), const SizedBox(width: 18), const Icon(Icons.mode_comment_outlined, size: 18, color: _muted), const SizedBox(width: 4), Text('${p['comments'] ?? p['commentsCount'] ?? 0}', style: const TextStyle(fontSize: 10, color: _muted)), const Spacer(), const Icon(Icons.share_outlined, size: 18, color: _muted)])])); }).toList()));

  Widget _section({required String title, required bool dark, required Widget child, VoidCallback? more}) => Padding(padding: const EdgeInsets.only(top: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionHeader(title, dark, more: more), const SizedBox(height: 11), child]));
  Widget _sectionHeader(String title, bool dark, {VoidCallback? more}) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), if (more != null) TextButton(onPressed: more, child: const Text('عرض الكل', style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w800)))]));
  Widget _empty(String text, bool dark) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(height: 105, alignment: Alignment.center, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(.08))), child: Text(text, style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : _muted)));
  Widget _error(String message, bool dark) => Padding(padding: const EdgeInsets.all(16), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(.06), borderRadius: BorderRadius.circular(14)), child: Text(message, style: TextStyle(fontSize: 11, color: dark ? Colors.white70 : Colors.red.shade700))));
  String _number(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
