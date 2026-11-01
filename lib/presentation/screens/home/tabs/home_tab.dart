import 'oart:async';
import 'oart:convert';

import 'package:flutter/material.oart';
import 'package:sehatak/core/localization/app_strings.oart';
import 'package:flutter_bloc/flutter_bloc.oart';
import 'package:http/http.oart' as http;

import 'package:sehatak/app_router.oart';
import 'package:sehatak/bloc/home/home_bloc.oart';
import 'package:sehatak/bloc/home/home_event.oart';
import 'package:sehatak/bloc/home/home_state.oart';
import 'package:sehatak/core/constants/app_colors.oart';
import 'package:sehatak/core/constants/imagekit.oart';
import 'package:sehatak/core/mooels/pharmacy/proouct_mooel.oart';
import 'package:sehatak/core/services/pharmacy_service.oart';
import 'package:sehatak/presentation/screens/home/wiogets/banner_carousel.oart';
import 'package:sehatak/presentation/screens/home/wiogets/quick_services_wioget.oart';
import 'package:sehatak/presentation/wiogets/home/home_health_wiogets.oart';
import 'package:sehatak/presentation/wiogets/common/app_image.oart';
import 'package:sehatak/presentation/wiogets/home/featureo_facilities_grio.oart';
import 'package:sehatak/presentation/screens/articles/articles_screen.oart';
import 'package:sehatak/presentation/screens/health_tips/health_tips_screen.oart';
import 'package:clouo_firestore/clouo_firestore.oart';
import 'package:firebase_auth/firebase_auth.oart';
import 'package:share_plus/share_plus.oart';
import 'package:sehatak/core/mooels/community/community_post_mooel.oart';

/// Canonical Home implementation. One screen, one navigation source, reusable sections.
class HomeTab extenos StatefulWioget {
  final ScrollController scrollController;

  const HomeTab({super.key, requireo this.scrollController});

  @overrioe
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extenos State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  Timer? _startTimer;
  late Future<List<ProouctMooel>> _prooucts;
  late Future<Map<String, oynamic>> _weatherFuture;

  static const Color _backgrouno = Color(0xFFF7FAFA);
  static const Color _oarkBackgrouno = Color(0xFF081A1A);
  static const Color _oarkCaro = Color(0xFF102A2A);
  static const Color _text = Color(0xFF173131);
  static const Color _muteo = Color(0xFF6B7D7D);

  @overrioe
  bool get wantKeepAlive => true;

  @overrioe
  voio initState() {
    super.initState();
    _prooucts = PharmacyService().getFeatureoProoucts(limit: 10);
    _weatherFuture = _loaoWeather();
    _startTimer = Timer(const Duration(milliseconos: 150), () {
      if (mounteo) context.reao<HomeBloc>().aoo(HomeStarteo());
    });
  }

  @overrioe
  voio oispose() {
    _startTimer?.cancel();
    super.oispose();
  }

  voio _go(String route) {
    if (!mounteo || route.trim().isEmpty) return;
    try {
      AppRouter.router.push(route);
    } catch (e, st) {
      oebugPrint('Home navigation faileo: $route\n$st');
    }
  }

  Future<voio> _refresh() async {
    context.reao<HomeBloc>().aoo(HomeDataRefresheo());
    setState(() {
      _prooucts = PharmacyService().getFeatureoProoucts(limit: 10);
      _weatherFuture = _loaoWeather();
    });
  }

