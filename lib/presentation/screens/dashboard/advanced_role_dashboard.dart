
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/admin/super_admin_dashboard.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_dashboard.dart';

class AdvancedRoleDashboardScreen extends StatelessWidget {
  final String role;
  const AdvancedRoleDashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'doctor') return const _DoctorControlCenter();
    if (role == 'pharmacy' || role == 'pharmacist' || role == 'pharmacyOwner') return const PharmacyDashboard();
    if (['lab','hospital','clinic','medical_center','dental','dentist','ophthalmology','optometrist','nurse','midwife','physiotherapist','paramedic','veterinarian'].contains(role)) return _FacilityControlCenter(role: role);
    if (role == 'superAdmin') return const SuperAdminDashboard();
    if (role == 'admin') return const _AdminControlCenter();
    return _ProviderControlCenter(role: role);
  }
}

class _DoctorControlCenter extends StatefulWidget {
  const _DoctorControlCenter();
  @override
  State<_DoctorControlCenter> createState() => _DoctorControlCenterState();
}

class _DoctorControlCenterState extends State<_DoctorControlCenter> {
  final _hospital = TextEditingController();
  final _clinic = TextEditingController();
  final _fee = TextEditingController();
  final _messageLimit = TextEditingController(text: '20');
  final _appointmentLimit = TextEditingController(text: '20');
  final _service = TextEditingController();

  bool loading = true, saving = false;
  bool available = false, online = false, newPatients = true, appointments = true;
  bool chat = true, calls = true, video = true, attachments = true;
  String presence = 'المستشفى';
  List<String> services = [];
  Map<String, dynamic> hours = {};
  List<Map<String, dynamic>> vacations = [];
  Set<String> blockedPatients = {};

  static const days = ['السبت','الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة'];

  @override
  void initState() { super.initState(); load(); }

  @override
  void dispose() {
    _hospital.dispose(); _clinic.dispose(); _fee.dispose();
    _messageLimit.dispose(); _appointmentLimit.dispose(); _service.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final s = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final d = s.data() ?? {};
    final m = d['messageSettings'] is Map ? Map<String, dynamic>.from(d['messageSettings']) : {};
    _hospital.text = d['hospital']?.toString() ?? '';
    _clinic.text = d['clinicAddress']?.toString() ?? '';
    _fee.text = d['consultationFee']?.toString() ?? '0';
    _messageLimit.text = (m['dailyLimit'] ?? 20).toString();
    _appointmentLimit.text = (d['maxDailyAppointments'] ?? 20).toString();
    available = d['isAvailable'] == true; online = d['isOnline'] == true;
    newPatients = d['acceptingPatients'] != false;
    appointments = d['acceptingAppointments'] != false;
    chat = m['enabled'] != false; calls = d['acceptingCalls'] != false;
    video = d['acceptingVideo'] != false; attachments = m['allowAttachments'] != false;
    presence = d['presenceMode']?.toString() ?? 'المستشفى';
    services = d['services'] is List ? List<String>.from(d['services'].map((e) => e.toString())) : [];
    hours = d['workingHours'] is Map ? Map<String, dynamic>.from(d['workingHours']) : {};
    vacations = d['vacations'] is List ? d['vacations'].map((e) => e is Map ? Map<String,dynamic>.from(e) : <String,dynamic>{}).toList() : [];
    blockedPatients = d['blockedPatientIds'] is List ? Set<String>.from(d['blockedPatientIds'].map((e) => e.toString())) : {};
    if (mounted) setState(() => loading = false);
  }

