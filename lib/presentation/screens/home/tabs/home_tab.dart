import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';

class HomeTab extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTab({super.key, required this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Timer? _loadTimer;

  static const _bg = Color(0xFFF8FAFC);
  static const _darkBg = Color(0xFF0B1121);
  static const _darkCard = Color(0xFF162033);
  static const _muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    // Render the shell immediately, then refresh Firebase in the background.
    _loadTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      try {
        context.read<HomeBloc>().add(HomeStarted());
      } catch (e) {
        debugPrint('Home background loading unavailable: $e');
      }
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final background = dark ? _darkBg : _bg;

        return Container(
          color: background,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              try {
                context.read<HomeBloc>().add(HomeDataRefreshed());
              } catch (e) {
                debugPrint('Home refresh unavailable: $e');
              }
            },
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader(context, state, dark)),
                SliverToBoxAdapter(child: _buildBanner(state, dark)),
                SliverToBoxAdapter(child: _buildQuickServices(context, dark)),
                SliverToBoxAdapter(child: _buildHealthOverview(state, dark)),
                SliverToBoxAdapter(child: _buildDoctorsSection(state, dark)),
                SliverToBoxAdapter(child: _buildProductsSection(dark)),
                SliverToBoxAdapter(child: _buildPlacesSection('مستشفيات مميزة', Icons.local_hospital_outlined, state.hospitals, dark)),
                SliverToBoxAdapter(child: _buildPlacesSection('مختبرات مميزة', Icons.biotech_outlined, state.labs, dark)),
                SliverToBoxAdapter(child: _buildPlacesSection('صيدليات مميزة', Icons.local_pharmacy_outlined, state.pharmacies, dark)),
                SliverToBoxAdapter(child: _buildArticlesSection(state, dark)),
                SliverToBoxAdapter(child: _buildTipsSection(state, dark)),
                SliverToBoxAdapter(child: _buildDiscoverSection(dark)),
                SliverToBoxAdapter(child: _buildWeatherAiSection(dark)),
                SliverToBoxAdapter(child: _buildCommunitySection(state, dark)),
                if (state.isLoading)
                  const SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                  )),
                if (state.hasError)
                  SliverToBoxAdapter(child: _buildError(state.errorMessage, dark)),
                const SliverToBoxAdapter(child: SizedBox(height: 34)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(BuildContext context, HomeState state, bool dark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : (hour < 17 ? 'مساء الخير' : 'مساء الخير');
    final name = state.userName.trim().isEmpty ? 'بك في صحتك' : state.userName.trim();

    return ClipPath(
      clipper: _HomeHeaderClipper(),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 18,
          right: 18,
          bottom: 34,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, AppColors.primary.withOpacity(.86)],
          ),
          boxShadow: const [BoxShadow(blurRadius: 24, offset: Offset(0, 10), color: Colors.black26)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'sehatak-home-avatar',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(.18),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                _headerIcon(Icons.notifications_none_rounded, badge: state.isLoggedIn ? '•' : null),
                const SizedBox(width: 7),
                _headerIcon(Icons.shopping_cart_outlined),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 18, offset: const Offset(0, 7))],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/icons/search/Search_button.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => const Icon(Icons.search_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('ابحث عن طبيب، خدمة أو دواء', style: TextStyle(color: _muted, fontSize: 13))),
                  Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/images/chat/microphone.png',
                    width: 23,
                    height: 23,
                    errorBuilder: (_, __, ___) => const Icon(Icons.mic_none_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon, {String? badge}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.white.withOpacity(.14), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        if (badge != null)
          Positioned(right: -1, top: -1, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
      ],
    );
  }

  Widget _buildBanner(HomeState state, bool dark) {
    if (state.bannerImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: _emptyBanner(dark),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: BannerCarousel(images: state.bannerImages, height: 174, autoPlay: true),
    );
  }

  Widget _emptyBanner(bool dark) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(.16), AppColors.primary.withOpacity(.05)]),
        border: Border.all(color: AppColors.primary.withOpacity(.12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Container(width: 62, height: 62, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.12), shape: BoxShape.circle), child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 34)),
          const SizedBox(width: 14),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('صحتك معك كل يوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 6), Text('اكتشف خدمات الرعاية الصحية بسهولة', style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : _muted))])),
        ],
      ),
    );
  }

  Widget _buildQuickServices(BuildContext context, bool dark) {
    const services = [
      ('pharmacy.png', 'الصيدلية', Icons.local_pharmacy_outlined),
      ('emergency.png', 'الطوارئ', Icons.emergency_outlined),
      ('medical_community.png', 'خدمات منزلية', Icons.home_work_outlined),
      ('blood_donation.png', 'تبرع بالدم', Icons.bloodtype_outlined),
      ('consultation.png', 'الأطباء', Icons.medical_services_outlined),
      ('laboratory.png', 'المختبرات', Icons.biotech_outlined),
      ('health_tips.png', 'صحتي', Icons.favorite_outline),
      ('wallet.png', 'المحفظة', Icons.account_balance_wallet_outlined),
      ('consultation.png', 'استشارة', Icons.chat_bubble_outline),
      ('map_location.png', 'بالقرب منك', Icons.location_on_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('الخدمات السريعة', dark),
        const SizedBox(height: 12),
        SizedBox(
          height: 98,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final item = services[i];
              return Container(
                width: 78,
                decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.primary.withOpacity(.10))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 45, height: 45, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Image.asset('assets/images/services/${item.$1}', fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(item.$3, color: AppColors.primary, size: 24))),
                  const SizedBox(height: 7),
                  Text(item.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF263238))),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildHealthOverview(HomeState state, bool dark) {
    final score = state.isLoaded ? 75 : 0;
    final stats = [
      ('السعرات', state.calories, 'kcal', Icons.local_fire_department_outlined),
      ('الخطوات', state.steps, 'خطوة', Icons.directions_walk_outlined),
      ('النوم', state.sleep, 'ساعة', Icons.bedtime_outlined),
      ('النبض', state.heartRate, 'bpm', Icons.favorite_outline),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('ملخصك الصحي', dark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))),
            child: Row(children: [
              SizedBox(width: 92, height: 92, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: score / 100, strokeWidth: 9, backgroundColor: AppColors.primary.withOpacity(.10), valueColor: const AlwaysStoppedAnimation(AppColors.primary)), Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$score', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF263238))), Text('صحة', style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted))])])),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مؤشر صحتك اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 5), Text('تابع عاداتك اليومية وحافظ على نمط حياة متوازن.', style: TextStyle(fontSize: 11.5, height: 1.45, color: dark ? Colors.white60 : _muted))])),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final s = stats[i];
              return Container(width: 145, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle), child: Icon(s.$4, color: AppColors.primary, size: 20)), const SizedBox(width: 9), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$1, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)), const SizedBox(height: 3), Text('${_formatNumber(s.$2)} ${s.$3}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238)))]))]));
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildDoctorsSection(HomeState state, bool dark) {
    if (state.doctors.isEmpty) return _sectionPlaceholder('أفضل الأطباء', 'سيظهر الأطباء الموثقون هنا بعد مزامنة البيانات.', Icons.medical_services_outlined, dark);
    final doctors = state.doctors.take(6).toList();
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('أفضل الأطباء', dark),
      const SizedBox(height: 12),
      SizedBox(height: 224, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: doctors.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => _doctorCard(doctors[i], dark))),
    ]));
  }

  Widget _doctorCard(Map<String, dynamic> doctor, bool dark) {
    final name = _stringValue(doctor, 'name', 'طبيب');
    final specialty = _stringValue(doctor, 'specialty', 'تخصص طبي');
    final image = _stringValueNullable(doctor, 'photoUrl') ?? _stringValueNullable(doctor, 'image');
    final rating = _stringValue(doctor, 'rating', '—');
    final verified = doctor['isVerified'] == true;
    return Container(width: 164, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Column(children: [
      Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(15), child: Container(width: double.infinity, height: 105, color: AppColors.primary.withOpacity(.08), child: image == null ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 45) : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: AppColors.primary, size: 45)))), if (verified) Positioned(top: 7, right: 7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified_rounded, color: Colors.white, size: 12), SizedBox(width: 3), Text('موثق', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800))]))) ]),
      const SizedBox(height: 9),
      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))),
      const SizedBox(height: 3), Text(specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: dark ? Colors.white60 : _muted)),
      const Spacer(), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16), SizedBox(width: 3), Text('★', style: TextStyle(color: Colors.transparent, fontSize: 1)),],),
      Text(rating, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF263238))),
    ]));
  }

  Widget _buildProductsSection(bool dark) {
    const products = [('باراسيتامول 500mg', 'مسكنات'), ('فيتامين D3', 'فيتامينات'), ('أوميغا 3', 'مكملات'), ('مستلزمات طبية', 'عناية')];
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('منتجات الصيدلية', dark), const SizedBox(height: 12),
      SizedBox(height: 172, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: products.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => Container(width: 152, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 76, width: double.infinity, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 34)), const SizedBox(height: 8), Text(products[i].$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 3), Text(products[i].$2, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)), const Spacer(), Text('اكتشف المنتج', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary))]))),
    ]));
  }

  Widget _buildPlacesSection(String title, IconData icon, List<Map<String, dynamic>> items, bool dark) {
    if (items.isEmpty) return _sectionPlaceholder(title, 'ستظهر البيانات هنا عند توفرها من Firebase.', icon, dark);
    final visible = items.take(6).toList();
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionHeader(title, dark), const SizedBox(height: 12), SizedBox(height: 122, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: visible.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) { final item = visible[i]; final name = _stringValue(item, 'name', title); final address = _stringValue(item, 'address', _stringValue(item, 'location', 'صنعاء')); final image = _stringValueNullable(item, 'imageUrl') ?? _stringValueNullable(item, 'image'); return Container(width: 245, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(13), child: Container(width: 72, height: 96, color: AppColors.primary.withOpacity(.08), child: image == null ? Icon(icon, color: AppColors.primary, size: 30) : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.primary, size: 30)))), const SizedBox(width: 10), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 5), Row(children: [Icon(Icons.location_on_outlined, size: 13, color: dark ? Colors.white54 : _muted), const SizedBox(width: 3), Expanded(child: Text(address, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)))]), const SizedBox(height: 7), Text('عرض التفاصيل', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary))]))])); }))]));
  }

  Widget _buildArticlesSection(HomeState state, bool dark) {
    if (state.articles.isEmpty) return _sectionPlaceholder('أحدث المقالات', 'مقالات صحية موثوقة ستظهر هنا.', Icons.article_outlined, dark);
    final articles = state.articles.take(4).toList();
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionHeader('أحدث المقالات', dark), const SizedBox(height: 12), GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: articles.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .95), itemBuilder: (_, i) { final a = articles[i]; final title = _stringValue(a, 'title', 'مقال صحي'); final image = _stringValueNullable(a, 'imageUrl') ?? _stringValueNullable(a, 'image'); return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(13), child: Container(width: double.infinity, color: AppColors.primary.withOpacity(.07), child: image == null ? const Icon(Icons.article_outlined, color: AppColors.primary, size: 32) : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.article_outlined, color: AppColors.primary, size: 32))))), const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(6)), child: const Text('صحة عامة', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.w800))), const SizedBox(height: 5), Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, height: 1.3, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238)))])); }]) )]));
  }

  Widget _buildTipsSection(HomeState state, bool dark) {
    final tips = state.tips.isEmpty ? const [{'title': 'شرب الماء', 'text': 'احرص على شرب الماء بانتظام طوال اليوم.'}, {'title': 'المشي', 'text': 'خصص وقتاً للحركة والمشي يومياً.'}, {'title': 'النوم', 'text': 'حافظ على روتين نوم منتظم ومريح.'}, {'title': 'الغذاء', 'text': 'نوّع غذاءك وأضف الخضروات والفواكه.'}] : state.tips.take(4).toList();
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionHeader('نصائح يومية', dark), const SizedBox(height: 12), SizedBox(height: 132, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: tips.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) { final t = tips[i]; return Container(width: 230, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primary.withOpacity(dark ? .13 : .07), borderRadius: BorderRadius.circular(19), border: Border.all(color: AppColors.primary.withOpacity(.12))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.12), shape: BoxShape.circle), child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 21)), const SizedBox(height: 8), Text(_stringValue(t, 'title', 'نصيحة صحية'), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 4), Text(_stringValue(t, 'text', _stringValue(t, 'content', 'نصيحة مفيدة لصحتك اليومية.')), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.35, color: dark ? Colors.white60 : _muted))])); }))]));
  }

  Widget _buildDiscoverSection(bool dark) {
    const items = [('medical_articles.png', 'مقالات طبية', Icons.article_outlined), ('health_insurance.png', 'تأمين صحي', Icons.shield_outlined), ('video_consultation.png', 'استشارة فيديو', Icons.video_call_outlined), ('packages.png', 'باقات صحية', Icons.inventory_2_outlined)];
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionHeader('اكتشف المزيد', dark), const SizedBox(height: 12), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, childAspectRatio: .78), itemBuilder: (_, i) { final x = items[i]; return Container(decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(13)), child: Image.asset('assets/images/services/${x.$1}', fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(x.$3, color: AppColors.primary, size: 22))), const SizedBox(height: 7), Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Text(x.$2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF263238))))])); })))]));
  }

  Widget _buildWeatherAiSection(bool dark) {
    return Padding(padding: const EdgeInsets.only(top: 24), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Expanded(child: _infoCard(Icons.wb_sunny_outlined, '28°C', 'طقس صنعاء', 'حافظ على الترطيب', dark)), const SizedBox(width: 10), Expanded(child: _infoCard(Icons.auto_awesome_rounded, 'صحتك + AI', 'توصيات مخصصة', 'نصائح مناسبة ليومك', dark))])));
  }

  Widget _infoCard(IconData icon, String title, String subtitle, String body, bool dark) {
    return Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 20)), const SizedBox(height: 8), Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 2), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)), const SizedBox(height: 6), Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, height: 1.35, color: dark ? Colors.white70 : _muted))]));
  }

  Widget _buildCommunitySection(HomeState state, bool dark) {
    if (state.communityPosts.isEmpty) return _sectionPlaceholder('مجتمع صحتك', 'شارك وتابع المحتوى الصحي من المجتمع.', Icons.groups_outlined, dark);
    return Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionHeader('مجتمع صحتك', dark), const SizedBox(height: 12), ...state.communityPosts.take(3).map((post) => _postCard(post, dark))]));
  }

  Widget _postCard(Map<String, dynamic> post, bool dark) {
    final name = _stringValue(post, 'authorName', _stringValue(post, 'name', 'مستخدم')); final text = _stringValue(post, 'text', _stringValue(post, 'content', ''));
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 19, backgroundColor: AppColors.primary.withOpacity(.10), child: const Icon(Icons.person_outline, color: AppColors.primary, size: 21)), const SizedBox(width: 10), Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238)))), const Icon(Icons.more_horiz, color: _muted)]), const SizedBox(height: 10), Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.5, color: dark ? Colors.white70 : const Color(0xFF475569))), const SizedBox(height: 10), Row(children: [const Icon(Icons.favorite_border, size: 19, color: AppColors.primary), const SizedBox(width: 5), Text(_stringValue(post, 'likesCount', '0'), style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)), const SizedBox(width: 18), const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary), const SizedBox(width: 5), Text(_stringValue(post, 'commentsCount', '0'), style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : _muted)), const Spacer(), const Icon(Icons.bookmark_border, size: 19, color: AppColors.primary)]),]));
  }

  Widget _sectionHeader(String title, bool dark) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF263238)))), Text('عرض الكل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary))]));
  }

  Widget _sectionPlaceholder(String title, String subtitle, IconData icon, bool dark) {
    return Padding(padding: const EdgeInsets.only(top: 24), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: dark ? _darkCard : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE7EEF2))), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.primary)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238))), const SizedBox(height: 3), Text(subtitle, style: TextStyle(fontSize: 10.5, color: dark ? Colors.white60 : _muted))]))]))));
  }

  Widget _buildError(String? message, bool dark) {
    return Container(margin: const EdgeInsets.fromLTRB(16, 20, 16, 0), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.red.withOpacity(.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.info_outline, color: Colors.red, size: 20), const SizedBox(width: 9), Expanded(child: Text(message?.trim().isNotEmpty == true ? message! : 'تعذر تحديث بعض البيانات. يمكنك متابعة استخدام التطبيق.', style: TextStyle(fontSize: 11, color: dark ? Colors.white70 : _muted)))]));
  }

  String _stringValue(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key]; if (value == null) return fallback; final text = value.toString().trim(); return text.isEmpty ? fallback : text;
  }

  String? _stringValueNullable(Map<String, dynamic> data, String key) {
    final value = data[key]; if (value == null) return null; final text = value.toString().trim(); return text.isEmpty ? null : text;
  }

  String _formatNumber(double value) {
    if (value == 0) return '—';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _HomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 24);
    path.quadraticBezierTo(size.width * .24, size.height + 4, size.width * .52, size.height - 10);
    path.quadraticBezierTo(size.width * .80, size.height - 25, size.width, size.height - 2);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
