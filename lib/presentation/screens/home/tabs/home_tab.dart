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

/// Canonical Home implementation. One screen, one navigation source, reusable sections.
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
      return {
        'temp': (current['temperature_2m'] as num?)?.toStringAsFixed(0),
        'condition': _weatherText(code),
      };
    } catch (_) {
      return {'condition': 'تعذر تحديث الطقس الآن'};
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
                SliverToBoxAdapter(
                  child: FeaturedFacilitiesGrid(
                    title: 'مستشفيات مميزة',
                    items: state.hospitals,
                    isHospital: true,
                    isDark: dark,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FeaturedFacilitiesGrid(
                    title: 'مختبرات مميزة',
                    items: state.labs,
                    isHospital: false,
                    isDark: dark,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _places(
                    'صيدليات مميزة',
                    state.pharmacies,
                    Icons.local_pharmacy_outlined,
                    dark,
                    more: () => _go(AppRouter.pharmacy),
                  ),
                ),
                SliverToBoxAdapter(child: _articles(state.articles, dark)),
                SliverToBoxAdapter(child: _tips(state.tips, dark)),
                SliverToBoxAdapter(child: _discover(dark)),
                SliverToBoxAdapter(child: _weather(dark)),
                SliverToBoxAdapter(child: _community(state.communityPosts, dark)),
                if (state.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                if (state.hasError)
                  SliverToBoxAdapter(
                    child: _error(state.errorMessage ?? 'حدث خطأ غير متوقع', dark),
                  ),
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
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 10,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _go(AppRouter.profile),
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.white24,
                  child: Text(
                    first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _go(AppRouter.profile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              _headerAction(Icons.notifications_none_rounded, AppRouter.notifications),
              const SizedBox(width: 8),
              _headerAction(Icons.shopping_cart_outlined, AppRouter.cart),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => _go(AppRouter.search),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.primary, size: 25),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ابحث عن طبيب، دواء أو خدمة...',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ),
                  Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 23),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, String route) => InkWell(
        onTap: () => _go(route),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      );

  Widget _banner(HomeState state, bool dark) {
    if (state.bannerImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withOpacity(.08),
          ),
          alignment: Alignment.center,
          child: Text(
            'صحتك معك كل يوم',
            style: TextStyle(color: dark ? Colors.white : _text, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: BannerCarousel(images: state.bannerImages, height: 180, autoPlay: true),
    );
  }

  Widget _quickServices(bool dark) => QuickServicesWidget(
        isDark: dark,
        onNavigate: (screen) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        ),
      );

  Widget _healthSummary(HomeState state, bool dark) => HomeHealthWidgets(
        state: state,
        isDark: dark,
        onNavigate: _go,
      );

  Widget _doctors(HomeState state, bool dark) {
    final doctors = state.doctors.take(6).toList();
    return _section(
      title: 'أفضل الأطباء',
      dark: dark,
      more: () => _go(AppRouter.doctors),
      child: doctors.isEmpty
          ? _empty('لا يوجد أطباء موثقون متاحون حالياً', dark)
          : SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final doctor = doctors[index];
                  final image = (doctor['photoUrl'] ?? doctor['image'] ?? '').toString();
                  final id = (doctor['id'] ?? doctor['uid'] ?? '').toString();
                  return InkWell(
                    onTap: () => _go(id.isEmpty ? AppRouter.doctors : '/doctor/$id'),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 168,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: image.isEmpty
                                ? Container(height: 92, width: double.infinity, color: AppColors.primary.withOpacity(.08), child: const Icon(Icons.person, color: AppColors.primary, size: 42))
                                : AppImage(imageUrl: image, height: 92, width: double.infinity, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 8),
                          Text((doctor['name'] ?? 'طبيب').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
                          const SizedBox(height: 3),
                          Text((doctor['specialty'] ?? 'تخصص طبي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                          const Spacer(),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                            const SizedBox(width: 3),
                            Text('${doctor['rating'] ?? 0}', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted)),
                          ]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _productsSection(bool dark) => _section(
        title: 'منتجات الصيدلية',
        dark: dark,
        more: () => _go(AppRouter.pharmacy),
        child: FutureBuilder<List<ProductModel>>(
          future: _products,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            final products = snapshot.data ?? const <ProductModel>[];
            if (products.isEmpty) return _empty('لا توجد منتجات متاحة حالياً', dark);
            return SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: products.length > 8 ? 8 : products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final product = products[index];
                  final image = product.imageUrl ?? '';
                  return InkWell(
                    onTap: () => _go(AppRouter.pharmacy),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 154,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: image.isEmpty
                                ? Container(height: 86, width: 86, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 36))
                                : AppImage(imageUrl: image, height: 86, width: 86, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 7),
                          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)),
                          const Spacer(),
                          Text('${product.price.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

  Widget _places(String title, List<Map<String, dynamic>> data, IconData icon, bool dark, {VoidCallback? more}) {
    final count = data.length > 8 ? 8 : data.length;
    return _section(
      title: title,
      dark: dark,
      more: more,
      child: data.isEmpty
          ? _empty('لا توجد بيانات متاحة حالياً', dark)
          : SizedBox(
              height: 112,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: count,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final item = data[index];
                  return InkWell(
                    onTap: () => _go(AppRouter.map),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((item['name'] ?? 'مرفق صحي').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)),
                                const SizedBox(height: 4),
                                Text((item['address'] ?? item['location'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _articles(List<Map<String, dynamic>> data, bool dark) {
    final count = data.length > 4 ? 4 : data.length;
    return _section(
      title: 'أحدث المقالات',
      dark: dark,
      more: () => _go(AppRouter.articles),
      child: data.isEmpty
          ? _empty('لا توجد مقالات منشورة حالياً', dark)
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .92),
              itemBuilder: (_, index) {
                final article = data[index];
                final image = (article['imageUrl'] ?? article['image'] ?? '').toString();
                return InkWell(
                  onTap: () => _go(AppRouter.articles),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: image.isEmpty
                              ? Container(height: 78, width: double.infinity, color: AppColors.primary.withOpacity(.07), child: const Center(child: Icon(Icons.article_outlined, color: AppColors.primary, size: 32)))
                              : AppImage(imageUrl: image, height: 78, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(9),
                          child: Text((article['title'] ?? article['name'] ?? 'مقال صحي').toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.35, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _tips(List<Map<String, dynamic>> data, bool dark) {
    final titles = data.isEmpty
        ? ['اشرب الماء', 'تحرك أكثر', 'نم جيداً']
        : data.take(4).map((e) => (e['title'] ?? e['name'] ?? 'نصيحة صحية').toString()).toList();
    final descriptions = data.isEmpty
        ? ['حافظ على الترطيب خلال اليوم.', 'المشي اليومي يساعد على صحة أفضل.', 'اجعل نومك منتظماً قدر الإمكان.']
        : data.take(4).map((e) => (e['content'] ?? e['description'] ?? '').toString()).toList();

    return _section(
      title: 'نصيحة اليوم',
      dark: dark,
      child: SizedBox(
        height: 108,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: titles.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) => InkWell(
            onTap: () => _showTip(titles[index], descriptions[index]),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(titles[index], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
                        const SizedBox(height: 4),
                        Text(descriptions[index], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white60 : _muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTip(String title, String text) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 38),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _discover(bool dark) {
    const items = [
      {'name': 'حجز موعد', 'icon': Icons.calendar_month_outlined, 'route': AppRouter.appointments},
      {'name': 'طوارئ', 'icon': Icons.emergency_outlined, 'route': AppRouter.emergency},
      {'name': 'خريطة', 'icon': Icons.map_outlined, 'route': AppRouter.map},
      {'name': 'باقات', 'icon': Icons.inventory_2_outlined, 'route': AppRouter.services},
    ];
    return _section(
      title: 'اكتشف المزيد',
      dark: dark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final item in items)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => _go(item['route']! as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon']! as IconData, color: AppColors.primary, size: 27),
                          const SizedBox(height: 5),
                          Text(item['name']! as String, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : _text)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _weather(bool dark) => _section(
        title: 'الطقس في صنعاء',
        dark: dark,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _weatherFuture,
          builder: (_, snapshot) {
            final data = snapshot.data ?? const <String, dynamic>{};
            final temp = data['temp'];
            final condition = (data['condition'] ?? 'جاري تحديث الطقس').toString();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 34),
                    const SizedBox(width: 12),
                    Expanded(child: Text(temp == null ? condition : '$temp° — $condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text))),
                    Text('اهتم بترطيبك اليوم', style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted)),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _community(List<Map<String, dynamic>> data, bool dark) => _section(
        title: 'مجتمع صحتك',
        dark: dark,
        more: () => _go(AppRouter.community),
        child: data.isEmpty
            ? InkWell(onTap: () => _go(AppRouter.community), child: _empty('لا توجد منشورات جديدة حالياً\nاضغط لفتح مجتمع صحتك', dark))
            : Column(
                children: [
                  for (final item in data.take(3))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: InkWell(
                        onTap: () => _go(AppRouter.community),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Expanded(child: Text((item['content'] ?? item['text'] ?? item['title'] ?? 'منشور صحي').toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.4, color: dark ? Colors.white : _text))),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      );

  Widget _section({required String title, required bool dark, required Widget child, VoidCallback? more}) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))),
                  if (more != null) TextButton(onPressed: more, child: const Text('عرض الكل')),
                ],
              ),
            ),
            child,
          ],
        ),
      );

  Widget _empty(String text, bool dark) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 105,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : _muted)),
        ),
      );

  Widget _error(String text, bool dark) => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
        ),
      );

  String _number(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}