  Future<void> save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => saving = true);
    final data = <String,dynamic>{
      'isAvailable': available, 'isOnline': online, 'acceptingPatients': newPatients,
      'acceptingAppointments': appointments, 'acceptingCalls': calls, 'acceptingVideo': video,
      'presenceMode': presence, 'hospital': _hospital.text.trim(), 'clinicAddress': _clinic.text.trim(),
      'consultationFee': double.tryParse(_fee.text) ?? 0,
      'maxDailyAppointments': int.tryParse(_appointmentLimit.text) ?? 20,
      'messageSettings': {'enabled': chat, 'dailyLimit': int.tryParse(_messageLimit.text) ?? 20, 'allowAttachments': attachments},
      'services': services, 'workingHours': hours, 'vacations': vacations,
      'blockedPatientIds': blockedPatients.toList(), 'availabilityUpdatedAt': FieldValue.serverTimestamp()
    };
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
      await FirebaseFirestore.instance.collection('doctors').doc(uid).set(<String,dynamic>{...data,'userId':uid,'uid':uid}, SetOptions(merge:true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ إعدادات الطبيب وتحديث ملفه في قائمة الأطباء')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> editDay(String day) async {
    final old = hours[day] is Map ? Map<String,dynamic>.from(hours[day]) : {};
    bool enabled = old.isEmpty ? true : old['enabled'] != false;
    TimeOfDay start = parseTime(old['start']?.toString()) ?? const TimeOfDay(hour:9,minute:0);
    TimeOfDay end = parseTime(old['end']?.toString()) ?? const TimeOfDay(hour:17,minute:0);
    final result = await showModalBottomSheet<Map<String,dynamic>>(context:context, builder:(c)=>StatefulBuilder(
      builder:(c,setSheet)=>Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(day,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
        SwitchListTile(title:const Text('متاح هذا اليوم'),value:enabled,onChanged:(v)=>setSheet(()=>enabled=v)),
        ListTile(title:Text('من '+fmt(start)),onTap:()async{final t=await showTimePicker(context:c,initialTime:start);if(t!=null)setSheet(()=>start=t);}),
        ListTile(title:Text('إلى '+fmt(end)),onTap:()async{final t=await showTimePicker(context:c,initialTime:end);if(t!=null)setSheet(()=>end=t);}),
        SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pop(c,<String,dynamic>{'enabled':enabled,'start':fmt(start),'end':fmt(end)}),child:const Text('حفظ اليوم')))
      ]))
    ));
    if(result!=null)setState(()=>hours[day]=result);
  }

  TimeOfDay? parseTime(String? v){if(v==null||!v.contains(':'))return null;final p=v.split(':');return TimeOfDay(hour:int.tryParse(p[0])??9,minute:int.tryParse(p[1])??0);}
  String fmt(TimeOfDay t)=>t.hour.toString().padLeft(2,'0')+':'+t.minute.toString().padLeft(2,'0');

  Future<void> addVacation() async {
    final a=await showDatePicker(context:context,firstDate:DateTime.now(),lastDate:DateTime.now().add(const Duration(days:730)),initialDate:DateTime.now(),helpText:'بداية الإجازة');
    if(a==null||!mounted)return;
    final b=await showDatePicker(context:context,firstDate:a,lastDate:DateTime.now().add(const Duration(days:730)),initialDate:a,helpText:'نهاية الإجازة');
    if(b!=null)setState(()=>vacations.add({'start':a.toIso8601String(),'end':b.toIso8601String()}));
  }

  @override
  Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:const Text('لوحة تحكم الطبيب'),backgroundColor:AppColors.primary,foregroundColor:Colors.white),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        _hero(),const SizedBox(height:12),_stats(),const SizedBox(height:12),
        _section('الحالة والتواجد',[
          sw('متاح للحجز والاستشارات',available,(v)=>setState(()=>available=v)),
          sw('متصل الآن',online,(v)=>setState(()=>online=v)),
          sw('استقبال مرضى جدد',newPatients,(v)=>setState(()=>newPatients=v)),
          sw('استقبال المواعيد',appointments,(v)=>setState(()=>appointments=v)),
          sw('استقبال الدردشة',chat,(v)=>setState(()=>chat=v)),
          sw('المكالمات الصوتية',calls,(v)=>setState(()=>calls=v)),
          sw('مكالمات الفيديو',video,(v)=>setState(()=>video=v)),
          sw('السماح بالمرفقات',attachments,(v)=>setState(()=>attachments=v)),
        ]),const SizedBox(height:12),
        _section('مكان التواجد والملف الظاهر',[
          DropdownButtonFormField<String>(value:['المستشفى','العيادة','عن بُعد','غير متاح'].contains(presence)?presence:'المستشفى',decoration:const InputDecoration(labelText:'مكان التواجد'),items:const ['المستشفى','العيادة','عن بُعد','غير متاح'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)setState(()=>presence=v);}),
          field(_hospital,'المستشفى / المنشأة'),field(_clinic,'عنوان العيادة'),field(_fee,'سعر الاستشارة (ر.ي)',number:true),
        ]),const SizedBox(height:12),
        _section('الدوام الأسبوعي',days.map((day){final d=hours[day] is Map?Map<String,dynamic>.from(hours[day]):{};final label=d.isEmpty?'لم يتم تحديد الدوام':(d['enabled']==false?'إجازة أسبوعية':d['start'].toString()+' — '+d['end'].toString());return ListTile(contentPadding:EdgeInsets.zero,title:Text(day,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(label),trailing:const Icon(Icons.edit_calendar),onTap:()=>editDay(day));}).toList()),
        const SizedBox(height:12),
        _section('حدود المرضى والرسائل',[
          field(_messageLimit,'الحد الأقصى لرسائل كل مريض يوميًا',number:true),
          field(_appointmentLimit,'الحد الأقصى للمواعيد يوميًا',number:true),
          const Text('الحد يختاره الطبيب ويُحفظ مع الحساب؛ الهدف منع استقبال رسائل أو مواعيد بلا سقف.',style:TextStyle(fontSize:11,color:Colors.grey))
        ]),const SizedBox(height:12),
        _section('الخدمات',[
          Row(children:[Expanded(child:TextField(controller:_service,decoration:const InputDecoration(hintText:'إضافة خدمة'))),IconButton.filled(onPressed:(){final s=_service.text.trim();if(s.isNotEmpty)setState((){if(!services.contains(s))services.add(s);_service.clear();});},icon:const Icon(Icons.add))]),
          Wrap(spacing:6,children:services.map((s)=>InputChip(label:Text(s),onDeleted:()=>setState(()=>services.remove(s)))).toList())
        ]),const SizedBox(height:12),
        _section('الإجازات',[...vacations.asMap().entries.map((e)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(vacationLabel(e.value)),trailing:IconButton(onPressed:()=>setState(()=>vacations.removeAt(e.key)),icon:const Icon(Icons.delete_outline))),OutlinedButton.icon(onPressed:addVacation,icon:const Icon(Icons.add),label:const Text('إضافة إجازة'))]),
        const SizedBox(height:12),_section('المرضى',[_patients()]),const SizedBox(height:18),
        SizedBox(height:54,child:FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save),label:Text(saving?'جارٍ الحفظ...':'حفظ كل إعدادات الطبيب')))
      ])
    );
  }

  Widget _patients(){
    final uid=FirebaseAuth.instance.currentUser?.uid;if(uid==null)return const Text('يجب تسجيل الدخول');
    return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:FirebaseFirestore.instance.collection('chats').where('participants',arrayContains:uid).limit(100).snapshots(),
      builder:(c,s){final seen=<String>{};final rows=<Widget>[];for(final doc in s.data?.docs??[]){final p=List<String>.from(doc.data()['participants']??[]);if(p.length!=2)continue;final id=p.firstWhere((x)=>x!=uid,orElse:()=>'' );if(id.isEmpty||!seen.add(id))continue;final details=doc.data()['participantDetails'];final name=details is Map&&details[id] is Map?(details[id]['name']?.toString()??'مريض'):'مريض';final blocked=blockedPatients.contains(id);rows.add(SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(name),subtitle:Text(blocked?'موقوف من التواصل':'يمكنه التواصل ضمن حدود الطبيب'),value:!blocked,onChanged:(v)=>setState(()=>v?blockedPatients.remove(id):blockedPatients.add(id))));}return rows.isEmpty?const Text('لا يوجد مرضى مرتبطون بالدردشات حتى الآن.',style:TextStyle(color:Colors.grey)):Column(children:rows);});
  }

  String vacationLabel(Map<String,dynamic> v){final a=DateTime.tryParse(v['start']?.toString()??'');final b=DateTime.tryParse(v['end']?.toString()??'');if(a==null||b==null)return'إجازة';return'إجازة: '+a.day.toString()+'/'+a.month.toString()+'/'+a.year.toString()+' — '+b.day.toString()+'/'+b.month.toString()+'/'+b.year.toString();}
  Widget _hero()=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('مركز التحكم المهني',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),SizedBox(height:5),Text('الطبيب صاحب القرار في التواجد والدوام والمرضى والرسائل والمواعيد.',style:TextStyle(color:Colors.white70))]));
  Widget _stats(){final uid=FirebaseAuth.instance.currentUser?.uid;if(uid==null)return const SizedBox();return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('appointments').where('doctorId',isEqualTo:uid).limit(100).snapshots(),builder:(c,a)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('chats').where('participants',arrayContains:uid).limit(100).snapshots(),builder:(c,s){final n=s.data?.docs.where((d)=>(d.data()['participants'] is List)&&(d.data()['participants'] as List).length==2).length??0;return Row(children:[Expanded(child:stat('المواعيد',(a.data?.docs.length??0).toString(),Icons.calendar_month)),const SizedBox(width:7),Expanded(child:stat('المرضى',n.toString(),Icons.people_alt)),const SizedBox(width:7),Expanded(child:stat('رسائل/مريض',_messageLimit.text,Icons.chat))]);}));}
  Widget stat(String t,String v,IconData i)=>Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(14)),child:Column(children:[Icon(i,color:AppColors.primary),Text(v,style:const TextStyle(fontWeight:FontWeight.w900)),Text(t,style:const TextStyle(fontSize:9,color:Colors.grey))]));
  Widget sw(String t,bool v,ValueChanged<bool> f)=>SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(t),value:v,onChanged:f);
  Widget field(TextEditingController c,String l,{bool number=false})=>Padding(padding:const EdgeInsets.only(top:8),child:TextFormField(controller:c,keyboardType:number?TextInputType.number:null,decoration:InputDecoration(labelText:l,border:const OutlineInputBorder())));
  Widget _section(String t,List<Widget> children)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900)),const Divider(),...children]));
}

