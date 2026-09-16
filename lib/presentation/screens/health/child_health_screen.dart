import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChildHealthScreen extends StatelessWidget {
  const ChildHealthScreen({super.key});
  @override Widget build(BuildContext context) {
    final dark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(backgroundColor: dark?const Color(0xFF0B1121):const Color(0xFFF8FAFC), appBar: AppBar(title: const Text('صحة الطفل'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(22)), child: const Row(children: [CircleAvatar(radius: 28, backgroundColor: AppColors.primary, child: Icon(Icons.health_and_safety_outlined,color:Colors.white)), SizedBox(width:14), Expanded(child: Text('متابعة النمو والتطعيمات والمواعيد', style: TextStyle(fontSize:17,fontWeight:FontWeight.w800)))])),
      const SizedBox(height:16),
            _item(context, 'النمو والتطور', Icons.calendar_month_outlined),
            _item(context, 'التطعيمات', Icons.favorite_outline),
            _item(context, 'المواعيد الطبية', Icons.notifications_none),
            _item(context, 'التغذية', Icons.medical_services_outlined),
    ]));
  }
  Widget _item(BuildContext context,String title,IconData icon)=>Card(elevation:0,margin:const EdgeInsets.only(bottom:10),child:ListTile(leading:CircleAvatar(backgroundColor:AppColors.primary.withOpacity(.10),child:Icon(icon,color:AppColors.primary)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:const Text('قيد التطوير — سيتم تفعيل هذه الخدمة مع حفظ بياناتك الصحية.'),trailing:const Icon(Icons.chevron_left),onTap:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('هذه الخدمة قيد التطوير حالياً.')))));
}
