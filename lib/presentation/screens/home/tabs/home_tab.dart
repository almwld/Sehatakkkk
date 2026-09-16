import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
import 'package:sehatak/core/services/pharmacy_service.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:sehatak/presentation/screens/home/widgets/quick_services_widget.dart';
import 'package:sehatak/presentation/widgets/home/home_health_widgets.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/home/featured_facilities_grid.dart';

/// Canonical Home implementation. Dynamic sections use only real source data.
class HomeTab extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTab({super.key, required this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  Timer? _startTimer;
  late Future<List<ProductModel>> _products;
  late Future<Map<String, dynamic>> _weatherFuture;

  static const Color _background = Color(0xFFF7FAFA);
  static const Color _darkBackground = Color(0xFF081A1A);
  static const Color _darkCard = Color(0xFF102A2A);
  static const Color _text = Color(0xFF173131);
  static const Color _muted = Color(0xFF6B7D7D);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _products = PharmacyService().getAllProducts();
    _weatherFuture = _loadWeather();
    _startTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) context.read<HomeBloc>().add(HomeStarted());
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    super.dispose();
  }

  void _go(String route) {
    if (!mounted || route.trim().isEmpty) return;
    try {
      AppRouter.router.push(route);
    } catch (e, st) {
      debugPrint('Home navigation failed: $route $e\n$st');
    }
  }

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(HomeDataRefreshed());
    setState(() {
      _products = PharmacyService().getAllProducts();
      _weatherFuture = _loadWeather();
    });
  }

  Future<Map<String, dynamic>> _loadWeather() async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=15.3694&longitude=44.1910&current=temperature_2m,weather_code&timezone=Asia%2FAden',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw Exception('weather request failed');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final current = (body['current'] as Map?)?.cast<String, dynamic>() ?? {};
      final code = (current['weather_code'] as num?)?.toInt() ?? -1;
      final temp = (current['temperature_2m'] as num?)?.toStringAsFixed(0);
      if (temp == null || code < 0) throw Exception('invalid weather response');
      return {'temp': temp, 'condition': _weatherText(code)};
    } catch (_) {
      return {};
    }
  }

  String _weatherText(int code) {
    if (code == 0) return 'صحو';
    if (code <= 3) return 'غائم جزئياً';
    if (code <= 48) return 'ضباب';
    if (code <= 67) return 'أمطار';
    if (code <= 77) return 'ثلوج';
    if (code <= 82) return 'زخات مطر';
    return 'عواصف رعدية';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: dark ? _darkBackground : _background,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header(state)),
                SliverToBoxAdapter(child: _banner(state, dark)),
                SliverToBoxAdapter(child: _quickServices(dark)),
                SliverToBoxAdapter(child: _healthSummary(state, dark)),
                SliverToBoxAdapter(child: _doctors(state, dark)),
                SliverToBoxAdapter(child: _productsSection(dark)),
                SliverToBoxAdapter(child: FeaturedFacilitiesGrid(title: 'مستشفيات مميزة', items: state.hospitals, isHospital: true, isDark: dark)),
                SliverToBoxAdapter(child: FeaturedFacilitiesGrid(title: 'مختبرات مميزة', items: state.labs, isHospital: false, isDark: dark)),
                SliverToBoxAdapter(child: _places('صيدليات مميزة', state.pharmacies, Icons.local_pharmacy_outlined, dark, more: () => _go(AppRouter.pharmacy))),
                SliverToBoxAdapter(child: _articles(state.articles, dark)),
                SliverToBoxAdapter(child: _tips(state.tips, dark)),
                SliverToBoxAdapter(child: _discover(dark)),
                SliverToBoxAdapter(child: _weather(dark)),
                SliverToBoxAdapter(child: _community(state.communityPosts, dark)),
                if (state.isLoading) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))),
                if (state.hasError) SliverToBoxAdapter(child: _error(state.errorMessage ?? 'حدث خطأ غير متوقع', dark)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final name = state.userName.trim().isEmpty ? 'مستخدم' : state.userName.trim();
    final first = name.characters.isEmpty ? 'ص' : name.characters.first;
    return Container(
      height: 194,
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 10, 18, 18),
      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(34))),
      child: Column(children: [
        Row(children: [
          InkWell(onTap: () => _go(AppRouter.profile), borderRadius: BorderRadius.circular(24), child: CircleAvatar(radius: 23, backgroundColor: Colors.white24, child: Text(first, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)))),
          const SizedBox(width: 12),
          Expanded(child: InkWell(onTap: () => _go(AppRouter.profile), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 3), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))]))),
          _headerAction(Icons.notifications_none_rounded, AppRouter.notifications),
          const SizedBox(width: 8),
          _headerAction(Icons.shopping_cart_outlined, AppRouter.cart),
        ]),
        const SizedBox(height: 18),
        InkWell(onTap: () => _go(AppRouter.search), borderRadius: BorderRadius.circular(18), child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.search_rounded, color: AppColors.primary, size: 25), SizedBox(width: 10), Expanded(child: Text('ابحث عن طبيب، دواء أو خدمة...', style: TextStyle(color: _muted, fontSize: 13))), Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 23)]))),
      ]),
    );
  }

  Widget _headerAction(IconData icon, String route) => InkWell(onTap: () => _go(route), borderRadius: BorderRadius.circular(22), child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 21)));

  Widget _banner(HomeState state, bool dark) => state.bannerImages.isEmpty
      ? Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: Container(height: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.primary.withOpacity(.08)), alignment: Alignment.center, child: Text('لا توجد عروض متاحة حالياً', style: TextStyle(color: dark ? Colors.white : _text, fontSize: 16, fontWeight: FontWeight.w800))))
      : Padding(padding: const EdgeInsets.only(top: 14), child: BannerCarousel(images: state.bannerImages, height: 180, autoPlay: true));

  Widget _quickServices(bool dark) => QuickServicesWidget(isDark: dark, onNavigate: (screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)));

  Widget _healthSummary(HomeState state, bool dark) => HomeHealthWidgets(state: state, isDark: dark, onNavigate: _go);

  Widget _doctors(HomeState state, bool dark) {
    final doctors = state.doctors.take(6).toList();
    if (doctors.isEmpty) return _section(title: 'أفضل الأطباء', dark: dark, more: () => _go(AppRouter.doctors), child: _empty('لا يوجد أطباء موثقون متاحون حالياً', dark));
    return _section(title: 'أفضل الأطباء', dark: dark, more: () => _go(AppRouter.doctors), child: SizedBox(height: 220, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: doctors.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, index) {
      final doctor = doctors[index];
      final image = (doctor['photoUrl'] ?? doctor['image'] ?? '').toString();
      final id = (doctor['id'] ?? doctor['uid'] ?? '').toString();
      return InkWell(onTap: () => _go(id.isEmpty ? AppRouter.doctors : '/doctor/$id'), borderRadius: BorderRadius.circular(18), child: Container(width: 168, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [
        ClipRRect(borderRadius: BorderRadius.circular(14), child: image.isEmpty ? Container(height: 92, width: double.infinity, color: AppColors.primary.withOpacity(.08), child: const Icon(Icons.person, color: AppColors.primary, size: 42)) : AppImage(imageUrl: image, height: 92, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 8),
        Text((doctor['name'] ?? 'طبيب').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
        const SizedBox(height: 3), Text((doctor['specialty'] ?? 'تخصص طبي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
        const Spacer(), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 15), const SizedBox(width: 3), Text('${doctor['rating'] ?? 0}', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted))]),
      ])));
    })));
  }

  Widget _productsSection(bool dark) => _section(title: 'منتجات الصيدلية', dark: dark, more: () => _go(AppRouter.pharmacy), child: FutureBuilder<List<ProductModel>>(future: _products, builder: (_, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    final products = snapshot.data ?? const <ProductModel>[];
    if (products.isEmpty) return _empty('لا توجد منتجات متاحة حالياً', dark);
    return SizedBox(height: 210, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: products.length > 8 ? 8 : products.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) {
      final product = products[index];
      final image = product.imageUrl ?? '';
      return InkWell(onTap: () => _go(AppRouter.pharmacy), borderRadius: BorderRadius.circular(16), child: Container(width: 154, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: image.isEmpty ? const Icon(Icons.medication_outlined, color: AppColors.primary, size: 48) : AppImage(imageUrl: image, height: 100, width: 100, fit: BoxFit.contain)),
        const SizedBox(height: 6), Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)), const Spacer(), Text('${product.price} ريال', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w900)),
      ])));
    }));
  }));

  Widget _discover(bool dark) {
    final items = [
      {'name': 'حجز موعد', 'asset': 'assets/images/services/calendar_booking.png', 'route': AppRouter.appointments},
      {'name': 'طوارئ', 'asset': 'assets/images/services/emergency.png', 'route': AppRouter.emergency},
      {'name': 'خريطة', 'asset': 'assets/images/services/map_location.png', 'route': AppRouter.map},
      {'name': 'باقات', 'asset': 'assets/images/services/packages.png', 'route': AppRouter.services},
    ];
    return _section(title: 'اكتشف المزيد', dark: dark, child: SizedBox(height: 112, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) {
      final item = items[index];
      return InkWell(onTap: () => _go(item['route']!), borderRadius: BorderRadius.circular(16), child: Container(width: 92, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(item['asset']!, width: 42, height: 42, fit: BoxFit.contain), const SizedBox(height: 8), Text(item['name']!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text))])));
    })));
  }

  Widget _section({required String title, required bool dark, Widget? child, VoidCallback? more}) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), if (more != null) TextButton(onPressed: more, child: const Text('عرض الكل'))])), if (child != null) child]));

  Widget _empty(String text, bool dark) => Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white70 : _muted, fontSize: 13, fontWeight: FontWeight.w700))));

  Widget _places(String title, List<dynamic> items, IconData icon, bool dark, {VoidCallback? more}) {
    if (items.isEmpty) return _section(title: title, dark: dark, more: more, child: _empty('لا توجد صيدليات متاحة حالياً', dark));
    final pharmacies = items.take(6).toList();
    return _section(title: title, dark: dark, more: more, child: SizedBox(height: 158, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: pharmacies.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) {
      final item = Map<String, dynamic>.from(pharmacies[index] as Map);
      final name = (item['name'] ?? item['pharmacyName'] ?? 'صيدلية').toString();
      final address = (item['address'] ?? item['location'] ?? '').toString();
      final image = (item['imageUrl'] ?? item['photoUrl'] ?? item['image'] ?? '').toString();
      return InkWell(onTap: () => _go(AppRouter.pharmacy), borderRadius: BorderRadius.circular(16), child: Container(width: 190, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [if (image.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: image, width: 46, height: 46, fit: BoxFit.cover)) else Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary)), const SizedBox(width: 10), Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _text, fontSize: 12)))]),
        const SizedBox(height: 10), Text(address.isEmpty ? 'صيدلية متاحة' : address, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white70 : _muted, fontSize: 10)),
      ])));
    })));
  }

  Widget _articles(List<dynamic> items, bool dark) {
    if (items.isEmpty) return _section(title: 'مقالات طبية', dark: dark, child: _empty('لا توجد مقالات منشورة حالياً', dark));
    final articles = items.take(4).toList();
    return _section(title: 'مقالات طبية', dark: dark, child: SizedBox(height: 145, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: articles.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) {
      final item = Map<String, dynamic>.from(articles[index] as Map);
      final title = (item['title'] ?? item['name'] ?? '').toString();
      final summary = (item['summary'] ?? item['description'] ?? item['content'] ?? '').toString();
      final image = (item['imageUrl'] ?? item['coverUrl'] ?? item['image'] ?? '').toString();
      return Container(width: 230, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [if (image.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: image, width: 68, height: 68, fit: BoxFit.cover)) else Container(width: 68, height: 68, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.article_outlined, color: AppColors.primary)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title.isEmpty ? 'مقال طبي' : title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), if (summary.isNotEmpty) ...[const SizedBox(height: 5), Text(summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: dark ? Colors.white70 : _muted))]]))]));
    })));
  }

  Widget _tips(List<dynamic> items, bool dark) {
    if (items.isEmpty) return _section(title: 'نصائح يومية', dark: dark, child: _empty('لا توجد نصائح منشورة حالياً', dark));
    final tips = items.take(6).toList();
    return _section(title: 'نصائح يومية', dark: dark, child: SizedBox(height: 126, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: tips.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) {
      final item = Map<String, dynamic>.from(tips[index] as Map);
      final title = (item['title'] ?? item['name'] ?? item['tip'] ?? '').toString();
      final body = (item['content'] ?? item['description'] ?? item['text'] ?? '').toString();
      return Container(width: 235, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), shape: BoxShape.circle), child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.isEmpty ? 'نصيحة صحية' : title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), if (body.isNotEmpty) ...[const SizedBox(height: 5), Text(body, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted))]]))]));
    })));
  }

  Widget _weather(bool dark) => _section(title: 'الطقس', dark: dark, child: FutureBuilder<Map<String, dynamic>>(future: _weatherFuture, builder: (_, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    final data = snapshot.data ?? const <String, dynamic>{};
    final temp = data['temp']?.toString();
    final condition = data['condition']?.toString();
    if (temp == null || condition == null || temp.isEmpty) return _empty('تعذر الحصول على بيانات الطقس حالياً', dark);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(height: 96, padding: const EdgeInsets.symmetric(horizontal: 18), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 38), const SizedBox(width: 14), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('صنعاء', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), const SizedBox(height: 4), Text(condition, style: TextStyle(fontSize: 11, color: dark ? Colors.white70 : _muted))])), Text('$temp°', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))]));)  }));

  Widget _community(List<dynamic> items, bool dark) {
    if (items.isEmpty) return _section(title: 'المجتمع', dark: dark, child: _empty('لا توجد منشورات منشورة حالياً', dark));
    final posts = items.take(5).toList();
    return _section(title: 'المجتمع', dark: dark, child: Column(children: posts.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      final author = (item['authorName'] ?? item['userName'] ?? item['displayName'] ?? 'مستخدم').toString();
      final text = (item['content'] ?? item['text'] ?? item['body'] ?? '').toString();
      final image = (item['imageUrl'] ?? item['image'] ?? '').toString();
      return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withOpacity(.1), child: const Icon(Icons.person_outline, color: AppColors.primary)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(author, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), if (text.isNotEmpty) ...[const SizedBox(height: 5), Text(text, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: dark ? Colors.white70 : _muted))], if (image.isNotEmpty) ...[const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: image, height: 110, width: double.infinity, fit: BoxFit.cover))]]))]));
    }).toList());
  })
  Widget _error(String text, bool dark) => Padding(padding: const EdgeInsets.all(20), child: Text(text, style: TextStyle(color: dark ? Colors.white : _text)));
}