class _ProviderControlCenter extends StatefulWidget{
  final String role;const _ProviderControlCenter({required this.role});
  @override State<_ProviderControlCenter> createState()=>_ProviderControlCenterState();
}
class _ProviderControlCenterState extends State<_ProviderControlCenter>{
  bool available=false,online=false,accepting=true,appointments=true,chat=true,calls=true,saving=false;
  String presence='المنشأة';final facility=TextEditingController(),location=TextEditingController(),limit=TextEditingController(text:'20');
  @override void initState(){super.initState();load();}
  @override void dispose(){facility.dispose();location.dispose();limit.dispose();super.dispose();}
  Future<void> load()async{final uid=FirebaseAuth.instance.currentUser?.uid;if(uid==null)return;final s=await FirebaseFirestore.instance.collection('users').doc(uid).get();final d=s.data()??{};if(mounted)setState((){available=d['isAvailable']==true;online=d['isOnline']==true;accepting=d['acceptingPatients']!=false;appointments=d['acceptingAppointments']!=false;chat=d['acceptingChat']!=false;calls=d['acceptingCalls']!=false;presence=d['presenceMode']?.toString()??'المنشأة';facility.text=d['hospital']?.toString()??'';location.text=d['location']?.toString()??'';limit.text=(d['maxDailyRequests']??20).toString();});}
  Future<void> save()async{final uid=FirebaseAuth.instance.currentUser?.uid;if(uid==null)return;setState(()=>saving=true);try{await FirebaseFirestore.instance.collection('users').doc(uid).update({'isAvailable':available,'isOnline':online,'acceptingPatients':accepting,'acceptingAppointments':appointments,'acceptingChat':chat,'acceptingCalls':calls,'presenceMode':presence,'hospital':facility.text.trim(),'location':location.text.trim(),'maxDailyRequests':int.tryParse(limit.text)??20,'availabilityUpdatedAt':FieldValue.serverTimestamp()});if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ إعدادات الحساب المهني')));}finally{if(mounted)setState(()=>saving=false);}}
  @override Widget build(BuildContext context){final title=AppRoles.getRoleName(widget.role);return Scaffold(appBar:AppBar(title:Text('لوحة تحكم '+title),backgroundColor:AppColors.primary,foregroundColor:Colors.white),body:ListView(padding:const EdgeInsets.all(16),children:[Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('لوحة '+title,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('تحكم في التواجد واستقبال الطلبات وبيانات الحساب.',style:TextStyle(color:Colors.white70))])),const SizedBox(height:12),section('التواجد والاستقبال',[sw('متاح',available,(v)=>setState(()=>available=v)),sw('متصل الآن',online,(v)=>setState(()=>online=v)),sw('استقبال طلبات جديدة',accepting,(v)=>setState(()=>accepting=v)),sw('استقبال المواعيد',appointments,(v)=>setState(()=>appointments=v)),sw('الدردشة',chat,(v)=>setState(()=>chat=v)),sw('المكالمات',calls,(v)=>setState(()=>calls=v)),DropdownButtonFormField<String>(value:['المنشأة','عن بُعد','غير متاح'].contains(presence)?presence:'المنشأة',decoration:const InputDecoration(labelText:'مكان التواجد'),items:const ['المنشأة','عن بُعد','غير متاح'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)setState(()=>presence=v);})]),const SizedBox(height:12),section('البيانات الظاهرة',[TextField(controller:facility,decoration:const InputDecoration(labelText:'المنشأة / المستشفى')),TextField(controller:location,decoration:const InputDecoration(labelText:'الموقع / العنوان')),TextField(controller:limit,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'الحد الأقصى للطلبات يوميًا'))]),const SizedBox(height:12),SizedBox(height:52,child:FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save),label:Text(saving?'جارٍ الحفظ...':'حفظ الإعدادات')))]) );}
  Widget sw(String t,bool v,ValueChanged<bool> f)=>SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(t),value:v,onChanged:f);
  Widget section(String t,List<Widget> c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900)),const Divider(),...c]));
}

