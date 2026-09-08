import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/community/community_bloc.dart';
import 'package:sehatak/bloc/community/community_event.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
import 'package:sehatak/core/services/community_share_service.dart';
import 'package:sehatak/core/services/pharmacy_service.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';
import 'package:sehatak/presentation/widgets/create_post_sheet.dart';

class HomeTab extends StatefulWidget {
  final ScrollController scrollController;
  const HomeTab({super.key, required this.scrollController});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab> {
  late Future<List<ProductModel>> _products;
  late Future<Map<String, dynamic>> _weather;
  bool _showPostButton = true;
  static const _darkBg = Color(0xFF081A1A);
  static const _darkCard = Color(0xFF102A2A);
  static const _text = Color(0xFF173131);
  static const _muted = Color(0xFF6B7D7D);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _products = PharmacyService().getAllProducts();
    _weather = _loadWeather();
    widget.scrollController.addListener(_scrollPostButton);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeBloc>().add(HomeStarted());
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollPostButton);
    super.dispose();
  }

  void _scrollPostButton() {
    if (!mounted || !widget.scrollController.hasClients) return;
    final direction = widget.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showPostButton) setState(() => _showPostButton = false);
    if (direction == ScrollDirection.forward && !_showPostButton) setState(() => _showPostButton = true);
    final p = widget.scrollController.position.pixels;
    if ((p <= 2 || p >= widget.scrollController.position.maxScrollExtent - 2) && !_showPostButton) setState(() => _showPostButton = true);
  }

  Future<Map<String, dynamic>> _loadWeather() async {
    try {
      final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=15.3694&longitude=44.1910&current=temperature_2m,weather_code&timezone=Asia%2FAden')).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw Exception();
      final current = (jsonDecode(response.body)['current'] as Map).cast<String, dynamic>();
      final code = (current['weather_code'] as num?)?.toInt() ?? -1;
      return {'temp': (current['temperature_2m'] as num?)?.toStringAsFixed(0), 'condition': _weatherText(code)};
    } catch (_) {
      return {'condition': 'تعذر تحديث الطقس الآن'};
    }
  }

  String _weatherText(int code) {
    if (code == 0) return 'صحو';
    if (code <= 3) return 'غائم جزئياً';
    if (code <= 48) return 'ضباب';
    if (code <= 67) return 'أمطار';
    if (code <= 82) return 'زخات مطر';
    return 'عواصف رعدية';
  }

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(HomeDataRefreshed());
    setState(() { _products = PharmacyService().getAllProducts(); _weather = _loadWeather(); });
  }

  void _go(String route) => context.push(route);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => CommunityBloc(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          return Stack(children: [
            Container(
              color: dark ? _darkBg : const Color(0xFFF7FAFA),
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: widget.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _header(state)),
                    SliverToBoxAdapter(child: _banner(state)),
                    SliverToBoxAdapter(child: _healthStats(state, dark)),
                    SliverToBoxAdapter(child: _quickServices(dark)),
                    SliverToBoxAdapter(child: _vitals(dark)),
                    SliverToBoxAdapter(child: _doctors(state, dark)),
                    SliverToBoxAdapter(child: _products(dark)),
                    SliverToBoxAdapter(child: _places('مستشفيات مميزة', state.hospitals, AppAssets.hospital1, dark)),
                    SliverToBoxAdapter(child: _places('مختبرات مميزة', state.labs, AppAssets.lab1, dark)),
                    SliverToBoxAdapter(child: _places('صيدليات مميزة', state.pharmacies, AppAssets.pharmacy1, dark)),
                    SliverToBoxAdapter(child: _articles(state.articles, dark)),
                    SliverToBoxAdapter(child: _tips(state.tips, dark)),
                    SliverToBoxAdapter(child: _discover(dark)),
                    SliverToBoxAdapter(child: _weather(dark)),
                    SliverToBoxAdapter(child: _community(state.communityPosts, dark)),
                    if (state.hasError) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Text(state.errorMessage ?? 'حدث خطأ', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)))),
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ),
              ),
            ),
            if (_showPostButton)
              Positioned(left: 18, bottom: 24, child: _doctorPostButton()),
          ]);
        },
      ),
    );
  }

  Widget _header(HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final name = state.userName.trim().isEmpty ? 'مرحباً بك في صحتك' : state.userName.trim();
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 10, 18, 18),
      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(34))),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.white24, child: Text(name.characters.first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))])),
          _headerAction('assets/images/icons/top_bar/notifications.png', AppRouter.notifications),
          const SizedBox(width: 7),
          _headerAction('assets/images/icons/top_bar/Shopping cart.png', AppRouter.cart),
        ]),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _go(AppRouter.search),
          borderRadius: BorderRadius.circular(18),
          child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [
            const LocalAssetIcon('assets/images/icons/search/Search_button.png', size: 24, semanticLabel: 'بحث'),
            const SizedBox(width: 9),
            const Expanded(child: Text('ابحث عن طبيب، دواء أو خدمة...', style: TextStyle(color: _muted, fontSize: 13))),
            GestureDetector(onTap: () => _go('${AppRouter.search}?voice=true'), child: const LocalAssetIcon('assets/images/chat/microphone.png', size: 23, semanticLabel: 'بحث صوتي')),
          ])),
        ),
      ]),
    );
  }

  Widget _headerAction(String asset, String route) => InkWell(onTap: () => _go(route), borderRadius: BorderRadius.circular(22), child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: LocalAssetIcon(asset, size: 23)));

  Widget _banner(HomeState state) => Padding(padding: const EdgeInsets.only(top: 14), child: BannerCarousel(images: state.bannerImages.isEmpty ? ImageKit.bannerList : state.bannerImages, height: 180, viewportFraction: .92, autoPlay: true));

  Widget _healthStats(HomeState state, bool dark) {
    final items = [
      ('السعرات', state.calories, 'kcal', 'assets/images/tracking/fitness.png', 3000.0),
      ('الخطوات', state.steps, 'خطوة', 'assets/images/tracking/fitness.png', 10000.0),
      ('النوم', state.sleep, 'ساعة', 'assets/images/tracking/mental_health.png', 8.0),
      ('النبض', state.heartRate, 'bpm', 'assets/images/tracking/heart_rate.png', 100.0),
    ];
    return _section('مؤشراتك اليوم', dark, Padding(padding: const EdgeInsets.symmetric(horizontal: 13), child: Row(children: items.map((x) => Expanded(child: _metric(x.$1, x.$2, x.$3, x.$4, x.$5, dark))).toList())));
  }

  Widget _metric(String name, double value, String unit, String asset, double max, bool dark) {
    final ratio = (value / max).clamp(0.0, 1.0);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Container(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [
      SizedBox(width: 58, height: 58, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: ratio, strokeWidth: 5, backgroundColor: AppColors.primary.withOpacity(.10), valueColor: const AlwaysStoppedAnimation(AppColors.primary)), LocalAssetIcon(asset, size: 19)])),
      const SizedBox(height: 4), Text(name, style: TextStyle(fontSize: 8.5, color: dark ? Colors.white60 : _muted)), Text('${_number(value)} $unit', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
    ])));
  }

  Widget _quickServices(bool dark) {
    const items = [
      ('assets/images/services/pharmacy.png', 'الصيدلية', AppRouter.pharmacy), ('assets/images/services/emergency.png', 'الطوارئ', AppRouter.emergency), ('assets/images/services/medical_community.png', 'خدمات منزلية', AppRouter.services), ('assets/images/services/blood_donation.png', 'تبرع بالدم', '/blood-donation'), ('assets/images/services/consultation.png', 'الأطباء', AppRouter.doctors), ('assets/images/services/laboratory.png', 'المختبرات', AppRouter.labs), ('assets/images/services/health_tips.png', 'صحتي', AppRouter.dashboard), ('assets/images/services/wallet.png', 'المحفظة', AppRouter.wallet), ('assets/images/services/consultation.png', 'استشارة', AppRouter.consultation), ('assets/images/services/map_location.png', 'بالقرب منك', AppRouter.map),
    ];
    return _section('الخدمات السريعة', dark, SizedBox(height: 82, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => InkWell(onTap: () => _go(items[i].$3), child: SizedBox(width: 60, child: Column(children: [LocalAssetIcon(items[i].$1, size: 44), const SizedBox(height: 4), Text(items[i].$2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white70 : _text))]))))));
  }

  Widget _vitals(bool dark) {
    const items = [
      ('assets/images/tracking/blood_pressure.png', 'ضغط الدم', '120/80', AppRouter.dashboard), ('assets/images/tracking/blood_sugar.png', 'سكر الدم', '98', AppRouter.dashboard), ('assets/images/tracking/fitness.png', 'اللياقة', '85%', AppRouter.dashboard), ('assets/images/tracking/weight_tracking.png', 'الوزن', '72 كجم', AppRouter.dashboard), ('assets/images/tracking/nutrition.png', 'التغذية', 'جيد', AppRouter.dashboard), ('assets/images/tracking/mental_health.png', 'الصحة النفسية', 'ممتاز', AppRouter.dashboard),
    ];
    return _section('المؤشرات الحيوية', dark, GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1), itemBuilder: (_, i) => InkWell(onTap: () => _go(items[i].$4), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(items[i].$1, size: 46), const SizedBox(height: 6), Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)), Text(items[i].$3, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w900))]))));
  }

  Widget _doctors(HomeState state, bool dark) => _section('أفضل الأطباء', dark, state.doctors.isEmpty ? _empty('لا يوجد أطباء موثقون متاحون حالياً', dark) : SizedBox(height: 220, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: state.doctors.take(6).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final d = state.doctors[i]; final id = (d['id'] ?? d['doctorId'] ?? d['userId'] ?? '').toString(); return InkWell(onTap: id.isEmpty ? null : () => _go('/doctor/$id'), child: Container(width: 160, padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [Expanded(child: AppImage(imageUrl: (d['photoUrl'] ?? d['image'] ?? ImageKit.doctor1).toString(), width: double.infinity, fit: BoxFit.cover, borderRadius: BorderRadius.circular(13))), const SizedBox(height: 7), Text((d['name'] ?? 'طبيب').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text((d['specialty'] ?? 'تخصص طبي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: AppColors.primary)), const SizedBox(height: 4), Text('★ ${d['rating'] ?? 0}  •  حجز موعد', style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w800))]))); }));

  Widget _products(bool dark) => _section('منتجات الصيدلية', dark, FutureBuilder<List<ProductModel>>(future: _products, builder: (_, snap) { if (snap.connectionState == ConnectionState.waiting) return const SizedBox(height: 210, child: Center(child: CircularProgressIndicator(strokeWidth: 2))); final products = snap.data ?? const <ProductModel>[]; if (products.isEmpty) return _empty('لا توجد منتجات متاحة حالياً', dark); return SizedBox(height: 225, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: products.take(8).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final p = products[i]; return Container(width: 155, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(children: [Center(child: AppImage(imageUrl: p.imageUrl ?? ImageKit.medicine1, width: 90, height: 90, fit: BoxFit.contain)), Positioned(top: 0, right: 0, child: InkWell(onTap: () => _go(AppRouter.cart), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: const LocalAssetIcon('assets/images/icons/top_bar/Shopping cart.png', size: 18))))])), const SizedBox(height: 5), Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)), const SizedBox(height: 4), Text('${p.price.toStringAsFixed(0)} ر.ي', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12))])); })); });

  Widget _places(String title, List<Map<String, dynamic>> data, String fallback, bool dark) => _section(title, dark, data.isEmpty ? _empty('لا توجد بيانات متاحة حالياً', dark) : SizedBox(height: 150, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: data.take(6).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final x = data[i]; return Container(width: 190, padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: AppImage(imageUrl: (x['imageUrl'] ?? x['image'] ?? fallback).toString(), width: double.infinity, fit: BoxFit.cover, borderRadius: BorderRadius.circular(12))), const SizedBox(height: 6), Text((x['name'] ?? 'منشأة صحية').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text((x['address'] ?? x['location'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted))])); }));

  Widget _articles(List<Map<String, dynamic>> data, bool dark) => _section('أحدث المقالات', dark, data.isEmpty ? _empty('لا توجد مقالات منشورة حالياً', dark) : GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.take(4).length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: .95), itemBuilder: (_, i) { final a = data[i]; return InkWell(onTap: () => _go(AppRouter.more), child: Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: AppImage(imageUrl: (a['imageUrl'] ?? a['image'] ?? ImageKit.nutritionTips).toString(), width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(9), child: Text((a['title'] ?? a['name'] ?? 'مقال صحي').toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)))]))); });

  Widget _tips(List<Map<String, dynamic>> data, bool dark) {
    final fallback = [('شرب الماء', '8 أكواب يومياً', 'assets/images/tracking/nutrition.png'), ('المشي', '30 دقيقة يومياً', 'assets/images/tracking/fitness.png'), ('النوم', '7-8 ساعات', 'assets/images/tracking/mental_health.png'), ('الفواكه', '5 حصص يومياً', 'assets/images/tracking/nutrition.png')];
    return _section('النصائح اليومية', dark, GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.isEmpty ? 4 : data.take(4).length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.1), itemBuilder: (_, i) { final title = data.isEmpty ? fallback[i].$1 : (data[i]['title'] ?? data[i]['name'] ?? 'نصيحة صحية').toString(); final text = data.isEmpty ? fallback[i].$2 : (data[i]['content'] ?? data[i]['description'] ?? '').toString(); return InkWell(onTap: () => _showTip(title, text), child: Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(data.isEmpty ? fallback[i].$3 : 'assets/images/tracking/nutrition.png', size: 44), const SizedBox(height: 6), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text(text, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white60 : _muted))]))); });
  }

  void _showTip(String title, String text) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 10, 24, 30), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)), const SizedBox(height: 18), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')))]));

  Widget _discover(bool dark) { const items = [('assets/images/services/medical_articles.png', 'مقالات', AppRouter.more), ('assets/images/services/health_insurance.png', 'تأمين', AppRouter.more), ('assets/images/services/video_consultation.png', 'فيديو', AppRouter.consultation), ('assets/images/services/packages.png', 'باقات', AppRouter.services)]; return _section('اكتشف المزيد', dark, Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: items.map((x) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(onTap: () => _go(x.$3), child: Container(height: 82, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(x.$1, size: 32), const SizedBox(height: 5), Text(x.$2, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white : _text))])))))).toList()))); }

  Widget _weather(bool dark) => _section('الطقس والتوصيات', dark, FutureBuilder<Map<String, dynamic>>(future: _weather, builder: (_, snap) { final d = snap.data ?? const {}; return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [const LocalAssetIcon('assets/images/tracking/nutrition.png', size: 38), const SizedBox(width: 12), Expanded(child: Text(d['temp'] == null ? (d['condition'] ?? 'جاري تحديث الطقس') : '${d['temp']}° — ${d['condition']}', style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), const Text('اهتم بترطيبك اليوم', style: TextStyle(fontSize: 9, color: AppColors.primary))]))); }));

  Widget _community(List<Map<String, dynamic>> data, bool dark) => _section('مجتمع صحتك', dark, Column(children: [if (data.isEmpty) _empty('لا توجد منشورات جديدة حالياً', dark), ...data.take(3).toList().asMap().entries.map((e) => _postCard(_postFromMap(e.value, e.key), e.key, dark))]));

  CommunityPostModel _postFromMap(Map<String, dynamic> x, int index) => CommunityPostModel(id: (x['id'] ?? 'home_$index').toString(), userId: (x['userId'] ?? '').toString(), userName: (x['userName'] ?? x['authorName'] ?? 'مستخدم').toString(), userAvatar: x['userAvatar']?.toString(), title: (x['title'] ?? '').toString(), content: x['content']?.toString(), imageUrl: x['imageUrl']?.toString(), images: List<String>.from(x['images'] ?? const []), category: x['category']?.toString(), tags: List<String>.from(x['tags'] ?? const []), likes: (x['likes'] as num?)?.toInt() ?? 0, comments: (x['comments'] as num?)?.toInt() ?? 0, shares: (x['shares'] as num?)?.toInt() ?? 0, views: (x['views'] as num?)?.toInt() ?? 0, isLiked: x['isLiked'] == true, isSaved: x['isSaved'] == true, isVerified: x['isVerified'] == true, isDoctorPost: x['isDoctorPost'] == true, isPublished: x['isPublished'] != false);

  Widget _postCard(CommunityPostModel post, int index, bool dark) {
    final image = post.images?.isNotEmpty == true ? post.images!.first : post.imageUrl;
    return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(12), child: Row(children: [CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(.12), child: Text(post.userName.isEmpty ? 'ص' : post.userName.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(post.userName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text(post.isDoctorPost == true ? 'طبيب موثق' : 'عضو المجتمع', style: const TextStyle(fontSize: 9, color: AppColors.primary))])), Text(post.timeAgo, style: TextStyle(fontSize: 8.5, color: dark ? Colors.white54 : _muted))])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))),
      if ((post.content ?? '').isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(12, 6, 12, 8), child: Text(post.content!, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.45, color: dark ? Colors.white70 : _text))),
      if (image != null && image.isNotEmpty) SizedBox(height: 190, width: double.infinity, child: AppImage(imageUrl: image, fit: BoxFit.cover)),
      Row(children: [TextButton(onPressed: () => context.read<CommunityBloc>().add(ToggleLikePost(postId: post.id, index: index)), child: Text('إعجاب ${post.likes}')), TextButton(onPressed: () => _comment(post, index), child: Text('تعليق ${post.comments}')), TextButton(onPressed: () => _share(post, index), child: Text('مشاركة ${post.shares}')), const Spacer(), TextButton(onPressed: () => context.read<CommunityBloc>().add(SaveCommunityPost(postId: post.id, index: index)), child: Text(post.isSaved ? 'محفوظ' : 'حفظ'))]),
    ]));
  }

  Future<void> _comment(CommunityPostModel post, int index) async { final controller = TextEditingController(); final result = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('إضافة تعليق'), content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب تعليقك...')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('إرسال'))])); controller.dispose(); if (result != null && result.isNotEmpty && mounted) context.read<CommunityBloc>().add(AddCommunityComment(postId: post.id, index: index, comment: result)); }
  Future<void> _share(CommunityPostModel post, int index) async { await CommunityShareService.sharePost(context, post); if (mounted) context.read<CommunityBloc>().add(ShareCommunityPost(postId: post.id, index: index)); }

  Future<void> _openComposer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? const <String, dynamic>{};
    if (data['role'] != 'doctor' || data['isVerified'] != true) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إضافة المنشورات متاحة للأطباء الموثقين فقط')));
      return;
    }
    if (mounted) await CreatePostSheet.show(context);
  }

  Widget _doctorPostButton() => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(future: FirebaseAuth.instance.currentUser == null ? null : FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(), builder: (_, snap) {
    final data = snap.data?.data();
    if (data?['role'] != 'doctor' || data?['isVerified'] != true) return const SizedBox.shrink();
    return AnimatedScale(scale: _showPostButton ? 1 : 0, duration: const Duration(milliseconds: 180), child: FloatingActionButton(onPressed: _openComposer, backgroundColor: AppColors.primary, child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300))));
  });

  Widget _section(String title, bool dark, Widget child) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerRight, child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), const SizedBox(height: 9), child]));
  Widget _empty(String text, bool dark) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(height: 95, width: double.infinity, alignment: Alignment.center, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Text(text, style: TextStyle(color: dark ? Colors.white60 : _muted)));
  String _number(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}