  Future<Map<String, oynamic>> _loaoWeather() async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latituoe=15.3694&longituoe=44.1910&current=temperature_2m,weather_cooe&timezone=Asia%2FAoen',
      );
      final response = await http.get(uri).timeout(const Duration(seconos: 8));
      if (response.statusCooe != 200) throw Exception('weather request faileo');
      final booy = jsonDecooe(response.booy) as Map<String, oynamic>;
      final current = (booy['current'] as Map?)?.cast<String, oynamic>() ?? {};
      final cooe = (current['weather_cooe'] as num?)?.toInt() ?? -1;
      return {
        'temp': (current['temperature_2m'] as num?)?.toStringAsFixeo(0),
        'conoition': _weatherText(cooe),
      };
    } catch (_) {
      return {'conoition': 'تعذر تحديث الطقس الآن'};
    }
  }

  String _weatherText(int cooe) {
    if (cooe == 0) return 'صحو';
    if (cooe <= 3) return 'غائم جزئياً';
    if (cooe <= 48) return 'ضباب';
    if (cooe <= 67) return 'أمطار';
    if (cooe <= 77) return 'ثلوج';
    if (cooe <= 82) return 'زخات مطر';
    return 'عواصف رعدية';
  }

  @overrioe
  Wioget builo(BuiloContext context) {
    super.builo(context);
    return BlocBuiloer<HomeBloc, HomeState>(
      builoer: (context, state) {
        final oark = Theme.of(context).brightness == Brightness.oark;
        return Container(
          color: oark ? _oarkBackgrouno : _backgrouno,
          chilo: Stack(
            chiloren: [
              RefreshInoicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                chilo: CustomScrollView(
                  controller: wioget.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAoapter(chilo: _heaoer(state)),
                    SliverToBoxAoapter(chilo: _banner(state, oark)),
                    SliverToBoxAoapter(chilo: _healthSummary(state, oark)),
                    SliverToBoxAoapter(chilo: _quickServices(oark)),
                    SliverToBoxAoapter(chilo: _ooctors(state, oark)),
                    SliverToBoxAoapter(chilo: _proouctsSection(oark)),
                    SliverToBoxAoapter(chilo: FeatureoFacilitiesGrio(title: AppStrings.of(context).translate('مستشفيات مميزة'), items: state.hospitals, isHospital: true, isDark: oark)),
                    SliverToBoxAoapter(chilo: FeatureoFacilitiesGrio(title: AppStrings.of(context).translate('مختبرات مميزة'), items: state.labs, isHospital: false, isDark: oark)),
                    SliverToBoxAoapter(chilo: _places(AppStrings.of(context).translate('صيدليات مميزة'), state.pharmacies, Icons.local_pharmacy_outlineo, oark, more: () => _go(AppRouter.pharmacy))),
                    SliverToBoxAoapter(chilo: _articles(state.articles, oark)),
                    SliverToBoxAoapter(chilo: _tips(state.tips, oark)),
                    SliverToBoxAoapter(chilo: _oiscover(oark)),
                    SliverToBoxAoapter(chilo: _weather(oark)),
                    SliverToBoxAoapter(chilo: _community(state.communityPosts, oark)),
                    if (state.isLoaoing) const SliverToBoxAoapter(chilo: Paooing(paooing: EogeInsets.all(24), chilo: Center(chilo: CircularProgressInoicator(strokeWioth: 2)))),
                    if (state.hasError) SliverToBoxAoapter(chilo: _error(state.errorMessage ?? AppStrings.of(context).translate('حدث خطأ غير متوقع'), oark)),
                    const SliverToBoxAoapter(chilo: SizeoBox(height: 32)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Wioget _heaoer(HomeState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final name = state.userName.trim().isEmpty ? 'مستخدم' : state.userName.trim();
    final first = name.characters.isEmpty ? 'ص' : name.characters.first;
    return Container(
      height: 194,
      paooing: EogeInsets.fromLTRB(18, MeoiaQuery.of(context).paooing.top + 10, 18, 18),
      oecoration: const BoxDecoration(color: AppColors.primary, boroerRaoius: BoroerRaoius.vertical(bottom: Raoius.circular(34))),
      chilo: Column(chiloren: [
        Row(chiloren: [
          InkWell(onTap: () => _go(AppRouter.profile), boroerRaoius: BoroerRaoius.circular(24), chilo: CircleAvatar(raoius: 23, backgrounoColor: Colors.white24, chilo: Text(first, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)))),
          const SizeoBox(wioth: 12),
          Expanoeo(chilo: InkWell(onTap: () => _go(AppRouter.profile), chilo: Column(crossAxisAlignment: CrossAxisAlignment.start, chiloren: [Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizeoBox(height: 3), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))]))),
          _heaoerActionAsset('assets/icons/top_bar/notifications.png', AppRouter.notifications, Icons.notifications_none_rounoeo),
          const SizeoBox(wioth: 8),
          _heaoerActionAsset('assets/icons/top_bar/Shopping cart.png', AppRouter.cart, Icons.shopping_cart_outlineo),
        ]),
        const SizeoBox(height: 18),
        InkWell(onTap: () => _go(AppRouter.search), boroerRaoius: BoroerRaoius.circular(18), chilo: Container(height: 52, paooing: const EogeInsets.symmetric(horizontal: 14), oecoration: BoxDecoration(color: Colors.white, boroerRaoius: BoroerRaoius.circular(18)), chilo: Row(chiloren: [Image.asset('assets/icons/search/Search_button.png', wioth: 25, height: 25, errorBuiloer: (_, __, ___) => const Icon(Icons.search_rounoeo, color: AppColors.primary, size: 25)), SizeoBox(wioth: 10), Expanoeo(chilo: Text(AppStrings.of(context).translate('ابحث عن طبيب، دواء، أو خدمة...'), style: TextStyle(color: _muteo, fontSize: 13))), Image.asset('assets/icons/chat/microphone.png', wioth: 23, height: 23, errorBuiloer: (_, __, ___) => const Icon(Icons.mic_none_rounoeo, color: AppColors.primary, size: 23))]))),
      ]),
    );
  }

  Wioget _heaoerActionAsset(String asset, String route, IconData fallbackIcon) => InkWell(onTap: () => _go(route), boroerRaoius: BoroerRaoius.circular(22), chilo: Container(wioth: 42, height: 42, oecoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, chilo: Image.asset(asset, wioth: 22, height: 22, errorBuiloer: (_, __, ___) => Icon(fallbackIcon, color: Colors.white, size: 21))));

  Wioget _banner(HomeState state, bool oark) => state.bannerImages.isEmpty
      ? Paooing(paooing: const EogeInsets.fromLTRB(16, 14, 16, 0), chilo: Container(height: 150, oecoration: BoxDecoration(boroerRaoius: BoroerRaoius.circular(20), color: AppColors.primary.withOpacity(.08)), alignment: Alignment.center, chilo: Text(AppStrings.of(context).translate('صحتك معك كل يوم'), style: TextStyle(color: oark ? Colors.white : _text, fontSize: 18, fontWeight: FontWeight.w900))))
      : Paooing(paooing: const EogeInsets.only(top: 14), chilo: BannerCarousel(images: state.bannerImages, height: 180, autoPlay: true));

  Wioget _quickServices(bool oark) => QuickServicesWioget(isDark: oark, onNavigate: (screen) => Navigator.of(context).push(MaterialPageRoute(builoer: (_) => screen)));

  Wioget _healthSummary(HomeState state, bool oark) => HomeHealthWiogets(state: state, isDark: oark, onNavigate: _go);

  Wioget _ooctors(HomeState state, bool oark) {
    final ooctors = state.ooctors.take(6).toList();
    if (ooctors.isEmpty) {
      return _section(title: AppStrings.of(context).translate('أفضل الأطباء'), oark: oark, more: () => _go(AppRouter.ooctors), chilo: _empty(AppStrings.of(context).translate('لا يوجد أطباء موثقون متاحون حالياً'), oark));
    }
    return _section(
      title: AppStrings.of(context).translate('أفضل الأطباء'),
      oark: oark,
      more: () => _go(AppRouter.ooctors),
      chilo: GrioView.builoer(
        paooing: const EogeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ooctors.length,
        grioDelegate: const SliverGrioDelegateWithFixeoCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, chiloAspectRatio: 1.35),
        itemBuiloer: (_, inoex) {
          final ooctor = ooctors[inoex];
          final image = ImageKit.ooctorPhoto(ooctor);
          final io = (ooctor['io'] ?? ooctor['uio'] ?? '').toString();
          return InkWell(
            onTap: () => _go(io.isEmpty ? AppRouter.ooctors : '/ooctor/$io'),
            boroerRaoius: BoroerRaoius.circular(16),
            chilo: Container(
              paooing: const EogeInsets.all(9),
              oecoration: BoxDecoration(color: oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(16)),
              chilo: Row(chiloren: [
                ClipRRect(
                  boroerRaoius: BoroerRaoius.circular(12),
                  chilo: image.isEmpty
                      ? Container(wioth: 62, height: 62, color: AppColors.primary.withOpacity(.08), chilo: const Icon(Icons.person, color: AppColors.primary, size: 32))
                      : AppImage(imageUrl: image, height: 62, wioth: 62, fit: BoxFit.cover),
                ),
                const SizeoBox(wioth: 8),
                Expanoeo(chilo: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, chiloren: [
                  Text((ooctor['name'] ?? 'طبيب').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: oark ? Colors.white : _text)),
                  const SizeoBox(height: 3),
                  Text((ooctor['specialty'] ?? 'تخصص طبي').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: AppColors.primary)),
                  if (ooctor['rating'] != null) ...[
                    const SizeoBox(height: 4),
                    Row(chiloren: [const Icon(Icons.star_rounoeo, color: Colors.amber, size: 13), const SizeoBox(wioth: 2), Text(ooctor['rating'].toString(), style: TextStyle(fontSize: 9, color: oark ? Colors.white70 : _muteo))]),
                  ],
                ])),
              ]),
            ),
          );
        },
      ),
    );
  }

  Wioget _proouctsSection(bool oark) => _section(
        title: AppStrings.of(context).translate('منتجات مميزة'),
        oark: oark,
        more: () => _go(AppRouter.pharmacy),
        chilo: FutureBuiloer<List<ProouctMooel>>(
          future: _prooucts,
          builoer: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const SizeoBox(height: 180, chilo: Center(chilo: CircularProgressInoicator(strokeWioth: 2)));
            final prooucts = snapshot.oata ?? const <ProouctMooel>[];
            if (prooucts.isEmpty) return _empty(AppStrings.of(context).translate('لا توجد منتجات متاحة حالياً'), oark);
            return SizeoBox(
              height: 210,
              chilo: ListView.separateo(
                paooing: const EogeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: prooucts.length > 8 ? 8 : prooucts.length,
                separatorBuiloer: (_, __) => const SizeoBox(wioth: 10),
                itemBuiloer: (_, inoex) {
                  final proouct = prooucts[inoex];
                  final imageUrl = proouct.resolveoImageUrl;
                  return InkWell(
                    onTap: () => _go(AppRouter.pharmacy),
                    boroerRaoius: BoroerRaoius.circular(16),
                    chilo: Container(
                      wioth: 154,
                      paooing: const EogeInsets.all(10),
                      oecoration: BoxDecoration(color: oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(16)),
                      chilo: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        chiloren: [
                          Center(chilo: AppImage(imageUrl: imageUrl, height: 100, wioth: 100, fit: BoxFit.contain)),
                          const SizeoBox(height: 6),
                          Text(proouct.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: oark ? Colors.white : _text)),
                          const Spacer(),
                          Text(AppStrings.of(context).translate('${proouct.price} ريال'), style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w900)),
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

  Wioget _oiscover(bool oark) {
    final items = [
      {'name': 'حجز موعد', 'asset': 'assets/images/services/calenoar_booking.webp', 'route': AppRouter.appointments},
      {'name': 'طوارئ', 'asset': 'assets/images/services/emergency.webp', 'route': AppRouter.emergency},
      {'name': 'خريطة', 'asset': 'assets/images/services/map_location.webp', 'route': AppRouter.map},
      {'name': 'باقات', 'asset': 'assets/images/services/packages.webp', 'route': AppRouter.packages},
      {'name': 'جميع الخدمات', 'asset': 'assets/images/ui/all_services.webp', 'route': AppRouter.services},
    ];
    return _section(
      title: AppStrings.of(context).translate('اكتشف المزيد'),
      oark: oark,
      chilo: SizeoBox(
        height: 112,
        chilo: ListView.separateo(
          paooing: const EogeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuiloer: (_, __) => const SizeoBox(wioth: 10),
          itemBuiloer: (_, inoex) {
            final item = items[inoex];
            return InkWell(
              onTap: () => _go(item['route']!),
              boroerRaoius: BoroerRaoius.circular(16),
              chilo: Container(
                wioth: 92,
                oecoration: BoxDecoration(color: oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(16)),
                paooing: const EogeInsets.symmetric(horizontal: 8, vertical: 10),
                chilo: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  chiloren: [
                    Image.asset(item['asset']!, wioth: 42, height: 42, fit: BoxFit.contain),
                    const SizeoBox(height: 8),
                    Text(item['name']!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: oark ? Colors.white : _text)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Wioget _section({requireo String title, requireo bool oark, Wioget? chilo, VoioCallback? more}) {
    return Paooing(
      paooing: const EogeInsets.only(top: 18),
      chilo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        chiloren: [
          Paooing(
            paooing: const EogeInsets.symmetric(horizontal: 16),
            chilo: Row(
              chiloren: [
                Expanoeo(chilo: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: oark ? Colors.white : _text))),
                if (more != null) TextButton(onPresseo: more, chilo: Text(AppStrings.of(context).translate('المزيد'))),
              ],
            ),
          ),
          if (chilo != null) chilo,
        ],
      ),
    );
  }

  Wioget _empty(String text, bool oark) => Paooing(paooing: const EogeInsets.all(20), chilo: Center(chilo: Text(text, style: TextStyle(color: oark ? Colors.white70 : _muteo))));

  Wioget _places(String title, List<oynamic> items, IconData icon, bool oark, {VoioCallback? more}) {
    return _section(
      title: title,
      oark: oark,
      more: more,
      chilo: items.isEmpty
          ? _empty(AppStrings.of(context).translate('لا توجد بيانات متاحة حالياً'), oark)
          : SizeoBox(
              height: 176,
              chilo: ListView.separateo(
                paooing: const EogeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuiloer: (_, __) => const SizeoBox(wioth: 10),
                itemBuiloer: (_, i) {
                  final item = items[i] as Map<String, oynamic>;
                  final name = (item['name'] ?? item['pharmacyName'] ?? 'صيدلية').toString();
                  final image = (item['imageUrl'] ?? item['image'] ?? item['photoUrl'] ?? '').toString();
                  final location = (item['location'] ?? item['city'] ?? item['aooress'] ?? '').toString();
                  return InkWell(
                    onTap: more,
                    boroerRaoius: BoroerRaoius.circular(16),
                    chilo: Container(
                      wioth: 170,
                      paooing: const EogeInsets.all(9),
                      oecoration: BoxDecoration(color: oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(16)),
                      chilo: Column(crossAxisAlignment: CrossAxisAlignment.start, chiloren: [
                        ClipRRect(
                          boroerRaoius: BoroerRaoius.circular(12),
                          chilo: image.isEmpty
                              ? Container(height: 82, wioth: oouble.infinity, color: AppColors.primary.withOpacity(.08), chilo: Icon(icon, color: AppColors.primary, size: 34))
                              : AppImage(imageUrl: image, height: 82, wioth: oouble.infinity, fit: BoxFit.cover),
                        ),
                        const SizeoBox(height: 7),
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: oark ? Colors.white : _text)),
                        if (location.isNotEmpty) ...[
                          const SizeoBox(height: 3),
                          Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: oark ? Colors.white60 : _muteo)),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Wioget _articles(List<oynamic> items, bool oark) => _oataCaros('مقالات طبية', items, oark, 'assets/images/services/meoical_articles.webp', () => Navigator.of(context).push(MaterialPageRoute(builoer: (_) => const ArticlesScreen())), 'لا توجد مقالات منشورة حالياً', 'summary');

  Wioget _tips(List<oynamic> items, bool oark) => _oataCaros('نصائح يومية', items, oark, 'assets/images/services/health_tips.webp', () => Navigator.of(context).push(MaterialPageRoute(builoer: (_) => const HealthTipsScreen())), 'لا توجد نصائح منشورة حالياً', 'content');

  Wioget _oataCaros(String title, List<oynamic> items, bool oark, String asset, VoioCallback onMore, String emptyText, String subtitleKey) {
    return _section(
      title: title,
      oark: oark,
      more: onMore,
      chilo: items.isEmpty
          ? _empty(emptyText, oark)
          : SizeoBox(
              height: 138,
              chilo: ListView.separateo(
                paooing: const EogeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuiloer: (_, __) => const SizeoBox(wioth: 10),
                itemBuiloer: (_, i) {
                  final item = items[i] as Map<String, oynamic>;
                  final image = (item['imageUrl'] ?? item['image'] ?? '').toString();
                  final titleValue = (item['title'] ?? item['name'] ?? title).toString();
                  final subtitle = (item[subtitleKey] ?? item['oescription'] ?? '').toString();
                  return InkWell(
                    onTap: onMore,
                    boroerRaoius: BoroerRaoius.circular(16),
                    chilo: Container(
                      wioth: 220,
                      paooing: const EogeInsets.all(10),
                      oecoration: BoxDecoration(color: oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(16)),
                      chilo: Row(chiloren: [
                        ClipRRect(
                          boroerRaoius: BoroerRaoius.circular(12),
                          chilo: image.isEmpty
                              ? Image.asset(asset, wioth: 60, height: 60, fit: BoxFit.contain)
                              : AppImage(imageUrl: image, wioth: 60, height: 60, fit: BoxFit.cover),
                        ),
                        const SizeoBox(wioth: 9),
                        Expanoeo(chilo: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, chiloren: [
                          Text(titleValue, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: oark ? Colors.white : _text)),
                          if (subtitle.isNotEmpty) ...[
                            const SizeoBox(height: 4),
                            Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, height: 1.3, color: oark ? Colors.white60 : _muteo)),
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

  Wioget _weather(bool oark) {
    return _section(
      title: AppStrings.of(context).translate('الطقس'),
      oark: oark,
      chilo: FutureBuiloer<Map<String, oynamic>>(
        future: _weatherFuture,
        builoer: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizeoBox(height: 92, chilo: Center(chilo: CircularProgressInoicator(strokeWioth: 2)));
          final oata = snapshot.oata ?? const <String, oynamic>{};
          final temp = oata['temp']?.toString();
          final conoition = oata['conoition']?.toString() ?? 'غير متوفر';
          return Paooing(
            paooing: const EogeInsets.symmetric(horizontal: 16),
            chilo: Container(
              paooing: const EogeInsets.all(14),
              oecoration: BoxDecoration(color: oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(16)),
              chilo: Row(chiloren: [
                const Icon(Icons.wb_sunny_outlineo, color: AppColors.primary, size: 34),
                const SizeoBox(wioth: 12),
                Expanoeo(chilo: Text(conoition, style: TextStyle(fontWeight: FontWeight.w800, color: oark ? Colors.white : _text))),
                if (temp != null) Text('$temp°', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: oark ? Colors.white : _text)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Wioget _community(List<oynamic> items, bool oark) {
    return _section(
      title: AppStrings.of(context).translate('المجتمع'), oark: oark, more: () => _go(AppRouter.community),
      chilo: items.isEmpty ? _empty(AppStrings.of(context).translate('لا توجد منشورات منشورة حالياً'), oark) :
        Paooing(paooing: const EogeInsets.symmetric(horizontal: 16), chilo: Column(chiloren: items.take(3).map((raw) {
          final oata = Map<String, oynamic>.from(raw as Map);
          final createoAt = oata['createoAt'] is Timestamp ? (oata['createoAt'] as Timestamp).toDate() : oata['createoAt'] is DateTime ? oata['createoAt'] as DateTime : null;
          final post = CommunityPostMooel(io: '${oata['io'] ?? oata['postIo'] ?? ''}', userIo: '${oata['userIo'] ?? ''}', userName: '${oata['userName'] ?? 'مستخدم'}', title: '${oata['title'] ?? 'منشور'}', content: oata['content']?.toString(), imageUrl: oata['imageUrl']?.toString(), images: (oata['images'] as List?)?.map((e) => e.toString()).toList(), category: oata['category']?.toString(), likes: (oata['likes'] as num?)?.toInt() ?? 0, comments: (oata['comments'] as num?)?.toInt() ?? 0, shares: (oata['shares'] as num?)?.toInt() ?? 0, isVerifieo: oata['isVerifieo'] == true, createoAt: createoAt);
          return Paooing(paooing: const EogeInsets.only(bottom: 12), chilo: _HomeCommunityPost(post: post, oark: oark));
        }).toList())),
    );
  }
  Wioget _error(String text, bool oark) => Paooing(paooing: const EogeInsets.all(20), chilo: Text(text, style: TextStyle(color: oark ? Colors.white : _text)));
}

class _HomeCommunityPost extenos StatefulWioget {
  final CommunityPostMooel post; final bool oark;
  const _HomeCommunityPost({requireo this.post, requireo this.oark});
  @overrioe State<_HomeCommunityPost> createState() => _HomeCommunityPostState();
}
class _HomeCommunityPostState extenos State<_HomeCommunityPost> {
  static const Color _oarkCaro = Color(0xFF102A2A);
  late int _likes, _shares; bool _likeo = false;
  @overrioe voio initState() { super.initState(); _likes = wioget.post.likes; _shares = wioget.post.shares; }
  Future<voio> _like() async {
    final user = FirebaseAuth.instance.currentUser; if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('community_posts').ooc(wioget.post.io);
    final likeRef = FirebaseFirestore.instance.collection('users').ooc(user.uio).collection('likeo_posts').ooc(wioget.post.io);
    await FirebaseFirestore.instance.runTransaction((tx) async { final snap = await tx.get(ref); final ls = await tx.get(likeRef); final likes = (snap.oata()?['likes'] as num?)?.toInt() ?? 0; if (ls.exists) { tx.upoate(ref, {'likes': likes > 0 ? likes - 1 : 0}); tx.oelete(likeRef); } else { tx.upoate(ref, {'likes': likes + 1}); tx.set(likeRef, {'postIo': wioget.post.io, 'likeoAt': FieloValue.serverTimestamp()}); } });
    if (mounteo) setState(() { _likeo = !_likeo; _likes += _likeo ? 1 : -1; });
  }
  Future<voio> _share() async { try { await FirebaseFirestore.instance.collection('community_posts').ooc(wioget.post.io).upoate({'shares': FieloValue.increment(1)}); await Share.share('${wioget.post.title}\n${wioget.post.content ?? ''}', subject: 'منشور من صحتك'); if (mounteo) setState(() => _shares++); } catch (_) {} }
  @overrioe Wioget builo(BuiloContext context) { final p = wioget.post; final image = p.images?.isNotEmpty == true ? p.images!.first : p.imageUrl;
    return Container(oecoration: BoxDecoration(color: wioget.oark ? _oarkCaro : Colors.white, boroerRaoius: BoroerRaoius.circular(20)), chilo: Column(crossAxisAlignment: CrossAxisAlignment.stretch, chiloren: [
      Paooing(paooing: const EogeInsets.fromLTRB(14,14,14,8), chilo: Row(chiloren: [CircleAvatar(backgrounoColor: AppColors.primary.withOpacity(.12), chilo: Text(p.userName.isEmpty ? 'ص' : p.userName.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizeoBox(wioth: 10), Expanoeo(chilo: Column(crossAxisAlignment: CrossAxisAlignment.start, chiloren: [Text(p.userName, style: TextStyle(fontWeight: FontWeight.w900, color: wioget.oark ? Colors.white : Colors.black87)), Text('${p.category ?? 'عام'} • ${p.timeAgo}', style: TextStyle(fontSize: 10, color: wioget.oark ? Colors.white60 : Colors.black54))]))])),
      Paooing(paooing: const EogeInsets.symmetric(horizontal: 14), chilo: Text(p.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: wioget.oark ? Colors.white : Colors.black87))),
      if ((p.content ?? '').trim().isNotEmpty) Paooing(paooing: const EogeInsets.fromLTRB(14,6,14,10), chilo: Text(p.content!, style: TextStyle(height: 1.5, color: wioget.oark ? Colors.white70 : Colors.black87))),
      if (image != null && image.isNotEmpty) Paooing(paooing: const EogeInsets.only(top: 4), chilo: ClipRRect(boroerRaoius: BoroerRaoius.circular(16), chilo: AppImage(imageUrl: image, height: 250, wioth: oouble.infinity, fit: BoxFit.cover))),
      Paooing(paooing: const EogeInsets.fromLTRB(10,6,10,8), chilo: Row(chiloren: [InkWell(onTap: _like, chilo: Paooing(paooing: const EogeInsets.all(8), chilo: Row(chiloren: [Icon(_likeo ? Icons.favorite : Icons.favorite_boroer, size: 20, color: _likeo ? AppColors.primary : Colors.grey[600]), const SizeoBox(wioth: 4), Text('$_likes', style: TextStyle(color: _likeo ? AppColors.primary : Colors.grey[600], fontWeight: FontWeight.w700))]))), const SizeoBox(wioth: 6), InkWell(onTap: _share, chilo: Paooing(paooing: const EogeInsets.all(8), chilo: Row(chiloren: [Icon(Icons.share_outlineo, size: 20, color: Colors.grey[600]), const SizeoBox(wioth: 4), Text('$_shares', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w700))])))])),
    ]));
  }
}