class _PharmacyOwnerControlCenter extends StatefulWidget {
  const _PharmacyOwnerControlCenter();
  @override State<_PharmacyOwnerControlCenter> createState()=>_PharmacyOwnerControlCenterState();
}
class _PharmacyOwnerControlCenterState extends State<_PharmacyOwnerControlCenter>{
  final name=TextEditingController(),address=TextEditingController(),logo=TextEditingController(),cover=TextEditingController(),productName=TextEditingController(),productImage=TextEditingController(),price=TextEditingController(),discount=TextEditingController();
  bool saving=false,acceptingOrders=true;
  String category='عام';
  @override void initState(){super.initState();load();}
  @override void dispose(){for(final c in [name,address,logo,cover,productName,productImage,price,discount])c.dispose();super.dispose();}
  Future<void> load()async{final u=FirebaseAuth.instance.currentUser;if(u==null)return;final d=(await FirebaseFirestore.instance.collection('users').doc(u.uid).get()).data()??{};if(mounted)setState((){name.text=d['pharmacyName']?.toString()??d['displayName']?.toString()??'';address.text=d['address']?.toString()??'';logo.text=d['pharmacyLogoUrl']?.toString()??'';cover.text=d['pharmacyCoverUrl']?.toString()??'';acceptingOrders=d['acceptingOrders']!=false;});}
  Future<void> save()async{final u=FirebaseAuth.instance.currentUser;if(u==null)return;setState(()=>saving=true);try{await FirebaseFirestore.instance.collection('users').doc(u.uid).set({'pharmacyName':name.text.trim(),'address':address.text.trim(),'pharmacyLogoUrl':logo.text.trim(),'pharmacyCoverUrl':cover.text.trim(),'acceptingOrders':acceptingOrders,'pharmacyProfileStatus':'pending_review','updatedAt':FieldValue.serverTimestamp()},SetOptions(merge:true));if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ بيانات الصيدلية وإرسال التغييرات للمراجعة')));}finally{if(mounted)setState(()=>saving=false);}}
  Future<void> addProduct()async{final u=FirebaseAuth.instance.currentUser;if(u==null||productName.text.trim().isEmpty)return;final p=double.tryParse(price.text.trim())??0;final d=double.tryParse(discount.text.trim())??0;final finalPrice=d>0?p-(p*d/100):p;await FirebaseFirestore.instance.collection('pharmacy_products').add({'ownerId':u.uid,'pharmacyId':u.uid,'name':productName.text.trim(),'category':category,'imageUrl':productImage.text.trim(),'price':p,'discountPercent':d,'finalPrice':finalPrice,'status':'pending_review','isPublished':false,'createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()});if(mounted){productName.clear();productImage.clear();price.clear();discount.clear();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تمت إضافة الدواء — جاري المراجعة قبل النشر')));setState((){});}}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('لوحة تحكم الصيدلية'),backgroundColor:AppColors.primary,foregroundColor:Colors.white),body:ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name.text.isEmpty?'إدارة الصيدلية':name.text,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('المالك يتحكم بالمنتجات والأسعار والخصومات وبيانات الصيدلية.',style:TextStyle(color:Colors.white70))])),
    const SizedBox(height:12),_section('بيانات الصيدلية',[field(name,'اسم الصيدلية'),field(address,'العنوان'),field(logo,'رابط شعار الصيدلية'),field(cover,'رابط صورة الخلفية'),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('استقبال الطلبات'),value:acceptingOrders,onChanged:(v)=>setState(()=>acceptingOrders=v))]),
    const SizedBox(height:12),_section('إضافة منتج / دواء',[field(productName,'اسم الدواء'),field(productImage,'رابط صورة المنتج'),field(price,'السعر',number:true),field(discount,'الخصم %',number:true),DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'التصنيف'),items:const ['عام','مسكنات','مضادات حيوية','فيتامينات','أدوية مزمنة','أخرى'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setState(()=>category=v);}),const SizedBox(height:8),FilledButton.icon(onPressed:addProduct,icon:const Icon(Icons.add_shopping_cart),label:const Text('حفظ المنتج وإرساله للمراجعة'))]),
    const SizedBox(height:12),_products(),const SizedBox(height:12),SizedBox(height:52,child:FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save),label:Text(saving?'جارٍ الحفظ...':'حفظ إعدادات الصيدلية'))]));
  Widget _products()=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('pharmacy_products').where('ownerId',isEqualTo:FirebaseAuth.instance.currentUser?.uid).snapshots(),builder:(c,s)=>_section('منتجاتي',[(s.data?.docs.isEmpty??true)?const Text('لا توجد منتجات بعد.'):...s.data!.docs.map((d){final x=d.data();final st=x['status']=='approved'?'معتمد':x['status']=='rejected'?'مرفوض':'جاري المراجعة';return ListTile(title:Text(x['name']?.toString()??'منتج'),subtitle:Text(st+' • '+(x['price']?.toString()??'0')+' ر.ي • خصم '+(x['discountPercent']?.toString()??'0')+'%'),leading:const Icon(Icons.medication_outlined));})]));
  Widget field(TextEditingController c,String l,{bool number=false})=>Padding(padding:const EdgeInsets.only(top:8),child:TextField(controller:c,keyboardType:number?TextInputType.numberWithOptions(decimal:true):null,decoration:InputDecoration(labelText:l,border:const OutlineInputBorder())));
  Widget _section(String t,List<Widget> c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900)),const Divider(),...c]));
}

