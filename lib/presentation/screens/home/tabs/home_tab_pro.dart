import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _go(String route) {
    if (route.isNotEmpty) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final background = dark ? const Color(0xFF0B1121) : const Color(0xFFF6F9F9);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, s) => RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        backgroundColor: theme.cardColor,
        child: ListView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 112),
          children: [
            _header(s),
            _banner(s),
            _activitySummary(s, dark),
            _quickServices(dark),
            _doctors(s, dark),
            FeaturedFacilitiesGrid(
              title: 'مستشفيات مميزة',
              items: s.hospitals,
              isHospital: true,
              isDark: dark,
            ),
            FeaturedFacilitiesGrid(
              title: 'مختبرات مميزة',
              items: s.labs,
              isHospital: false,
              isDark: dark,
            ),
            _places('الصيدليات القريبة', s.pharmacies, dark),
            _tips(s.tips, dark),
            _articles(s.articles, dark),
            _community(s.communityPosts, dark),
            if (s.hasError)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _errorCard(s.errorMessage, dark),
              ),
            Container(height: 1, color: background),
          ],
        ),
      ),
    );
  }

  Widget _header(HomeState s) {
    final top = MediaQuery.of(context).padding.top;
    final initial = s.userName.trim().isEmpty ? 'ص' : s.userName.characters.first;
    return Container(
      padding: EdgeInsets.fromLTRB(18, top + 12, 18, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً بك 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.userName.trim().isEmpty ? 'في صحتك' : s.userName,
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
              _headerAction(
                icon: Icons.notifications_none_rounded,
                badge: s.notificationCount,
                onTap: () => _go(AppRouter.notifications),
              ),
              const SizedBox(width: 4),
              _headerAction(
                icon: Icons.shopping_cart_outlined,
                onTap: () => _go(AppRouter.cart),
              ),
            ],
          ),
          const SizedBox(height: 15),
          InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => _go(AppRouter.search),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'ابحث عن طبيب، دواء أو خدمة...',
                      style: TextStyle(color: Color(0xFF7B8585), fontSize: 13),
                    ),
                  ),
                  Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 25),
        ),
        if (badge > 0)
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _banner(HomeState s) {
    final images = s.bannerImages.isEmpty ? ImageKit.bannerList : s.bannerImages;
    if (images.isEmpty) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 5),
      child: AspectRatio(
        aspectRatio: 2.0,
        child: PageView.builder(
          itemCount: images.length,
          controller: PageController(viewportFraction: .96),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AppImage(imageUrl: images[i], fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget _activitySummary(HomeState s, bool dark) {
    final values = [
      ('الخطوات', s.steps, 'خطوة', Icons.directions_walk_rounded),
      ('السعرات', s.calories, 'kcal', Icons.local_fire_department_outlined),
      ('النوم', s.sleep, 'ساعة', Icons.bedtime_outlined),
      ('النبض', s.heartRate, 'bpm', Icons.favorite_outline_rounded),
    ];
    return _section(
      'ملخص صحتك اليوم',
      dark,
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(dark),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: s.steps <= 0 ? 0 : (s.steps / 10000).clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor: AppColors.primary.withOpacity(.12),
                        color: AppColors.primary,
                      ),
                      Text(
                        '${((s.steps / 10000).clamp(0.0, 1.0) * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : const Color(0xFF173131),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هدف النشاط',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${s.steps.toStringAsFixed(0)} / 10,000 خطوة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : const Color(0xFF173131),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.steps > 0 ? 'استمر، أنت تتقدم بشكل جيد' : 'ابدأ تسجيل نشاطك اليوم',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final item in values)
                Expanded(
                  child: _metric(
                    item.$1,
                    item.$2,
                    item.$3,
                    item.$4,
                    dark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, double value, String unit, IconData icon, bool dark) {
    final valid = value > 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
      decoration: _cardDecoration(dark),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            valid ? '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} $unit' : '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: dark ? Colors.white : const Color(0xFF173131),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickServices(bool dark) {
    const services = [
      ('الأطباء', AppRouter.doctors, Icons.medical_services_outlined),
      ('الصيدلية', AppRouter.pharmacy, Icons.local_pharmacy_outlined),
      ('المختبرات', AppRouter.labs, Icons.science_outlined),
      ('الطوارئ', AppRouter.emergency, Icons.emergency_outlined),
      ('صحتي', AppRouter.dashboard, Icons.health_and_safety_outlined),
      ('المحفظة', AppRouter.wallet, Icons.account_balance_wallet_outlined),
    ];
    return _section(
      'الخدمات السريعة',
      dark,
      SizedBox(
        height: 94,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(width: 9),
          itemBuilder: (_, i) {
            final service = services[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _go(service.$2),
              child: SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.11),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(service.$3, color: AppColors.primary, size: 25),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dark ? Colors.white : Colors.black87,
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

  Widget _doctors(HomeState s, bool dark) {
    final doctors = s.doctors.take(6).toList();
    return _section(
      'أفضل الأطباء',
      dark,
      doctors.isEmpty
          ? _empty('لا توجد بيانات أطباء حالياً', dark)
          : SizedBox(
              height: 188,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final doctor = doctors[i];
                  final image = '${doctor['photoUrl'] ?? doctor['image'] ?? ImageKit.doctor1}';
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(8),
                    decoration: _cardDecoration(dark),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${doctor['name'] ?? 'طبيب'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: dark ? Colors.white : const Color(0xFF173131),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doctor['specialty'] ?? 'تخصص طبي'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _places(String title, List<Map<String, dynamic>> data, bool dark) {
    final items = data.take(6).toList();
    return _section(
      title,
      dark,
      items.isEmpty
          ? _empty('لا توجد بيانات متاحة حالياً', dark)
          : SizedBox(
              height: 136,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return Container(
                    width: 180,
                    padding: const EdgeInsets.all(8),
                    decoration: _cardDecoration(dark),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppImage(
                            imageUrl: '${item['imageUrl'] ?? item['image'] ?? ImageKit.hospital1}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item['name'] ?? 'منشأة صحية'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: dark ? Colors.white : const Color(0xFF173131),
                          ),
                        ),
                        Text(
                          '${item['location'] ?? item['address'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _tips(List<Map<String, dynamic>> data, bool dark) {
    final items = data.take(4).toList();
    return _section(
      'نصيحتك الصحية اليوم',
      dark,
      items.isEmpty
          ? _empty('لا توجد نصائح منشورة حالياً', dark)
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (_, i) {
                final item = items[i];
                return Container(
                  padding: const EdgeInsets.all(11),
                  decoration: _cardDecoration(dark),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tips_and_updates_outlined,
                          color: AppColors.primary, size: 23),
                      const SizedBox(height: 5),
                      Text(
                        '${item['title'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : const Color(0xFF173131),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item['description'] ?? item['content'] ?? ''}',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _articles(List<Map<String, dynamic>> data, bool dark) {
    final items = data.take(5).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return _section(
      'التثقيف الصحي',
      dark,
      SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final item = items[i];
            return Container(
              width: 215,
              padding: const EdgeInsets.all(9),
              decoration: _cardDecoration(dark),
              child: Row(
                children: [
                  Container(
                    width: 82,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: AppImage(
                      imageUrl: '${item['imageUrl'] ?? item['image'] ?? ''}',
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['title'] ?? 'مقال صحي'}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: dark ? Colors.white : const Color(0xFF173131),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item['description'] ?? item['content'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
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

  Widget _community(List<Map<String, dynamic>> data, bool dark) {
    final items = data.take(3).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return _section(
      'مجتمع صحتك',
      dark,
      Column(
        children: [
          for (final item in items)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(dark),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.primary.withOpacity(.11),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['authorName'] ?? item['userName'] ?? 'عضو في مجتمع صحتك'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: dark ? Colors.white : const Color(0xFF173131),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item['content'] ?? item['text'] ?? item['title'] ?? ''}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, bool dark, Widget child) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 2, left: 2),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: dark ? Colors.white : const Color(0xFF173131),
                ),
              ),
            ),
            child,
          ],
        ),
      );

  BoxDecoration _cardDecoration(bool dark) => BoxDecoration(
        color: dark ? const Color(0xFF102A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(.05) : const Color(0xFFE9EFEF),
        ),
        boxShadow: dark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      );

  Widget _empty(String text, bool dark) => Container(
        height: 88,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: _cardDecoration(dark),
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      );

  Widget _errorCard(String? message, bool dark) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withOpacity(.18)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.error),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                message ?? 'تعذر تحديث بعض البيانات. اسحب للأسفل للمحاولة مرة أخرى.',
                style: TextStyle(
                  fontSize: 11,
                  color: dark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
}
