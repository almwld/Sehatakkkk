import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import '../payment/subscription_payment_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override State<SubscriptionsScreen> createState()=>_SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>{
  bool _annual=false;
  final plans=const [
    ('الباقة المجانية','free',0,0,'الأساسيات الصحية اليومية',['متابعة المؤشرات','الوصول للخدمات الأساسية']),
    ('الباقة الفضية','silver',3000,30000,'رعاية صحية منتظمة',['متابعة صحية محسنة','مزايا إضافية']),
    ('الباقة البرونزية','bronze',3900,39000,'مزايا صحية متقدمة',['مزايا صحية متقدمة','أولوية في بعض الخدمات']),
    ('الباقة الذهبية','gold',4900,35000,'الرعاية الصحية المتكاملة',['مزايا متقدمة','أولوية في الخدمات المتاحة']),
    ('باقة العائلة','family',7500,75000,'حتى 5 أفراد من العائلة',['إدارة أفراد العائلة','مزايا عائلية']),
    ('الباقة الكريستالية','crystal',12000,120000,'تجربة رعاية فائقة',['أعلى مستوى من المزايا','خدمات متميزة']),
  ];

  Future<String?> _activePlan() async {
    final uid=FirebaseAuth.instance.currentUser?.uid;
    if(uid==null)return null;
    final q=await FirebaseFirestore.instance.collection('subscriptions').where('userId',isEqualTo:uid).where('status',whereIn:['active','trial']).limit(1).get();
    return q.docs.isEmpty?null:q.docs.first.data()['planName']?.toString();
  }

  Future<void> _subscribe((String,String,int,int,String,List<String>) p) async {
    final price=_annual?p.$4:p.$3;
    if(price==0){ToastService.showInfo('أنت على الباقة المجانية.');return;}
    final active=await _activePlan();
    if(active!=null){ToastService.showInfo('لديك اشتراك نشط: $active');return;}
    if(!mounted)return;
    final ok=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>SubscriptionPaymentScreen(planName:p.$1,planCode:p.$2,price:price,annual:_annual,features:p.$6)));
    if(ok==true&&mounted)setState((){});
  }

  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(backgroundColor:dark?const Color(0xFF08131A):const Color(0xFFF4F8F7),
      appBar:AppBar(title:const Text('الباقات والاشتراكات'),backgroundColor:dark?const Color(0xFF08131A):Colors.white,foregroundColor:dark?Colors.white:Colors.black87,elevation:0),
      body:ListView(padding:const EdgeInsets.fromLTRB(16,10,16,30),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),borderRadius:BorderRadius.circular(28)),child:Row(children:[
          Container(width:58,height:58,decoration:BoxDecoration(color:Colors.white.withOpacity(.14),shape:BoxShape.circle),child:Image.asset('assets/images/services/packages.webp',width:34,height:34,errorBuilder:(_,__,___)=>const Icon(Icons.workspace_premium_outlined,color:Colors.white,size:32))),
          const SizedBox(width:14),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('خطتك الصحية تبدأ من هنا',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),SizedBox(height:5),Text('اختر الباقة، راجع التفاصيل، وادفع بأمان من محفظة صحتك.',style:TextStyle(color:Colors.white70,height:1.4))]))
        ])),
        const SizedBox(height:18),
        Container(padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:dark?const Color(0xFF16252C):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[
          Expanded(child:_period('شهرياً',!_annual,()=>setState(()=>_annual=false),dark)),
          Expanded(child:_period('سنوياً',_annual,()=>setState(()=>_annual=true),dark)),
        ])),
        const SizedBox(height:16),
        ...plans.map((p)=>_card(p,dark)),
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:dark?const Color(0xFF16252C):Colors.white,borderRadius:BorderRadius.circular(16)),child:const Row(children:[Icon(Icons.verified_user_outlined,color:AppColors.primary),SizedBox(width:10),Expanded(child:Text('الدفع يتم عبر الخادم الموثوق، ويُخصم من رصيد محفظتك فقط بعد التحقق من الرصيد وإنشاء المعاملة والفاتورة.'))]))
      ]));
  }

  Widget _period(String text,bool selected,VoidCallback tap,bool dark)=>GestureDetector(onTap:tap,child:AnimatedContainer(duration:const Duration(milliseconds:180),padding:const EdgeInsets.symmetric(vertical:12),decoration:BoxDecoration(color:selected?AppColors.primary:Colors.transparent,borderRadius:BorderRadius.circular(12)),child:Text(text,textAlign:TextAlign.center,style:TextStyle(color:selected?Colors.white:(dark?Colors.white70:Colors.black54),fontWeight:FontWeight.w800))));
  Widget _card((String, String, int, int, String, List<String>) p, bool dark) {
    final price = _annual ? p.$4 : p.$3;
    final featured = p.$2 == 'gold' || p.$2 == 'family';
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: dark ? const Color(0xFF122027) : Colors.white, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: featured ? AppColors.primary.withOpacity(.45) : Colors.transparent, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(14)),
            child: Image.asset('assets/images/services/packages.webp', width: 30, height: 30, errorBuilder: (_, __, ___) => const Icon(Icons.workspace_premium_outlined, color: AppColors.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(p.$5, style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : Colors.black54)),
          ])),
          if (featured) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: const Text('مميزة', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 14),
        Text(price == 0 ? 'مجاناً' : '${_money(price)} ر.ي', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.primary)),
        if (price > 0) Text(_annual ? 'للسنة كاملة' : 'لكل شهر', style: TextStyle(fontSize: 11, color: dark ? Colors.white54 : Colors.black45)),
        const SizedBox(height: 10),
        ...p.$6.map((f) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 17), const SizedBox(width: 7), Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
        ]))),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _subscribe(p), style: ElevatedButton.styleFrom(backgroundColor: price == 0 ? Colors.grey : AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: Text(price == 0 ? 'الباقة الحالية' : 'مراجعة الدفع'))),
      ]),
    );
  }
  String _money(int n)=>n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'),(_)=>',');
}
