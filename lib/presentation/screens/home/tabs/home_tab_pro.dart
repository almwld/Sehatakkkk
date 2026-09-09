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
  @override State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab> {
  @override bool get wantKeepAlive => true;
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.read<HomeBloc>().add(HomeStarted()); }); }
  Future<void> _refresh() async { context.read<HomeBloc>().add(HomeDataRefreshed()); await Future<void>.delayed(const Duration(milliseconds: 300)); }
  void _go(String route) { if (route.isNotEmpty) context.push(route); }

  @override Widget build(BuildContext context) {
    super.build(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, s) => RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _header(s), _banner(s), _stats(s, dark), _quick(dark), _doctors(s, dark),
            FeaturedFacilitiesGrid(title: 'مستشفيات مميزة', items: s.hospitals, isHospital: true, isDark: dark),
            FeaturedFacilitiesGrid(title: 'مختبرات مميزة', items: s.labs, isHospital: false, isDark: dark),
            _places('الصيدليات', s.pharmacies, dark), _tips(s.tips, dark),
            if (s.hasError) Padding(padding: const EdgeInsets.all(16), child: Text(s.errorMessage ?? 'حدث خطأ', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error))),
          ],
        ),
      ),
    );
  }

  Widget _header(HomeState s) => Container(
    padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 10, 18, 18),
    decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
    child: Column(children: [
      Row(children: [
        CircleAvatar(backgroundColor: Colors.white24, child: Text(s.userName.isEmpty ? 'ص' : s.userName.characters.first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10), Expanded(child: Text(s.userName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))),
        IconButton(onPressed: () => _go(AppRouter.notifications), icon: const Icon(Icons.notifications_none, color: Colors.white)),
        IconButton(onPressed: () => _go(AppRouter.cart), icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white)),
      ]),
      const SizedBox(height: 12),
      InkWell(onTap: () => _go(AppRouter.search), child: Container(height: 50, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.search, color: AppColors.primary), SizedBox(width: 8), Text('ابحث عن طبيب، دواء أو خدمة...', style: TextStyle(color: Colors.grey))]))),
    ]),
  );

  Widget _banner(HomeState s) {
    final images = s.bannerImages.isEmpty ? ImageKit.bannerList : s.bannerImages;
    return Padding(padding: const EdgeInsets.all(14), child: SizedBox(height: 175, child: PageView.builder(itemCount: images.length, itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(18), child: AppImage(imageUrl: images[i], fit: BoxFit.cover)))));
  }

  Widget _stats(HomeState s, bool dark) => _section('مؤشراتك اليوم', dark, Row(children: [
    _metric('السعرات', s.calories, 'kcal', dark), _metric('الخطوات', s.steps, 'خطوة', dark), _metric('النوم', s.sleep, 'ساعة', dark), _metric('النبض', s.heartRate, 'bpm', dark),
  ]));

  Widget _metric(String t, double v, String u, bool dark) => Expanded(child: Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [const Icon(Icons.favorite_outline, color: AppColors.primary, size: 22), Text(t, style: const TextStyle(fontSize: 9, color: Colors.grey)), Text('${v.toStringAsFixed(v % 1 == 0 ? 0 : 1)} $u', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))])));

  Widget _quick(bool dark) {
    const d = [('الصيدلية', AppRouter.pharmacy, Icons.local_pharmacy_outlined), ('الأطباء', AppRouter.doctors, Icons.medical_services_outlined), ('المختبرات', AppRouter.labs, Icons.science_outlined), ('الطوارئ', AppRouter.emergency, Icons.emergency_outlined), ('صحتي', AppRouter.dashboard, Icons.health_and_safety_outlined), ('المحفظة', AppRouter.wallet, Icons.account_balance_wallet_outlined)];
    return _section('الخدمات السريعة', dark, SizedBox(height: 90, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: d.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => InkWell(onTap: () => _go(d[i].$2), child: SizedBox(width: 68, child: Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(d[i].$3, color: AppColors.primary)), Text(d[i].$1, style: TextStyle(fontSize: 9, color: dark ? Colors.white : Colors.black87))]))))));
  }

  Widget _doctors(HomeState s, bool dark) {
    final d = s.doctors.take(6).toList();
    if (d.isEmpty) return _section('أفضل الأطباء', dark, _empty('لا توجد بيانات أطباء حالياً', dark));
    return _section('أفضل الأطباء', dark, SizedBox(height: 180, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: d.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => Container(width: 145, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [Expanded(child: AppImage(imageUrl: '${d[i]['photoUrl'] ?? d[i]['image'] ?? ImageKit.doctor1}', fit: BoxFit.cover, width: double.infinity, borderRadius: BorderRadius.circular(10))), Text('${d[i]['name'] ?? 'طبيب'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${d[i]['specialty'] ?? 'تخصص طبي'}', style: const TextStyle(fontSize: 9, color: AppColors.primary))])))));
  }

  Widget _places(String title, List<Map<String, dynamic>> data, bool dark) => _section(title, dark, data.isEmpty ? _empty('لا توجد بيانات متاحة حالياً', dark) : SizedBox(height: 130, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: data.take(6).length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => Container(width: 175, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: AppImage(imageUrl: '${data[i]['imageUrl'] ?? data[i]['image'] ?? ImageKit.hospital1}', fit: BoxFit.cover, width: double.infinity, borderRadius: BorderRadius.circular(10))), Text('${data[i]['name'] ?? 'منشأة صحية'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${data[i]['location'] ?? data[i]['address'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.grey))])))));

  Widget _tips(List<Map<String, dynamic>> data, bool dark) {
    if (data.isEmpty) return _section('نصائح صحية', dark, _empty('لا توجد نصائح منشورة حالياً', dark));
    final x = data.take(4).toList();
    return _section('نصائح صحية', dark, GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: x.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5), itemBuilder: (_, i) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary), Text('${x[i]['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)), Text('${x[i]['description'] ?? x[i]['content'] ?? ''}', maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.grey))])))));
  }

  Widget _section(String title, bool dark, Widget child) => Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131)))), child]));
  Widget _empty(String text, bool dark) => Container(height: 90, width: double.infinity, alignment: Alignment.center, decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(text, style: const TextStyle(color: Colors.grey)));
}
