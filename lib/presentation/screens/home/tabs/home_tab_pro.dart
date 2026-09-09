import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
import 'package:sehatak/core/services/pharmacy_service.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_products.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/home/featured_facilities_grid.dart';

class HomeTab extends StatefulWidget {
  final ScrollController scrollController;
  const HomeTab({super.key, required this.scrollController});
  @override State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab> {
  late final PageController _bannerController;
  final PharmacyService _pharmacy = PharmacyService();
  List<ProductModel> _products = const [];
  int _banner = 0;
  @override bool get wantKeepAlive => true;

  @override void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: .92);
    WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; context.read<HomeBloc>().add(HomeStarted()); _loadProducts(); });
  }
  Future<void> _loadProducts() async { final p = await _pharmacy.getAllProducts(); if (mounted) setState(() => _products = p.take(12).toList(growable: false)); }
  Future<void> _refresh() async { context.read<HomeBloc>().add(HomeDataRefreshed()); await _loadProducts(); }
  void _go(String route) { if (route.isNotEmpty) context.push(route); }
  @override void dispose() { _bannerController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    super.build(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<HomeBloc, HomeState>(builder: (_, s) => RefreshIndicator(
      onRefresh: _refresh, color: AppColors.primary,
      child: ListView(controller: widget.scrollController, physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.only(bottom: 112), children: [
        _header(s), _banners(s), _vitals(s, dark), _services(dark), _doctors(s, dark),
        HomeProductsRow(products: _products, onViewAll: () => _go(AppRouter.pharmacy)),
        FeaturedFacilitiesGrid(title: 'المستشفيات المميزة', items: s.hospitals, isHospital: true, isDark: dark),
        FeaturedFacilitiesGrid(title: 'المختبرات المميزة', items: s.labs, isHospital: false, isDark: dark),
        _places('الصيدليات المميزة', s.pharmacies, dark), _articles(s.articles, dark), _tips(s.tips, dark), _discover(dark), _community(s.communityPosts, dark),
        if (s.hasError) _error(s.errorMessage),
      ]),
    ));
  }

  Widget _header(HomeState s) {
    final top = MediaQuery.of(context).padding.top;
    final name = s.userName.trim().isEmpty ? 'مرحباً بك في صحتك' : s.userName.trim();
    return ClipPath(clipper: _Curve(), child: Container(padding: EdgeInsets.fromLTRB(16, top + 12, 16, 30), decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(.82)], begin: Alignment.topRight, end: Alignment.bottomLeft),
    ), child: Column(children: [
      Row(children: [
        GestureDetector(onTap: () => _go(AppRouter.profile), child: CircleAvatar(radius: 22, backgroundColor: Colors.white.withOpacity(.2), child: Image.asset('assets/images/ui/user_profile.png', width: 25, height: 25, color: Colors.white, errorBuilder: (_, __, ___) => Text(name.characters.first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
        const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_greeting(), style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 2), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))])),
        _topIcon('assets/images/icons/top_bar/notifications.png', () => _go(AppRouter.notifications), s.notificationCount), const SizedBox(width: 12),
        GestureDetector(onTap: () => _go(AppRouter.cart), child: Image.asset('assets/images/services/pharmacy.png', width: 27, height: 27, color: Colors.white)),
      ]),
      const SizedBox(height: 15),
      GestureDetector(onTap: () => _go(AppRouter.search), child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(.28))), child: Row(children: [
        Image.asset('assets/images/services/medical_articles.png', width: 21, height: 21, color: Colors.white70), const SizedBox(width: 9), const Expanded(child: Text('ابحث عن طبيب، دواء، أو خدمة...', style: TextStyle(color: Colors.white70, fontSize: 13))), Image.asset('assets/images/chat/microphone.png', width: 20, height: 20, color: Colors.white70),
      ]))),
    ])));
  }

  Widget _topIcon(String asset, VoidCallback tap, int badge) => GestureDetector(onTap: tap, child: Stack(clipBehavior: Clip.none, children: [Image.asset(asset, width: 27, height: 27, color: Colors.white), if (badge > 0) Positioned(right: -7, top: -7, child: Container(constraints: const BoxConstraints(minWidth: 17, minHeight: 17), alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text(badge > 99 ? '99+' : '$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))))]));
  String _greeting() { final h = DateTime.now().hour; if (h < 12) return 'صباح الخير ☀️'; if (h < 17) return 'مساء الخير 🌤️'; return 'مساء الخير 🌙'; }

  Widget _banners(HomeState s) {
    final images = s.bannerImages.isEmpty ? ImageKit.bannerList : s.bannerImages;
    if (images.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.fromLTRB(12, 16, 12, 8), child: Column(children: [SizedBox(height: 180, child: PageView.builder(controller: _bannerController, itemCount: images.length, onPageChanged: (i) => setState(() => _banner = i), itemBuilder: (_, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: ClipRRect(borderRadius: BorderRadius.circular(17), child: AppImage(imageUrl: images[i], fit: BoxFit.cover, width: double.infinity))))), if (images.length > 1) Padding(padding: const EdgeInsets.only(top: 7), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: images.asMap().entries.map((e) => AnimatedContainer(duration: const Duration(milliseconds: 250), width: e.key == _banner ? 20 : 7, height: 6, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(color: e.key == _banner ? AppColors.primary : AppColors.primary.withOpacity(.25), borderRadius: BorderRadius.circular(5)))).toList()))]));
  }

  Widget _vitals(HomeState s, bool dark) {
    final p = (s.steps / 10000).clamp(0.0, 1.0);
    final v = [
      ['ضغط الدم','—','مم زئبق','assets/images/tracking/blood_pressure.png',0.0], ['سكر الدم','—','مجم/دل','assets/images/tracking/blood_sugar.png',0.0],
      ['اللياقة',s.steps > 0 ? '${(p * 100).round()}' : '—','%','assets/images/tracking/fitness.png',p], ['الوزن','—','كجم','assets/images/tracking/weight_tracking.png',0.0],
      ['التغذية','—','','assets/images/tracking/nutrition.png',0.0], ['الصحة النفسية','—','','assets/images/tracking/mental_health.png',0.0],
    ];
    return _section('المؤشرات الحيوية', dark, Column(children: [Container(padding: const EdgeInsets.all(13), decoration: _card(dark), child: Row(children: [SizedBox(width: 62, height: 62, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: p, strokeWidth: 6, backgroundColor: AppColors.primary.withOpacity(.12), color: AppColors.primary), Text('${(p * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))])), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('صف الإحصائيات السريعة', style: TextStyle(fontSize: 11, color: dark ? Colors.white70 : Colors.black54)), Text('${s.steps.toStringAsFixed(0)} / 10,000 خطوة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF173131))), Text('السعرات ${s.calories > 0 ? s.calories.toStringAsFixed(0) : '—'} • النوم ${s.sleep > 0 ? s.sleep.toStringAsFixed(1) : '—'} • النبض ${s.heartRate > 0 ? s.heartRate.toStringAsFixed(0) : '—'}', style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)]))])), const SizedBox(height: 9), GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: v.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .9), itemBuilder: (_, i) => GestureDetector(onTap: () => _go(AppRouter.dashboard), child: Container(padding: const EdgeInsets.all(7), decoration: _card(dark), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 55, height: 55, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: v[i][4] as double, strokeWidth: 5, backgroundColor: AppColors.primary.withOpacity(.1), color: AppColors.primary), Image.asset(v[i][3] as String, width: 19, height: 19, color: AppColors.primary, errorBuilder: (_, __, ___) => const SizedBox.shrink())])), const SizedBox(height: 5), Text('${v[i][1]} ${v[i][2]}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87)), Text(v[i][0] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.grey))]))))]));
  }

  Widget _services(bool dark) {
    const x = [
      ['صيدلية','assets/images/services/pharmacy.png',AppRouter.pharmacy], ['طوارئ','assets/images/services/emergency.png',AppRouter.emergency], ['خدمات منزلية','assets/images/services/medical_community.png',AppRouter.services], ['تبرع بالدم','assets/images/services/blood_donation.png',AppRouter.bloodDonation], ['أطباء','assets/images/services/consultation.png',AppRouter.doctors], ['مختبرات','assets/images/services/laboratory.png',AppRouter.labs], ['صحة','assets/images/services/health_tips.png',AppRouter.dashboard], ['محفظة','assets/images/services/wallet.png',AppRouter.wallet], ['استشارة','assets/images/services/consultation.png',AppRouter.consultation], ['بالقرب منك','assets/images/services/map_location.png',AppRouter.map],
    ];
    return _section('الخدمات السريعة', dark, SizedBox(height: 86, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: x.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => GestureDetector(onTap: () => _go(x[i][2]), child: SizedBox(width: 68, child: Column(children: [SizedBox(width: 46, height: 46, child: Image.asset(x[i][1], fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink())), const SizedBox(height: 4), Text(x[i][0], maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))]))))));
  }

  Widget _doctors(HomeState s, bool dark) {
    final d = s.doctors.take(6).toList();
    return _section('أفضل الأطباء', dark, d.isEmpty ? _empty('لا توجد بيانات أطباء حالياً', dark) : GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: d.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: .82), itemBuilder: (_, i) { final z=d[i]; final id='${z['id']??''}'; return GestureDetector(onTap: id.isEmpty?null:()=>_go('/doctor/$id'), child: Container(padding: const EdgeInsets.all(8), decoration: _card(dark), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: AppImage(imageUrl: '${z['photoUrl']??z['image']??''}', width: double.infinity, fit: BoxFit.cover, borderRadius: BorderRadius.circular(11))), const SizedBox(height: 6), Text('${z['name']??'طبيب'}', maxLines:1, overflow:TextOverflow.ellipsis, style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:dark?Colors.white:Colors.black87)), Text('${z['specialty']??'تخصص طبي'}',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,color:AppColors.primary)), const SizedBox(height:5), SizedBox(width:double.infinity,height:27,child:ElevatedButton(onPressed:id.isEmpty?null:()=>_go('/doctor/$id'),style:ElevatedButton.styleFrom(padding:EdgeInsets.zero,elevation:0,backgroundColor:AppColors.primary.withOpacity(.1),foregroundColor:AppColors.primary),child:const Text('حجز موعد',style:TextStyle(fontSize:10,fontWeight:FontWeight.w700))))]))); }));
  }

  Widget _places(String title, List<Map<String,dynamic>> a, bool dark) => _section(title,dark,a.isEmpty?_empty('لا توجد بيانات حالياً',dark):GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:a.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:1.05),itemBuilder:(_,i){final x=a[i];return Container(padding:const EdgeInsets.all(8),decoration:_card(dark),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:AppImage(imageUrl:'${x['image']??x['photoUrl']??''}',width:double.infinity,fit:BoxFit.cover,borderRadius:BorderRadius.circular(10))),const SizedBox(height:6),Text('${x['name']??'مرفق صحي'}',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.w800,fontSize:12,color:dark?Colors.white:Colors.black87)),Text('${x['location']??'الموقع غير متوفر'}',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,color:Colors.grey))]);}));

  Widget _articles(List<Map<String,dynamic>> a,bool dark)=>_section('أحدث المقالات',dark,a.isEmpty?_empty('لا توجد مقالات حالياً',dark):GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:a.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:.95),itemBuilder:(_,i){final x=a[i];return GestureDetector(onTap:()=>_go('/article/${x['id']??''}'),child:Container(padding:const EdgeInsets.all(7),decoration:_card(dark),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:AppImage(imageUrl:'${x['image']??x['imageUrl']??''}',width:double.infinity,fit:BoxFit.cover,borderRadius:BorderRadius.circular(10))),const SizedBox(height:5),Text('${x['category']??'صحة'}',style:const TextStyle(fontSize:9,color:AppColors.primary)),Text('${x['title']??'مقال صحي'}',maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:dark?Colors.white:Colors.black87))]));});

  Widget _tips(List<Map<String,dynamic>> a,bool dark)=>_section('النصائح اليومية',dark,a.isEmpty?_empty('لا توجد نصائح حالياً',dark):GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:a.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:1.15),itemBuilder:(_,i){final x=a[i];return Container(padding:const EdgeInsets.all(10),decoration:_card(dark),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Image.asset('assets/images/services/health_tips.png',width:34,height:34),const SizedBox(height:5),Text('${x['title']??x['name']??'نصيحة صحية'}',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:dark?Colors.white:Colors.black87)),const SizedBox(height:3),Expanded(child:Text('${x['subtitle']??x['content']??x['description']??''}',maxLines:3,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,color:Colors.grey))),TextButton(onPressed:()=>_go(AppRouter.dashboard),style:TextButton.styleFrom(padding:EdgeInsets.zero,minimumSize:const Size(0,24)),child:const Text('اقرأ المزيد',style:TextStyle(fontSize:9))) ]));});

  Widget _discover(bool dark){const x=[['مقالات طبية','assets/images/services/medical_articles.png'],['تأمين صحي','assets/images/services/health_insurance.png'],['استشارة فيديو','assets/images/services/video_consultation.png'],['باقات صحية','assets/images/services/packages.png']];return _section('اكتشف المزيد',dark,GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:4,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:7,childAspectRatio:.82),itemBuilder:(_,i)=>GestureDetector(onTap:()=>_go(i==2?AppRouter.consultation:AppRouter.more),child:Column(children:[Container(width:52,height:52,decoration:BoxDecoration(color:AppColors.primary.withOpacity(.09),borderRadius:BorderRadius.circular(15)),child:Image.asset(x[i][1],width:31,height:31)),const SizedBox(height:5),Text(x[i][0],textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w600))]))));}

  Widget _community(List<Map<String,dynamic>> a,bool dark)=>_section('مجتمع صحتك',dark,a.isEmpty?_empty('لا توجد منشورات حالياً',dark):Column(children:a.take(5).map((x)=>Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(11),decoration:_card(dark),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[CircleAvatar(radius:18,backgroundColor:AppColors.primary.withOpacity(.1),child:Image.asset('assets/images/ui/user_profile.png',width:22,height:22,color:AppColors.primary)),const SizedBox(width:8),Expanded(child:Text('${x['authorName']??'مستخدم'}',style:TextStyle(fontWeight:FontWeight.w800,fontSize:12,color:dark?Colors.white:Colors.black87)))]),const SizedBox(height:7),Text('${x['title']??''}',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.w800,color:dark?Colors.white:Colors.black87)),const SizedBox(height:3),Text('${x['content']??''}',maxLines:3,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,color:Colors.grey)),const SizedBox(height:7),Row(children:[Text('إعجاب ${x['likesCount']??0}',style:const TextStyle(fontSize:9,color:Colors.grey)),const SizedBox(width:14),Text('تعليق ${x['commentsCount']??0}',style:const TextStyle(fontSize:9,color:Colors.grey)),const Spacer(),Text('مشاركة ${x['sharesCount']??0}',style:const TextStyle(fontSize:9,color:Colors.grey))])]))).toList()));

  Widget _section(String title,bool dark,Widget child)=>Padding(padding:const EdgeInsets.fromLTRB(14,8,14,7),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Padding(padding:const EdgeInsets.symmetric(horizontal:2,vertical:5),child:Text(title,style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:dark?Colors.white:const Color(0xFF173131)))),child]));
  BoxDecoration _card(bool dark)=>BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(14),boxShadow:[BoxShadow(color:Colors.black.withOpacity(.05),blurRadius:8,offset:const Offset(0,2))]);
  Widget _empty(String t,bool dark)=>Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:_card(dark),child:Text(t,textAlign:TextAlign.center,style:const TextStyle(fontSize:11,color:Colors.grey)));
  Widget _error(String? t)=>Padding(padding:const EdgeInsets.all(14),child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.error.withOpacity(.08),borderRadius:BorderRadius.circular(12)),child:Text(t??'حدث خطأ أثناء تحميل بعض البيانات',style:const TextStyle(fontSize:11))));
}

class _Curve extends CustomClipper<Path>{@override Path getClip(Size s){final p=Path()..lineTo(0,s.height-25);p.quadraticBezierTo(s.width/2,s.height+18,s.width,s.height-25);p.lineTo(s.width,0);p.close();return p;}@override bool shouldReclip(covariant CustomClipper<Path> oldClipper)=>false;}
