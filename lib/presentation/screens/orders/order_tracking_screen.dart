import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String? deliveryMethod;
  const OrderTrackingScreen({super.key, required this.orderId, this.deliveryMethod});
  String _label(String s) => switch (s) {
    'pending'=>'قيد المعالجة','confirmed'=>'مؤكد','preparing'=>'جاري التحضير','ready'=>'جاهز','delivering'=>'جاري التوصيل','delivered'=>'تم التسليم','cancelled'=>'ملغي',_=>'حالة غير معروفة'};
  int _step(String s) => switch (s) {
    'pending'=>0,'confirmed'=>1,'preparing'=>2,'ready'=>3,'delivering'=>4,'delivered'=>5,'cancelled'=>-1,_=>0};
  @override Widget build(BuildContext context) {
    final uid=FirebaseAuth.instance.currentUser?.uid;
    final dark=Theme.of(context).brightness==Brightness.dark;
    if(uid==null)return const Scaffold(body:Center(child:Text('يجب تسجيل الدخول لمتابعة الطلب')));
    return Scaffold(
      backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF8FAFC),
      appBar:AppBar(title:const Text('تتبع الطلب'),backgroundColor:dark?const Color(0xFF0B1121):Colors.white,foregroundColor:dark?Colors.white:Colors.black87),
      body:StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        stream:FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder:(context,s){
          if(s.hasError)return const Center(child:Text('تعذر تحميل حالة الطلب'));
          if(!s.hasData)return const Center(child:CircularProgressIndicator());
          final data=s.data!.data();
          if(data==null||!s.data!.exists)return const Center(child:Text('الطلب غير موجود'));
          if(data['userId']?.toString()!=uid)return const Center(child:Text('لا تملك صلاحية عرض هذا الطلب'));
          final status=data['status']?.toString()??'pending';
          final current=_step(status);
          final steps=<Map<String,dynamic>>[
            {'title':'تم استلام الطلب','icon':Icons.receipt_long},
            {'title':'تم تأكيد الطلب','icon':Icons.check_circle_outline},
            {'title':'جاري التجهيز','icon':Icons.inventory_2_outlined},
            {'title':'الطلب جاهز','icon':Icons.done_outline},
            {'title':'جاري التوصيل','icon':Icons.local_shipping_outlined},
            {'title':'تم التسليم','icon':Icons.done_all},
          ];
          return ListView(padding:const EdgeInsets.all(16),children:[
            Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[
              const Icon(Icons.receipt_long,color:AppColors.primary,size:32),const SizedBox(width:12),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('طلب #$orderId',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
                const SizedBox(height:4),Text(_label(status),style:const TextStyle(color:AppColors.primary)),
                if(deliveryMethod!=null)Text(deliveryMethod!,style:TextStyle(fontSize:12,color:dark?Colors.grey[400]:Colors.grey[600])),
              ])),
            ])),
            const SizedBox(height:20),
            if(status=='cancelled')_notice('تم إلغاء هذا الطلب.',Colors.red)
            else ...steps.asMap().entries.map((e){
              final done=current>=e.key;
              return ListTile(
                leading:CircleAvatar(radius:20,backgroundColor:done?AppColors.primary:Colors.grey.withOpacity(.15),child:Icon(e.value['icon'] as IconData,color:done?Colors.white:Colors.grey)),
                title:Text(e.value['title'] as String),
                subtitle:current==e.key?const Text('آخر حالة مؤكدة من النظام'):null,
              );
            }),
            const SizedBox(height:12),
            _notice('تظهر هنا حالة الطلب الفعلية من النظام؛ لا توجد أوقات أو مواقع مصطنعة.',dark?Colors.white70:Colors.black54),
          ]);
        },
      ),
    );
  }
  Widget _notice(String t,Color c)=>Container(margin:const EdgeInsets.only(top:8),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:c.withOpacity(.08),borderRadius:BorderRadius.circular(12)),child:Text(t,style:TextStyle(color:c)));
}