import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_health_info_screen.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_tracking_screen.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});
  @override State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with SingleTickerProviderStateMixin {
  String _t(String value) => AppStrings.of(context).translate(value);
  late final TabController _tabController;
  final _orderIdController = TextEditingController();
  String _selectedType = 'standard';

  @override void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); }
  @override void dispose() { _tabController.dispose(); _orderIdController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_t('خدمة التوصيل')), backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        bottom: TabBar(controller: _tabController, tabs: [Tab(text:_t('الخدمات المتاحة')),Tab(text:_t('معلومات التوصيل')),Tab(text:_t('تتبع الطلب'))]),
      ),
      body: TabBarView(controller:_tabController, children:[_buildServices(dark),const DeliveryHealthInfoScreen(),_buildTracking(dark)]),
    );
  }

  Widget _buildServices(bool dark) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Center(child: Text(_t('سجل الدخول أولاً.')));
    return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream: FirebaseFirestore.instance.collection('delivery_services').where('isActive', isEqualTo: true).snapshots(),
      builder:(context,snapshot){
        if(snapshot.hasError) return Center(child:Text(_t('تعذر تحميل خدمات التوصيل.')));
        if(snapshot.connectionState==ConnectionState.waiting) return const Center(child:CircularProgressIndicator());
        final docs=snapshot.data?.docs??const [];
        if(docs.isEmpty) return Center(child:Padding(padding:const EdgeInsets.all(24),child:Text(_t('لا توجد خدمة توصيل مفعلة حالياً.'))));
        final services=docs.map((d)=>d.data()).where((d)=>d['type']==_selectedType).toList();
        return Column(children:[
          Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:DropdownButtonFormField<String>(value:_selectedType,decoration:InputDecoration(labelText:_t('نوع التوصيل'),border:const OutlineInputBorder()),items: [DropdownMenuItem(value:'standard',child:Text(_t('عادي'))),DropdownMenuItem(value:'express',child:Text(_t('سريع'))),DropdownMenuItem(value:'premium',child:Text(_t('مميز')))],onChanged:(v){if(v!=null)setState(()=>_selectedType=v);})),
          Expanded(child:services.isEmpty?Center(child:Text(_t('لا توجد خدمة متاحة لهذا النوع.'))):ListView.builder(padding:const EdgeInsets.all(16),itemCount:services.length,itemBuilder:(context,i)=>_serviceCard(services[i],dark))),
        ]);
      },
    );
  }

  Widget _serviceCard(Map<String,dynamic> data,bool dark) {
    final name=data['name']?.toString()??_t('خدمة توصيل');
    final price=(data['price'] as num?)?.toDouble();
    final eta=data['estimatedMinutes'];
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
      Container(width:56,height:56,decoration:BoxDecoration(color:AppColors.primary.withOpacity(.1),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.delivery_dining_rounded,color:AppColors.primary,size:30)),
      const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:const TextStyle(fontSize:16,fontWeight:FontWeight.bold)),if(eta!=null)Text('${_t('المدة المتوقعة')}: $eta ${_t('دقيقة')}'),if(price!=null)Text(AppStrings.of(context).formatCurrency(price),style:const TextStyle(fontWeight:FontWeight.bold,color:AppColors.primary))])),
      ElevatedButton(onPressed:()=>_selectService(data),child:Text(_t('اختيار'))),
    ])));
  }

  Future<void> _selectService(Map<String,dynamic> service) async {
    final uid=FirebaseAuth.instance.currentUser?.uid; if(uid==null)return;
    final ref=FirebaseFirestore.instance.collection('users').doc(uid).collection('preferences').doc('delivery');
    await ref.set({'serviceId':service['id']??service['serviceId'],'serviceName':service['name'],'type':service['type'],'updatedAt':FieldValue.serverTimestamp()});
    final savedMessage = _t('تم حفظ خدمة التوصيل للاستخدام في الطلبات القادمة.');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savedMessage)));
    }
  }

  Widget _buildTracking(bool dark)=>Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.location_searching_rounded,size:64,color:AppColors.primary),const SizedBox(height:16),Text(_t('تتبع طلبك'),style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),Text(_t('أدخل رقم طلبك لعرض الحالة الفعلية المسجلة للطلب.'),textAlign:TextAlign.center),const SizedBox(height:20),
    TextField(controller:_orderIdController,textDirection:TextDirection.ltr,decoration:InputDecoration(labelText:_t('رقم الطلب'),border:const OutlineInputBorder())),const SizedBox(height:14),
    SizedBox(width:double.infinity,height:50,child:ElevatedButton.icon(onPressed:(){final id=_orderIdController.text.trim();if (id.isEmpty) { final message = _t('أدخل رقم الطلب أولاً.'); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); return; }Navigator.push(context,MaterialPageRoute(builder:(_)=>DeliveryTrackingScreen(orderId:id)));},icon:const Icon(Icons.my_location),label:Text(_t('عرض التتبع')))),
  ]));
}
