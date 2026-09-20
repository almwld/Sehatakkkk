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
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/health_tips/health_tips_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';

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
      debugPrint('Home navigation failed: $route\n$st');
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
          child: Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: widget.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _header(state)),
                    SliverToBoxAdapter(child: _banner(state, dark)),
                    SliverToBoxAdapter(child: _healthSummary(state, dark)),
                    SliverToBoxAdapter(child: _quickServices(dark)),
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
            ],
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
          _headerActionAsset('assets/icons/top_bar/notifications.png', AppRouter.notifications, Icons.notifications_none_rounded),
          const SizedBox(width: 8),
          _headerActionAsset('assets/icons/top_bar/Shopping cart.png', AppRouter.cart, Icons.shopping_cart_outlined),
        ]),
        const SizedBox(height: 18),
        InkWell(onTap: () => _go(AppRouter.search), borderRadius: BorderRadius.circular(18), child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Image.asset('assets/icons/search/Search_button.png', width: 25, height: 25, errorBuilder: (_, __, ___) => const Icon(Icons.search_rounded, color: AppColors.primary, size: 25)), SizedBox(width: 10), Expanded(child: Text('ابحث عن طبيب، دواء، أو خدمة...', style: TextStyle(color: _muted, fontSize: 13))), Image.asset('assets/icons/chat/microphone.png', width: 23, height: 23, errorBuilder: (_, __, ___) => const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 23))]))),
      ]),
    );
  }

  Widget _headerActionAsset(String asset, String route, IconData fallbackIcon) => InkWell(onTap: () => _go(route), borderRadius: BorderRadius.circular(22), child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: Image.asset(asset, width: 22, height: 22, errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.white, size: 21))));

  Widget _banner(HomeState state, bool dark) => state.bannerImages.isEmpty
      ? Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: Container(height: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.primary.withOpacity(.08)), alignment: Alignment.center, child: Text('صحتك معك كل يوم', style: TextStyle(color: dark ? Colors.white : _text, fontSize: 18, fontWeight: FontWeight.w900))))
      : Padding(padding: const EdgeInsets.only(top: 14), child: BannerCarousel(images: state.bannerImages, height: 180, autoPlay: true));

  Widget _quickServices(bool dark) => QuickServicesWidget(isDark: dark, onNavigate: (screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)));

  Widget _healthSummary(HomeState state, bool dark) => HomeHealthWidgets(state: state, isDark: dark, onNavigate: _go);

  Widget _doctors(HomeState state, bool dark) {
    final doctors = state.doctors.take(6).toList();
    if (doctors.isEmpty) {
      return _section(title: 'أفضل الأطباء', dark: dark, more: () => _go(AppRouter.doctors), child: _empty('لا يوجد أطباء موثقون متاحون حالياً', dark));
    }
    return _section(
      title: 'أفضل الأطباء',
      dark: dark,
      more: () => _go(AppRouter.doctors),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: doctors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.35),
        itemBuilder: (_, index) {
          final doctor = doctors[index];
          final image = (doctor['photoUrl'] ?? doctor['image'] ?? '').toString();
          final id = (doctor['id'] ?? doctor['uid'] ?? '').toString();
          return InkWell(
            onTap: () => _go(id.isEmpty ? AppRouter.doctors : '/doctor/$id'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image.isEmpty
                      ? Container(width: 62, height: 62, color: AppColors.primary.withOpacity(.08), child: const Icon(Icons.person, color: AppColors.primary, size: 32))
                      : AppImage(imageUrl: image, height: 62, width: 62, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text((doctor['name'] ?? 'طبيب').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
                  const SizedBox(height: 3),
                  Text((doctor['specialty'] ?? 'تخصص طبي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: AppColors.primary)),
                  if (doctor['rating'] != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 13), const SizedBox(width: 2), Text(doctor['rating'].toString(), style: TextStyle(fontSize: 9, color: dark ? Colors.white70 : _muted))]),
                  ],
                ])),
              ]),
            ),
          );
        },
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
            if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
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
                          Center(child: image.isEmpty ? const Icon(Icons.medication_outlined, color: AppColors.primary, size: 48) : AppImage(imageUrl: image, height: 100, width: 100, fit: BoxFit.contain)),
                          const SizedBox(height: 6),
                          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)),
                          const Spacer(),
                          Text('${product.price} ريال', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w900)),
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

  Widget _discover(bool dark) {
    final items = [
      {'name': 'حجز موعد', 'asset': 'assets/images/services/calendar_booking.png', 'route': AppRouter.appointments},
      {'name': 'طوارئ', 'asset': 'assets/images/services/emergency.png', 'route': AppRouter.emergency},
      {'name': 'خريطة', 'asset': 'assets/images/services/map_location.png', 'route': AppRouter.map},
      {'name': 'باقات', 'asset': 'assets/images/services/packages.png', 'route': AppRouter.packages},
      {'name': 'جميع الخدمات', 'asset': 'assets/images/ui/all_services.png', 'route': AppRouter.services},
    ];
    return _section(
      title: 'اكتشف المزيد',
      dark: dark,
      child: SizedBox(
        height: 112,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) {
            final item = items[index];
            return InkWell(
              onTap: () => _go(item['route']!),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 92,
                decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(item['asset']!, width: 42, height: 42, fit: BoxFit.contain),
                    const SizedBox(height: 8),
                    Text(item['name']!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _section({required String title, required bool dark, Widget? child, VoidCallback? more}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))),
                if (more != null) TextButton(onPressed: more, child: const Text('المزيد')),
              ],
            ),
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _empty(String text, bool dark) => Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(text, style: TextStyle(color: dark ? Colors.white70 : _muted))));

  Widget _places(String title, List<dynamic> items, IconData icon, bool dark, {VoidCallback? more}) {
    return _section(
      title: title,
      dark: dark,
      more: more,
      child: items.isEmpty
          ? _empty('لا توجد بيانات متاحة حالياً', dark)
          : SizedBox(
              height: 176,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = items[i] as Map<String, dynamic>;
                  final name = (item['name'] ?? item['pharmacyName'] ?? 'صيدلية').toString();
                  final image = (item['imageUrl'] ?? item['image'] ?? item['photoUrl'] ?? '').toString();
                  final location = (item['location'] ?? item['city'] ?? item['address'] ?? '').toString();
                  return InkWell(
                    onTap: more,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 170,
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: image.isEmpty
                              ? Container(height: 82, width: double.infinity, color: AppColors.primary.withOpacity(.08), child: Icon(icon, color: AppColors.primary, size: 34))
                              : AppImage(imageUrl: image, height: 82, width: double.infinity, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 7),
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: dark ? Colors.white : _text)),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted)),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _articles(List<dynamic> items, bool dark) => _dataCards('مقالات طبية', items, dark, 'assets/images/services/medical_articles.png', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArticlesScreen())), 'لا توجد مقالات منشورة حالياً', 'summary');

  Widget _tips(List<dynamic> items, bool dark) => _dataCards('نصائح يومية', items, dark, 'assets/images/services/health_tips.png', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthTipsScreen())), 'لا توجد نصائح منشورة حالياً', 'content');

  Widget _dataCards(String title, List<dynamic> items, bool dark, String asset, VoidCallback onMore, String emptyText, String subtitleKey) {
    return _section(
      title: title,
      dark: dark,
      more: onMore,
      child: items.isEmpty
          ? _empty(emptyText, dark)
          : SizedBox(
              height: 138,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = items[i] as Map<String, dynamic>;
                  final image = (item['imageUrl'] ?? item['image'] ?? '').toString();
                  final titleValue = (item['title'] ?? item['name'] ?? title).toString();
                  final subtitle = (item[subtitleKey] ?? item['description'] ?? '').toString();
                  return InkWell(
                    onTap: onMore,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: image.isEmpty
                              ? Image.asset(asset, width: 60, height: 60, fit: BoxFit.contain)
                              : AppImage(imageUrl: image, width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(titleValue, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: dark ? Colors.white : _text)),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, height: 1.3, color: dark ? Colors.white60 : _muted)),
                          ],
                        ])),
                      ]),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _weather(bool dark) {
    return _section(
      title: 'الطقس',
      dark: dark,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _weatherFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 92, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
          final data = snapshot.data ?? const <String, dynamic>{};
          final temp = data['temp']?.toString();
          final condition = data['condition']?.toString() ?? 'غير متوفر';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 34),
                const SizedBox(width: 12),
                Expanded(child: Text(condition, style: TextStyle(fontWeight: FontWeight.w800, color: dark ? Colors.white : _text))),
                if (temp != null) Text('$temp°', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _community(List<dynamic> items, bool dark) {
    return _section(
      title: 'المجتمع', dark: dark, more: () => _go(AppRouter.community),
      child: items.isEmpty ? _empty('لا توجد منشورات منشورة حالياً', dark) :
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: items.take(3).map((raw) {
          final data = Map<String, dynamic>.from(raw as Map);
          final createdAt = data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : data['createdAt'] is DateTime ? data['createdAt'] as DateTime : null;
          final post = CommunityPostModel(id: '${data['id'] ?? data['postId'] ?? ''}', userId: '${data['userId'] ?? ''}', userName: '${data['userName'] ?? 'مستخدم'}', title: '${data['title'] ?? 'منشور'}', content: data['content']?.toString(), imageUrl: data['imageUrl']?.toString(), images: (data['images'] as List?)?.map((e) => e.toString()).toList(), category: data['category']?.toString(), likes: (data['likes'] as num?)?.toInt() ?? 0, comments: (data['comments'] as num?)?.toInt() ?? 0, shares: (data['shares'] as num?)?.toInt() ?? 0, isVerified: data['isVerified'] == true, createdAt: createdAt);
          return Padding(padding: const EdgeInsets.only(bottom: 12), child: _HomeCommunityPost(post: post, dark: dark));
        }).toList())),
    );
  }
  Widget _error(String text, bool dark) => Padding(padding: const EdgeInsets.all(20), child: Text(text, style: TextStyle(color: dark ? Colors.white : _text)));
}

