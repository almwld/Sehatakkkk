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
import 'package:sehatak/presentation/widgets/home/featured_facilities_grid.dart';

class HomeTab extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTab({super.key, required this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  Timer? _timer;
  late Future<List<ProductModel>> _products;
  late Future<Map<String, dynamic>> _weatherFuture;

  static const Color _lightBackground = Color(0xFFF7FAFA);
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
    _timer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        context.read<HomeBloc>().add(HomeStarted());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadWeather() async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=15.3694&longitude=44.1910'
        '&current=temperature_2m,weather_code'
        '&timezone=Asia%2FAden',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('weather request failed');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final current = (body['current'] as Map?)?.cast<String, dynamic>() ?? {};
      final code = (current['weather_code'] as num?)?.toInt() ?? -1;
      return <String, dynamic>{
        'temp': (current['temperature_2m'] as num?)?.toStringAsFixed(0),
        'condition': _weatherText(code),
      };
    } catch (_) {
      return <String, dynamic>{'condition': 'تعذر تحديث الطقس الآن'};
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

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(HomeDataRefreshed());
    setState(() {
      _products = PharmacyService().getAllProducts();
      _weatherFuture = _loadWeather();
    });
  }

  void _go(String route) {
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: dark ? _darkBackground : _lightBackground,
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
                    child: _error(
                      state.errorMessage ?? 'حدث خطأ غير متوقع',
                      dark,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير ☀️' : 'مساء الخير 🌙';
    final name = state.userName.trim().isEmpty ? 'مرحباً بك في صحتك' : state.userName.trim();
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
              CircleAvatar(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
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

  Widget _headerAction(IconData icon, String route) {
    return InkWell(
      onTap: () => _go(route),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

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
          child: Center(
            child: Text(
              'صحتك معك كل يوم',
              style: TextStyle(
                color: dark ? Colors.white : _text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: BannerCarousel(
        images: state.bannerImages,
        height: 180,
        autoPlay: true,
      ),
    );
  }

  Widget _quickServices(bool dark) {
    const items = <Map<String, dynamic>>[
      {'icon': Icons.local_pharmacy_outlined, 'name': 'الصيدلية', 'route': AppRouter.pharmacy},
      {'icon': Icons.emergency_outlined, 'name': 'الطوارئ', 'route': AppRouter.emergency},
      {'icon': Icons.home_work_outlined, 'name': 'خدمات منزلية', 'route': AppRouter.services},
      {'icon': Icons.bloodtype_outlined, 'name': 'تبرع بالدم', 'route': AppRouter.services},
      {'icon': Icons.medical_services_outlined, 'name': 'الأطباء', 'route': AppRouter.doctors},
      {'icon': Icons.biotech_outlined, 'name': 'المختبرات', 'route': AppRouter.labs},
      {'icon': Icons.favorite_outline, 'name': 'صحتي', 'route': AppRouter.dashboard},
      {'icon': Icons.account_balance_wallet_outlined, 'name': 'المحفظة', 'route': AppRouter.wallet},
      {'icon': Icons.chat_bubble_outline, 'name': 'استشارة', 'route': AppRouter.consultation},
      {'icon': Icons.location_on_outlined, 'name': 'بالقرب منك', 'route': AppRouter.map},
    ];

    return _section(
      title: 'الخدمات السريعة',
      dark: dark,
      child: SizedBox(
        height: 96,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) {
            final item = items[index];
            return InkWell(
              onTap: () => _go(item['route'] as String),
              borderRadius: BorderRadius.circular(17),
              child: Container(
                width: 78,
                decoration: BoxDecoration(
                  color: dark ? _darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppColors.primary,
                        size: 23,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['name'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: dark ? Colors.white : _text,
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

  Widget _healthSummary(HomeState state, bool dark) {
    final score = _healthScore(state);
    final stats = <Map<String, dynamic>>[
      {'name': 'السعرات', 'value': state.calories, 'unit': 'kcal', 'icon': Icons.local_fire_department_outlined},
      {'name': 'الخطوات', 'value': state.steps, 'unit': 'خطوة', 'icon': Icons.directions_walk_outlined},
      {'name': 'النوم', 'value': state.sleep, 'unit': 'ساعة', 'icon': Icons.bedtime_outlined},
      {'name': 'النبض', 'value': state.heartRate, 'unit': 'bpm', 'icon': Icons.favorite_outline},
    ];

    return _section(
      title: 'ملخصك الصحي',
      dark: dark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? _darkCard : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 8,
                          backgroundColor: AppColors.primary.withOpacity(.10),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: dark ? Colors.white : _text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مؤشر صحتك اليوم',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: dark ? Colors.white : _text,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          score == 0
                              ? 'أضف قياساتك الصحية لاحتساب المؤشر.'
                              : 'تابع نشاطك ونومك ومؤشراتك الحيوية باستمرار.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: dark ? Colors.white60 : _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: stats.map((item) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.06),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      children: [
                        Icon(item['icon'] as IconData, color: AppColors.primary, size: 18),
                        const SizedBox(height: 4),
                        Text(
                          item['name'] as String,
                          style: TextStyle(fontSize: 8.5, color: dark ? Colors.white60 : _muted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_number(item['value'] as double)} ${item['unit']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  int _healthScore(HomeState state) {
    if (state.calories == 0 && state.steps == 0 && state.sleep == 0 && state.heartRate == 0) {
      return 0;
    }
    final activity = (state.steps / 10000 * 35).clamp(0, 35);
    final sleep = (state.sleep / 8 * 25).clamp(0, 25);
    final calories = (state.calories / 3000 * 15).clamp(0, 15);
    final heart = state.heartRate >= 50 && state.heartRate <= 100 ? 25 : 10;
    return (activity + sleep + calories + heart).round().clamp(0, 100);
  }

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
                  return Container(
                    width: 168,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: dark ? _darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: image.isEmpty
                              ? Container(
                                  height: 92,
                                  width: double.infinity,
                                  color: AppColors.primary.withOpacity(.08),
                                  child: const Icon(Icons.person, color: AppColors.primary, size: 42),
                                )
                              : AppImage(
                                  imageUrl: image,
                                  height: 92,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (doctor['name'] ?? 'طبيب').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          (doctor['specialty'] ?? 'تخصص طبي').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: AppColors.primary),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                            const SizedBox(width: 3),
                            Text(
                              '${doctor['rating'] ?? 0}',
                              style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _productsSection(bool dark) {
    return _section(
      title: 'منتجات الصيدلية',
      dark: dark,
      more: () => _go(AppRouter.pharmacy),
      child: FutureBuilder<List<ProductModel>>(
        future: _products,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final products = snapshot.data ?? const <ProductModel>[];
          if (products.isEmpty) return _empty('لا توجد منتجات متاحة حالياً', dark);
          final count = products.length > 8 ? 8 : products.length;
          return SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final product = products[index];
                final image = product.imageUrl ?? '';
                return Container(
                  width: 154,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dark ? _darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: image.isEmpty
                            ? Container(
                                height: 86,
                                width: 86,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(.06),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 36),
                              )
                            : AppImage(imageUrl: image, height: 86, width: 86, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text),
                      ),
                      const Spacer(),
                      Text(
                        '${product.price.toStringAsFixed(0)} ر.ي',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _places(
    String title,
    List<Map<String, dynamic>> data,
    IconData icon,
    bool dark,
  ) {
    final count = data.length > 8 ? 8 : data.length;
    return _section(
      title: title,
      dark: dark,
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
                  return Container(
                    width: 190,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: dark ? _darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (item['name'] ?? 'مرفق صحي').toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (item['address'] ?? item['location'] ?? '').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted),
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
    );
  }

  Widget _articles(List<Map<String, dynamic>> data, bool dark) {
    final count = data.length > 4 ? 4 : data.length;
    return _section(
      title: 'أحدث المقالات',
      dark: dark,
      child: data.isEmpty
          ? _empty('لا توجد مقالات منشورة حالياً', dark)
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .92,
              ),
              itemBuilder: (_, index) {
                final article = data[index];
                final image = (article['imageUrl'] ?? article['image'] ?? '').toString();
                return Container(
                  decoration: BoxDecoration(
                    color: dark ? _darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: image.isEmpty
                            ? Container(
                                height: 78,
                                width: double.infinity,
                                color: AppColors.primary.withOpacity(.07),
                                child: const Center(child: Icon(Icons.article_outlined, color: AppColors.primary, size: 32)),
                              )
                            : AppImage(imageUrl: image, height: 78, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(9),
                        child: Text(
                          (article['title'] ?? article['name'] ?? 'مقال صحي').toString(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, height: 1.35, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _tips(List<Map<String, dynamic>> data, bool dark) {
    final titles = data.isEmpty
        ? <String>['اشرب الماء', 'تحرك أكثر', 'نم جيداً']
        : data.take(4).map((e) => (e['title'] ?? e['name'] ?? 'نصيحة صحية').toString()).toList();
    final descriptions = data.isEmpty
        ? <String>['حافظ على الترطيب خلال اليوم.', 'المشي اليومي يساعد على صحة أفضل.', 'اجعل نومك منتظماً قدر الإمكان.']
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
          itemBuilder: (_, index) {
            return InkWell(
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
            );
          },
        ),
      ),
    );
  }

  void _showTip(String title, String text) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 38),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _discover(bool dark) {
    final items = <Map<String, dynamic>>[
      {'name': 'مقالات', 'icon': Icons.article_outlined, 'route': AppRouter.more},
      {'name': 'تأمين', 'icon': Icons.health_and_safety_outlined, 'route': AppRouter.more},
      {'name': 'فيديو', 'icon': Icons.video_call_outlined, 'route': AppRouter.consultation},
      {'name': 'باقات', 'icon': Icons.inventory_2_outlined, 'route': AppRouter.services},
    ];

    return _section(
      title: 'اكتشف المزيد',
      dark: dark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: items.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _go(item['route'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 82,
                    decoration: BoxDecoration(
                      color: dark ? _darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'] as IconData, color: AppColors.primary, size: 27),
                        const SizedBox(height: 5),
                        Text(
                          item['name'] as String,
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : _text),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _weather(bool dark) {
    return _section(
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
                  Expanded(
                    child: Text(
                      temp == null ? condition : '$temp° — $condition',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text),
                    ),
                  ),
                  Text('اهتم بترطيبك اليوم', style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _community(List<Map<String, dynamic>> data, bool dark) {
    if (data.isEmpty) {
      return _section(
        title: 'مجتمع صحتك',
        dark: dark,
        child: _empty('لا توجد منشورات جديدة حالياً', dark),
      );
    }

    return _section(
      title: 'مجتمع صحتك',
      dark: dark,
      child: Column(
        children: data.take(3).map((item) {
          final text = (item['content'] ?? item['text'] ?? item['title'] ?? 'منشور صحي').toString();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.4, color: dark ? Colors.white : _text)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _section({
    required String title,
    required bool dark,
    required Widget child,
    VoidCallback? more,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text),
                  ),
                ),
                if (more != null)
                  TextButton(onPressed: more, child: const Text('عرض الكل')),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _empty(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 105,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : _muted)),
      ),
    );
  }

  Widget _error(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
      ),
    );
  }

  String _number(double value) {
    return value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
  }
}