class _FacilityControlCenter extends StatefulWidget {
  final String role;
  const _FacilityControlCenter({required this.role});
  @override State<_FacilityControlCenter> createState()=>_FacilityControlCenterState();
}
class _FacilityControlCenterState extends State<_FacilityControlCenter>{
  final name=TextEditingController(),address=TextEditingController(),logo=TextEditingController(),cover=TextEditingController(),phone=TextEditingController(),services=TextEditingController();
  bool available=true,accepting=true,saving=false;
  String facilityType='';
  @override void initState(){super.initState();load();}
  @override void dispose(){for(final c in [name,address,logo,cover,phone,services])c.dispose();super.dispose();}
  Future<void> load()async{final u=FirebaseAuth.instance.currentUser;if(u==null)return;final d=(await FirebaseFirestore.instance.collection('users').doc(u.uid).get()).data()??{};if(mounted)setState((){name.text=d['facilityName']?.toString()??d['displayName']?.toString()??'';address.text=d['address']?.toString()??'';logo.text=d['facilityLogoUrl']?.toString()??'';cover.text=d['facilityCoverUrl']?.toString()??'';phone.text=d['phone']?.toString()??'';services.text=(d['services'] is List)?List.from(d['services']).join('، '):'';facilityType=d['facilityType']?.toString()??widget.role;available=d['isAvailable']!=false;accepting=d['acceptingPatients']!=false;});}
  Future<void> save()async{final u=FirebaseAuth.instance.currentUser;if(u==null)return;setState(()=>saving=true);try{final data={'facilityName':name.text.trim(),'facilityType':facilityType,'address':address.text.trim(),'phone':phone.text.trim(),'facilityLogoUrl':logo.text.trim(),'facilityCoverUrl':cover.text.trim(),'services':services.text.split('،').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList(),'isAvailable':available,'acceptingPatients':accepting,'facilityProfileStatus':'pending_review','updatedAt':FieldValue.serverTimestamp()};await FirebaseFirestore.instance.collection('users').doc(u.uid).set(data,SetOptions(merge:true));await FirebaseFirestore.instance.collection('health_facilities').doc(u.uid).set({...data,'ownerId':u.uid,'status':'pending_review','isPublished':false},SetOptions(merge:true));if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ بيانات المنشأة وإرسالها للمراجعة')));}finally{if(mounted)setState(()=>saving=false);}}
  @override Widget build(BuildContext context){final title=AppRoles.getRoleName(widget.role);return Scaffold(appBar:AppBar(title:Text('لوحة تحكم '+title),backgroundColor:AppColors.primary,foregroundColor:Colors.white),body:ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name.text.isEmpty?'إدارة المنشأة':name.text,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text('لوحة مخصصة لـ '+title+' بحسب نوع المنشأة',style:const TextStyle(color:Colors.white70))])),
    const SizedBox(height:12),_section('هوية المنشأة',[field(name,'اسم المنشأة'),field(address,'العنوان'),field(phone,'رقم الهاتف'),field(logo,'رابط الشعار'),field(cover,'رابط الخلفية')]),
    const SizedBox(height:12),_section('التشغيل',[SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('المنشأة متاحة'),value:available,onChanged:(v)=>setState(()=>available=v)),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('استقبال المرضى/الطلبات'),value:accepting,onChanged:(v)=>setState(()=>accepting=v)),TextField(controller:services,decoration:const InputDecoration(labelText:'الخدمات — افصل بينها بـ ،'))]),
    const SizedBox(height:12),_section('نوع المنشأة',[DropdownButtonFormField<String>(value:facilityType.isEmpty?widget.role:facilityType,items:[DropdownMenuItem(value:widget.role,child:Text(title)),const DropdownMenuItem(value:'hospital',child:Text('مستشفى')),const DropdownMenuItem(value:'clinic',child:Text('عيادة')),const DropdownMenuItem(value:'medical_center',child:Text('مركز طبي')),const DropdownMenuItem(value:'dental_clinic',child:Text('عيادة أسنان')),const DropdownMenuItem(value:'eye_clinic',child:Text('مركز عيون')),const DropdownMenuItem(value:'lab',child:Text('مختبر')),].toList(),onChanged:(v){if(v!=null)setState(()=>facilityType=v);})]),
    const SizedBox(height:12),Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.orange.withOpacity(.1),borderRadius:BorderRadius.circular(14)),child:const Text('حالة المنشأة: جاري المراجعة. لن تظهر للعامة حتى تعتمدها الإدارة.')),
    const SizedBox(height:12),SizedBox(height:52,child:FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save),label:Text(saving?'جارٍ الحفظ...':'حفظ وإرسال للمراجعة')))
  ]);}
  Widget field(TextEditingController c,String l)=>Padding(padding:const EdgeInsets.only(top:8),child:TextField(controller:c,decoration:InputDecoration(labelText:l,border:const OutlineInputBorder())));
  Widget _section(String t,List<Widget> c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.w900)),const Divider(),...c]));
}

class _AdminControlCenter extends StatelessWidget{
  const _AdminControlCenter();
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('لوحة تحكم الإدارة'),backgroundColor:AppColors.primary,foregroundColor:Colors.white),body:ListView(padding:const EdgeInsets.all(16),children:[Card(child:ListTile(title:const Text('إدارة التوثيق والحسابات المهنية'),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const PlatformDashboard())))),const Card(child:ListTile(title:Text('إدارة الصلاحيات والمستخدمين'))),const Card(child:ListTile(title:Text('إدارة السوق والمحتوى')))]));
}