class _HomeCommunityPost extends StatefulWidget {
  final CommunityPostModel post; final bool dark;
  const _HomeCommunityPost({required this.post, required this.dark});
  @override State<_HomeCommunityPost> createState() => _HomeCommunityPostState();
}
class _HomeCommunityPostState extends State<_HomeCommunityPost> {
  static const Color _darkCard = Color(0xFF102A2A);
  late int _likes, _shares; bool _liked = false;
  @override void initState() { super.initState(); _likes = widget.post.likes; _shares = widget.post.shares; }
  Future<void> _like() async {
    final user = FirebaseAuth.instance.currentUser; if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('community_posts').doc(widget.post.id);
    final likeRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('liked_posts').doc(widget.post.id);
    await FirebaseFirestore.instance.runTransaction((tx) async { final snap = await tx.get(ref); final ls = await tx.get(likeRef); final likes = (snap.data()?['likes'] as num?)?.toInt() ?? 0; if (ls.exists) { tx.update(ref, {'likes': likes > 0 ? likes - 1 : 0}); tx.delete(likeRef); } else { tx.update(ref, {'likes': likes + 1}); tx.set(likeRef, {'postId': widget.post.id, 'likedAt': FieldValue.serverTimestamp()}); } });
    if (mounted) setState(() { _liked = !_liked; _likes += _liked ? 1 : -1; });
  }
  Future<void> _share() async { try { await FirebaseFirestore.instance.collection('community_posts').doc(widget.post.id).update({'shares': FieldValue.increment(1)}); await Share.share('${widget.post.title}\n${widget.post.content ?? ''}', subject: 'منشور من صحتك'); if (mounted) setState(() => _shares++); } catch (_) {} }
  @override Widget build(BuildContext context) { final p = widget.post; final image = p.images?.isNotEmpty == true ? p.images!.first : p.imageUrl;
    return Container(decoration: BoxDecoration(color: widget.dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.fromLTRB(14,14,14,8), child: Row(children: [CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.12), child: Text(p.userName.isEmpty ? 'ص' : p.userName.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.userName, style: TextStyle(fontWeight: FontWeight.w900, color: widget.dark ? Colors.white : Colors.black87)), Text('${p.category ?? 'عام'} • ${p.timeAgo}', style: TextStyle(fontSize: 10, color: widget.dark ? Colors.white60 : Colors.black54))]))])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(p.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.dark ? Colors.white : Colors.black87))),
      if ((p.content ?? '').trim().isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(14,6,14,10), child: Text(p.content!, style: TextStyle(height: 1.5, color: widget.dark ? Colors.white70 : Colors.black87))),
      if (image != null && image.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AppImage(imageUrl: image, height: 250, width: double.infinity, fit: BoxFit.cover))),
      Padding(padding: const EdgeInsets.fromLTRB(10,6,10,8), child: Row(children: [InkWell(onTap: _like, child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [Icon(_liked ? Icons.favorite : Icons.favorite_border, size: 20, color: _liked ? AppColors.primary : Colors.grey[600]), const SizedBox(width: 4), Text('$_likes', style: TextStyle(color: _liked ? AppColors.primary : Colors.grey[600], fontWeight: FontWeight.w700))]))), const SizedBox(width: 6), InkWell(onTap: _share, child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [Icon(Icons.share_outlined, size: 20, color: Colors.grey[600]), const SizedBox(width: 4), Text('$_shares', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w700))])))])),
    ]));
  }
}