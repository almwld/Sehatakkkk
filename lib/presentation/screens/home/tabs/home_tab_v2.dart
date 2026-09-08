import 'dart:async';
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
  bool _showComposer = true;
  Timer? _composerTimer;

  static const _light = Color(0xFFF7FAFA);
  static const _dark = Color(0xFF081A1A);
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
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeBloc>().add(HomeStarted());
    });
  }

  @override
  void dispose() {
    _composerTimer?.cancel();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final direction = widget.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showComposer) setState(() => _showComposer = false);
    if (direction == ScrollDirection.forward && !_showComposer) setState(() => _showComposer = true);
    if (widget.scrollController.position.pixels <= 2 || widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 2) {
      if (!_showComposer) setState(() => _showComposer = true);
    }
  }

  Future<Map<String, dynamic>> _loadWeather() async {
    try {
      const latitude = 15.3694;
      const longitude = 44.1910;
      final uri = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code&timezone=Asia%2FAden');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw Exception('weather');
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

  void _go(String route) => context.push(route);

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(HomeDataRefreshed());
    setState(() {
      _products = PharmacyService().getAllProducts();
      _weather = _loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => CommunityBloc(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            color: dark ? _dark : _light,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _header(state)),
                  SliverToBoxAdapter(child: _banner(state, dark)),
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
                  SliverToBoxAdapter(child: _weatherCard(dark)),
                  SliverToBoxAdapter(child: _community(state.communityPosts, dark)),
                  if (state.hasError) SliverToBoxAdapter(child: _error(state.errorMessage ?? 'حدث خطأ', dark)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : hour < 17 ? 'مساء الخير' : 'مساء الخير';
    final name = state.userName.trim().isEmpty ? 'مرحباً بك في صحتك' : state.userName.trim();
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 10, 18, 18),
      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(34))),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.white24, child: Text(name.characters.first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))])),
          _topAction('assets/images/icons/top_bar/notifications.png', AppRouter.notifications),
          const SizedBox(width: 7),
          _topAction('assets/images/icons/top_bar/Shopping cart.png', AppRouter.cart),
        ]),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _go(AppRouter.search),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const LocalAssetIcon('assets/images/icons/search/Search_button.png', size: 24, semanticLabel: 'بحث'),
              const SizedBox(width: 9),
              const Expanded(child: Text('ابحث عن طبيب، دواء أو خدمة...', style: TextStyle(color: _muted, fontSize: 13))),
              GestureDetector(onTap: () => _go('${AppRouter.search}?voice=true'), child: const LocalAssetIcon('assets/images/chat/microphone.png', size: 23, semanticLabel: 'بحث صوتي')),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _topAction(String asset, String route) => InkWell(onTap: () => _go(route), borderRadius: BorderRadius.circular(22), child: Container(width: 42, height: 42, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: LocalAssetIcon(asset, size: 24)));

  Widget _banner(HomeState state, bool dark) {
    final images = state.bannerImages.isEmpty ? ImageKit.bannerList : state.bannerImages;
    return Padding(padding: const EdgeInsets.only(top: 14), child: BannerCarousel(images: images, height: 180, viewportFraction: .92, autoPlay: true));
  }

  Widget _healthStats(HomeState state, bool dark) {
    final stats = [
      ('السعرات', state.calories, 'kcal', AppAssets.caloriesIcon, 3000.0),
      ('الخطوات', state.steps, 'خطوة', AppAssets.stepsIcon, 10000.0),
      ('النوم', state.sleep, 'ساعة', AppAssets.sleepIcon, 8.0),
      ('النبض', state.heartRate, 'bpm', AppAssets.heartRateIcon, 100.0),
    ];
    return _section('مؤشراتك اليوم', dark, Row(children: stats.map((s) => Expanded(child: _metric(s.$1, s.$2, s.$3, s.$4, s.$5, dark))).toList()));
  }

  Widget _metric(String name, double value, String unit, String asset, double max, bool dark) {
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [
      SizedBox(width: 58, height: 58, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: ratio, strokeWidth: 5, backgroundColor: AppColors.primary.withOpacity(.10), valueColor: const AlwaysStoppedAnimation(AppColors.primary)), LocalAssetIcon(asset, size: 18)])),
      const SizedBox(height: 5), Text(name, style: TextStyle(fontSize: 8.5, color: dark ? Colors.white60 : _muted)), Text('${_number(value)} $unit', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)),
    ])));
  }

  Widget _quickServices(bool dark) {
    const items = [
      (AppAssets.servicePharmacy, 'الصيدلية', AppRouter.pharmacy),
      (AppAssets.serviceEmergency, 'الطوارئ', AppRouter.emergency),
      (AppAssets.serviceMedicalCommunity, 'خدمات منزلية', AppRouter.services),
      (AppAssets.serviceBloodDonation, 'تبرع بالدم', '/blood-donation'),
      (AppAssets.serviceConsultation, 'الأطباء', AppRouter.doctors),
      (AppAssets.serviceLaboratory, 'المختبرات', AppRouter.labs),
      (AppAssets.serviceHealthTips, 'صحتي', AppRouter.dashboard),
      (AppAssets.serviceWallet, 'المحفظة', AppRouter.wallet),
      (AppAssets.serviceConsultation, 'استشارة', AppRouter.consultation),
      (AppAssets.serviceMapLocation, 'بالقرب منك', AppRouter.map),
    ];
    return _section('الخدمات السريعة', dark, SizedBox(height: 82, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => InkWell(onTap: () => _go(items[i].$3), child: SizedBox(width: 60, child: Column(children: [LocalAssetIcon(items[i].$1, size: 44), const SizedBox(height: 4), Text(items[i].$2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white70 : _text))]))))));
  }

  Widget _vitals(bool dark) {
    const items = [
      (AppAssets.trackingBloodPressure, 'ضغط الدم', '120/80', AppRouter.dashboard),
      (AppAssets.trackingBloodSugar, 'سكر الدم', '98', '/glucose-tracker'),
      (AppAssets.trackingFitness, 'اللياقة', '85%', '/health-dashboard'),
      (AppAssets.trackingWeight, 'الوزن', '72 كجم', '/weight-tracker'),
      (AppAssets.trackingNutrition, 'التغذية', 'جيد', AppRouter.dashboard),
      (AppAssets.trackingMentalHealth, 'الصحة النفسية', 'ممتاز', AppRouter.dashboard),
    ];
    return _section('المؤشرات الحيوية', dark, GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1), itemBuilder: (_, i) => InkWell(onTap: () => _go(items[i].$4), borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(items[i].$1, size: 46), const SizedBox(height: 6), Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)), Text(items[i].$3, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w900))]))));
  }

  Widget _doctors(HomeState state, bool dark) {
    final doctors = state.doctors.take(6).toList();
    return _section('أفضل الأطباء', dark, doctors.isEmpty ? _empty('لا يوجد أطباء موثقون متاحون حالياً', dark) : SizedBox(height: 220, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: doctors.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
      final d = doctors[i];
      final id = (d['id'] ?? d['doctorId'] ?? d['userId'] ?? '').toString();
      return InkWell(onTap: id.isEmpty ? null : () => _go('/doctor/$id'), child: Container(width: 160, padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(13), child: AppImage(imageUrl: (d['photoUrl'] ?? d['image'] ?? ImageKit.doctor1).toString(), width: double.infinity, fit: BoxFit.cover))),
        const SizedBox(height: 7), Text((d['name'] ?? 'طبيب').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _text, fontSize: 12)),
        Text((d['specialty'] ?? 'تخصص طبي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 9.5)),
        const SizedBox(height: 4), Text('★ ${d['rating'] ?? 0}  •  حجز موعد', style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
      ])));
    })));
  }

  Widget _products(bool dark) => _section('منتجات الصيدلية', dark, FutureBuilder<List<ProductModel>>(future: _products, builder: (_, snap) {
    if (snap.connectionState == ConnectionState.waiting) return const SizedBox(height: 210, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    final products = snap.data ?? const <ProductModel>[];
    if (products.isEmpty) return _empty('لا توجد منتجات متاحة حالياً', dark);
    return SizedBox(height: 230, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: products.take(8).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
      final p = products[i];
      return Container(width: 155, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Stack(children: [Center(child: AppImage(imageUrl: p.imageUrl ?? ImageKit.medicine1, width: 90, height: 90, fit: BoxFit.contain)), Positioned(top: 0, right: 0, child: InkWell(onTap: () => _go(AppRouter.cart), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: const LocalAssetIcon(AppAssets.cartIcon, size: 18))))])),
        Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)),
        const SizedBox(height: 4), Text('${p.price.toStringAsFixed(0)} ر.ي', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12)),
      ]);
    }));
  }));

  Widget _places(String title, List<Map<String, dynamic>> data, String fallback, bool dark) => _section(title, dark, data.isEmpty ? _empty('لا توجد بيانات متاحة حالياً', dark) : SizedBox(height: 150, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: data.take(6).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
    final item = data[i];
    final image = (item['imageUrl'] ?? item['image'] ?? fallback).toString();
    return Container(width: 190, padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: AppImage(imageUrl: image, width: double.infinity, fit: BoxFit.cover, borderRadius: BorderRadius.circular(12))), const SizedBox(height: 6), Text((item['name'] ?? 'منشأة صحية').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text((item['address'] ?? item['location'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: dark ? Colors.white60 : _muted))]));
  })));

  Widget _articles(List<Map<String, dynamic>> data, bool dark) => _section('أحدث المقالات', dark, data.isEmpty ? _empty('لا توجد مقالات منشورة حالياً', dark) : GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: data.take(4).length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: .95), itemBuilder: (_, i) { final a = data[i]; return InkWell(onTap: () => _go(AppRouter.more), child: Container(decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15)), clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: AppImage(imageUrl: (a['imageUrl'] ?? a['image'] ?? ImageKit.nutritionTips).toString(), width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(9), child: Text((a['title'] ?? a['name'] ?? 'مقال صحي').toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : _text)))]))); });

  Widget _tips(List<Map<String, dynamic>> data, bool dark) {
    final tips = data.take(4).toList();
    final fallback = [('شرب الماء', '8 أكواب يومياً', AppAssets.waterIcon), ('المشي', '30 دقيقة يومياً', AppAssets.stepsIcon), ('النوم', '7-8 ساعات', AppAssets.sleepIcon), ('الفواكه', '5 حصص يومياً', AppAssets.trackingNutrition)];
    return _section('النصائح اليومية', dark, GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: tips.isEmpty ? 4 : tips.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.1), itemBuilder: (_, i) { final title = tips.isEmpty ? fallback[i].$1 : (tips[i]['title'] ?? tips[i]['name'] ?? 'نصيحة صحية').toString(); final desc = tips.isEmpty ? fallback[i].$2 : (tips[i]['content'] ?? tips[i]['description'] ?? '').toString(); final asset = tips.isEmpty ? fallback[i].$3 : AppAssets.trackingNutrition; return InkWell(onTap: () => _showTip(title, desc), child: Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(asset, size: 44), const SizedBox(height: 6), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text(desc, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white60 : _muted))]))); });
  }

  void _showTip(String title, String text) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 10, 24, 30), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)), const SizedBox(height: 18), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')))]));

  Widget _discover(bool dark) {
    const items = [(AppAssets.serviceMedicalCommunity, 'مقالات', AppRouter.more), (AppAssets.serviceHealthInsurance, 'تأمين', AppRouter.more), (AppAssets.serviceVideoConsultation, 'فيديو', AppRouter.consultation), (AppAssets.serviceAiAssistant, 'باقات', AppRouter.services)];
    return _section('اكتشف المزيد', dark, Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: items.map((e) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(onTap: () => _go(e.$3), child: Container(height: 82, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(e.$1, size: 32), const SizedBox(height: 5), Text(e.$2, style: TextStyle(fontSize: 9.5, color: dark ? Colors.white : _text))])))))).toList())));
  }

  Widget _weatherCard(bool dark) => _section('الطقس والتوصيات', dark, FutureBuilder<Map<String, dynamic>>(future: _weather, builder: (_, snap) { final d = snap.data ?? {}; final temp = d['temp']; return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [const LocalAssetIcon(AppAssets.trackingNutrition, size: 38), const SizedBox(width: 12), Expanded(child: Text(temp == null ? (d['condition'] ?? 'جاري تحديث الطقس') : '$temp° — ${d['condition']}', style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), const Text('اهتم بترطيبك اليوم', style: TextStyle(fontSize: 9, color: AppColors.primary))]))); }));

  Widget _community(List<Map<String, dynamic>> data, bool dark) {
    final posts = data.take(3).toList();
    return _section('مجتمع صحتك', dark, Column(children: [
      ...posts.asMap().entries.map((entry) => _postCard(entry.value, entry.key, dark)),
      if (posts.isEmpty) _empty('لا توجد منشورات جديدة حالياً', dark),
    ]));
  }

  Widget _postCard(Map<String, dynamic> item, int index, bool dark) {
    final post = CommunityPostModel.fromFirestore(_MapDoc(item, 'home_$index'));
    final image = post.images?.isNotEmpty == true ? post.images!.first : post.imageUrl;
    return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: Container(decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(12), child: Row(children: [CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(.12), child: Text(post.userName.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(post.userName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)), Text(post.isVerified == true ? 'طبيب موثق' : 'عضو المجتمع', style: const TextStyle(fontSize: 9, color: AppColors.primary))])), Text(post.timeAgo, style: TextStyle(fontSize: 8.5, color: dark ? Colors.white54 : _muted))])),
      Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text)).paddingSymmetric(horizontal: 12),
      if ((post.content ?? '').isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(12, 6, 12, 8), child: Text(post.content!, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.45, color: dark ? Colors.white70 : _text))),
      if (image != null && image.isNotEmpty) SizedBox(height: 190, width: double.infinity, child: AppImage(imageUrl: image, fit: BoxFit.cover)),
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [TextButton(onPressed: () => _toggleLike(post, index), child: Text('إعجاب ${post.likes}')), TextButton(onPressed: () => _comment(post, index), child: Text('تعليق ${post.comments}')), TextButton(onPressed: () => _share(post, index), child: Text('مشاركة ${post.shares}')), const Spacer(), TextButton(onPressed: () => context.read<CommunityBloc>().add(SaveCommunityPost(postId: post.id, index: index)), child: Text(post.isSaved ? 'محفوظ' : 'حفظ'))]))
    ])));
  }

  Future<void> _toggleLike(CommunityPostModel post, int index) async => context.read<CommunityBloc>().add(ToggleLikePost(postId: post.id, index: index));

  Future<void> _comment(CommunityPostModel post, int index) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('إضافة تعليق'), content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب تعليقك...')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('إرسال'))]));
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) context.read<CommunityBloc>().add(AddCommunityComment(postId: post.id, index: index, comment: result));
  }

  Future<void> _share(CommunityPostModel post, int index) async {
    await CommunityShareService.sharePost(context, post);
    if (mounted) context.read<CommunityBloc>().add(ShareCommunityPost(postId: post.id, index: index));
  }

  Widget _section(String title, bool dark, Widget child) => Padding(padding: const EdgeInsets.only(top: 18), child: Column(children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerRight, child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : _text))), const SizedBox(height: 9), child]));

  Widget _empty(String text, bool dark) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(height: 95, width: double.infinity, alignment: Alignment.center, decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(16)), child: Text(text, style: TextStyle(color: dark ? Colors.white60 : _muted)));
  Widget _error(String text, bool dark) => Padding(padding: const EdgeInsets.all(16), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)));
  String _number(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}

class _MapDoc implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;
  _MapDoc(this._data, this._id);
  @override String get id => _id;
  @override Map<String, dynamic>? data() => _data;
  @override DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError();
  @override SnapshotMetadata get metadata => throw UnimplementedError();
  @override bool get exists => true;
  @override operator [](Object? field) => _data[field];
  @override DocumentSnapshot<Map<String, dynamic>>? get existsAsDocumentSnapshot => this;
}
