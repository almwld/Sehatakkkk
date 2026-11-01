import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ParamedicFieldScreen extends StatefulWidget {
  final bool publicMode;
  const ParamedicFieldScreen({super.key, this.publicMode = false});
  @override State<ParamedicFieldScreen> createState() => _ParamedicFieldScreenState();
}

class _ParamedicFieldScreenState extends State<ParamedicFieldScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _name = TextEditingController(), _phone = TextEditingController(), _area = TextEditingController(), _address = TextEditingController(), _vehicle = TextEditingController(), _plate = TextEditingController(), _skills = TextEditingController();
  bool _available = true, _acceptingEmergency = true, _online = true, _saving = false, _locating = false;
  GeoPoint? _location;
  String _t(String value) => AppStrings.of(context).translate(value);

  @override void initState() { super.initState(); if (!widget.publicMode) _loadProfile(); }
  @override void dispose() { for (final c in [_name,_phone,_area,_address,_vehicle,_plate,_skills]) { c.dispose(); } super.dispose(); }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) return;
    final d = (await _firestore.collection('health_contacts').doc(uid).get()).data() ?? {};
    if (!mounted) return;
    setState(() {
      _name.text=(d['name']??'').toString(); _phone.text=(d['phone']??'').toString();
      _area.text=(d['serviceArea']??d['area']??'').toString(); _address.text=(d['address']??'').toString();
      _vehicle.text=(d['vehicleType']??'').toString(); _plate.text=(d['vehiclePlate']??'').toString();
      _skills.text=d['skills'] is List ? (d['skills'] as List).join('، ') : (d['skills']??'').toString();
      _available=d['isAvailable']!=false; _acceptingEmergency=d['acceptingEmergency']!=false; _online=d['isOnline']!=false;
      _location=d['location'] is GeoPoint ? d['location'] as GeoPoint : null;
    });
  }

  Future<void> _useGps() async {
    if (_locating) return; setState(()=>_locating=true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) { _message(_t('فعّل GPS في الهاتف أولاً'),error:true); return; }
      var permission=await Geolocator.checkPermission();
      if (permission==LocationPermission.denied) permission=await Geolocator.requestPermission();
      if (permission==LocationPermission.denied || permission==LocationPermission.deniedForever) { _message(_t('يلزم السماح بالموقع لتحديد تواجد المسعف'),error:true); return; }
      final p=await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
      setState(()=>_location=GeoPoint(p.latitude,p.longitude)); _message(_t('تم تحديث موقع التواجد الميداني'));
    } catch(e) { _message(_t('تعذر تحديد الموقع الحالي'),error:true); debugPrint('Paramedic GPS: $e'); }
    finally { if(mounted)setState(()=>_locating=false); }
  }

  Future<void> _saveProfile() async {
    final uid=FirebaseAuth.instance.currentUser?.uid; if(uid==null)return;
    if(_name.text.trim().isEmpty||_phone.text.trim().isEmpty||_area.text.trim().isEmpty){_message(_t('أكمل الاسم ورقم الهاتف ومنطقة الخدمة'),error:true);return;}
    setState(()=>_saving=true);
    try {
      final data=<String,dynamic>{
        'role':'paramedic','userId':uid,'name':_name.text.trim(),'phone':_phone.text.trim(),
        'serviceArea':_area.text.trim(),'area':_area.text.trim(),'address':_address.text.trim(),
        'vehicleType':_vehicle.text.trim(),'vehiclePlate':_plate.text.trim(),
        'skills':_skills.text.split('،').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList(),
        'isAvailable':_available,'acceptingEmergency':_acceptingEmergency,'isOnline':_online,
        'availabilityStatus':_available&&_online&&_acceptingEmergency?'available':'unavailable',
        'lastSeenAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp(),
      };
      if(_location!=null){data['location']=_location;data['latitude']=_location!.latitude;data['longitude']=_location!.longitude;}
      await _firestore.collection('health_contacts').doc(uid).set(data,SetOptions(merge:true));
      await _firestore.collection('users').doc(uid).set({
        'isAvailable':_available,'acceptingEmergency':_acceptingEmergency,'isOnline':_online,'serviceArea':_area.text.trim(),
        if(_location!=null)'location':_location,'locationUpdatedAt':FieldValue.serverTimestamp(),
      },SetOptions(merge:true));
      _message(_t('تم حفظ ملف المسعف وحالة التوفر'));
    } catch(e) { _message(_t('تعذر حفظ بيانات المسعف'),error:true); debugPrint('Paramedic save: $e'); }
    finally { if(mounted)setState(()=>_saving=false); }
  }

  Future<void> _requestParamedic(Map<String,dynamic> d,String id) async {
    final uid=FirebaseAuth.instance.currentUser?.uid;
    if(uid==null){_message(_t('سجّل الدخول لطلب مسعف'),error:true);return;}
    try {
      final p=await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
      await _firestore.collection('ambulance_requests').add({
        'patientId':uid,'paramedicId':id,'paramedicName':d['name']??'مسعف ميداني','status':'pending','emergency':true,
        'patientLocation':GeoPoint(p.latitude,p.longitude),'patientLatitude':p.latitude,'patientLongitude':p.longitude,
        'createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp(),
      });
      _message(_t('تم إرسال طلب الإسعاف إلى') + ' ' + (d['name']?.toString() ?? _t('المسعف')));
    } catch(e) { _message(_t('تعذر إرسال الطلب. تأكد من الموقع والاتصال'),error:true); }
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> _paramedics()=>_firestore.collection('health_contacts').where('role',isEqualTo:'paramedic').where('isAvailable',isEqualTo:true).where('isOnline',isEqualTo:true).where('acceptingEmergency',isEqualTo:true).limit(50).snapshots();
  Stream<QuerySnapshot<Map<String,dynamic>>> _requests(String uid)=>_firestore.collection('ambulance_requests').where('paramedicId',isEqualTo:uid).where('status',whereIn:const ['pending','accepted','en_route','on_scene']).limit(30).snapshots();
  Future<void> _setRequestStatus(String id,String status)=>_firestore.collection('ambulance_requests').doc(id).update({'status':status,'updatedAt':FieldValue.serverTimestamp()});
  void _message(String m,{bool error=false}){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(m),backgroundColor:error?Colors.red:AppColors.primary));}

  @override Widget build(BuildContext context)=>widget.publicMode?_publicView():_dashboardView();

  Widget _publicView()=>Scaffold(
    appBar:AppBar(title:Text(_t('المسعفون الميدانيون')),backgroundColor:AppColors.primary,foregroundColor:Colors.white),
    body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:_paramedics(),builder:(context,snapshot){
        final docs=snapshot.data?.docs??const [];
        return ListView(padding:const EdgeInsets.all(16),children:[
          _hero('المسعفون المتاحون الآن','اعرض المسعفين المتواجدين في مناطق الخدمة والمتاحين للاستجابة للطوارئ.'),
          const SizedBox(height:12),
          if(snapshot.hasError) Text(AppStrings.of(context).translate('تعذر تحميل المسعفين المتاحين') + ': ${snapshot.error}'),
          if(docs.isEmpty) Card(child:Padding(padding:const EdgeInsets.all(18),child:Text(AppStrings.of(context).translate('لا يوجد مسعف متاح حالياً وفق بيانات التواجد المسجلة.')))),
          ...docs.map((d)=>_paramedicCard(d.id,d.data())),
        ]);
      }),
  );

  Widget _dashboardView(){
    final uid=FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar:AppBar(title:Text(_t('لوحة المسعف الميداني')),backgroundColor:AppColors.primary,foregroundColor:Colors.white),
      body:uid==null?Center(child:Text(_t('يجب تسجيل الدخول'))):ListView(padding:const EdgeInsets.all(16),children:[
        _hero(_t('مركز الاستجابة الميدانية'),_t('حدّث بياناتك وموقعك وحالة التوفر ليظهر ملفك للمحتاجين في منطقتك.')),
        const SizedBox(height:12),_statusCard(),const SizedBox(height:12),
        _section(_t('البيانات المهنية'),[
          _field(_name,_t('اسم المسعف')),_field(_phone,_t('رقم الهاتف'),type:TextInputType.phone),
          _field(_area,_t('منطقة/مناطق الخدمة'),hint:_t('مثال: حدة، الصافية، صنعاء')),_field(_address,_t('عنوان نقطة التواجد الحالية')),
          _field(_vehicle,_t('نوع المركبة/سيارة الإسعاف')),_field(_plate,_t('رقم اللوحة')),
          _field(_skills,_t('المهارات والشهادات'),hint:'BLS, ACLS, advanced first aid'),
          const SizedBox(height:8),
          OutlinedButton.icon(onPressed:_locating?null:_useGps,icon:_locating?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.my_location),label:Text(_locating?_t('جارٍ تحديد الموقع...'):_t('تحديث موقع التواجد عبر GPS'))),
          if(_location!=null) Padding(padding:const EdgeInsets.only(top:8),child:Text('${_t('الموقع')}: ${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}')),
        ]),
        const SizedBox(height:12),SizedBox(height:52,child:FilledButton.icon(onPressed:_saving?null:_saveProfile,icon:const Icon(Icons.save),label:Text(_saving?_t('جارٍ الحفظ...'):_t('حفظ وتحديث حالة التواجد')))),
        const SizedBox(height:20),Text(_t('طلبات الإسعاف النشطة'),style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:8),
        StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:_requests(uid),builder:(context,snapshot){
          final docs=snapshot.data?.docs??const [];
          if(docs.isEmpty)return Card(child:Padding(padding:const EdgeInsets.all(16),child:Text(AppStrings.of(context).translate('لا توجد طلبات إسعاف نشطة.'))));
          return Column(children:docs.map((d)=>_requestCard(d.id,d.data())).toList());
        }),
      ]),
    );
  }

  Widget _statusCard() {
    final ready = _available && _online && _acceptingEmergency;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_t('حالة الاستجابة'), style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                Text(
                  ready ? _t('متاح الآن') : _t('غير متاح'),
                  style: TextStyle(
                    color: ready ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_t('متاح لاستقبال الطوارئ')),
              value: _available,
              onChanged: (v) => setState(() => _available = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_t('متصل ميدانياً')),
              value: _online,
              onChanged: (v) => setState(() => _online = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_t('أستقبل طلبات الإسعاف')),
              value: _acceptingEmergency,
              onChanged: (v) => setState(() => _acceptingEmergency = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paramedicCard(String id,Map<String,dynamic> d){
    final area=(d['serviceArea']??d['area']??'المنطقة غير محددة').toString();
    final vehicle=(d['vehicleType']??'مركبة إسعاف/استجابة').toString();
    final skills=d['skills'] is List?(d['skills'] as List).join('، '):(d['skills']??'').toString();
    return Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const CircleAvatar(child:Icon(Icons.emergency)),const SizedBox(width:10),Expanded(child:Text((d['name']??_t('مسعف ميداني')).toString(),style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16))),_availableBadge()]),
      const SizedBox(height:7),Text('${_t('متواجد في')}: $area'),Text('${_t('المركبة')}: $vehicle'),if(skills.isNotEmpty)Text('${_t('المهارات')}: $skills'),
      if((d['phone']??'').toString().isNotEmpty)Text('${_t('الهاتف')}: ${d['phone']}'),const SizedBox(height:8),
      SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>_requestParamedic(d,id),icon:const Icon(Icons.sos),label:Text(_t('طلب هذا المسعف')))),
    ])));
  }
  Widget _availableBadge()=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Colors.green.withOpacity(.12),borderRadius:BorderRadius.circular(20)),child:Text(_t('متاح الآن'),style:const TextStyle(color:Colors.green,fontWeight:FontWeight.bold,fontSize:11)));

  Widget _requestCard(String id,Map<String,dynamic> d){
    final status=(d['status']??'pending').toString();
    const labels={'pending':'طلب جديد','accepted':'تم القبول','en_route':'في الطريق','on_scene':'وصل للموقع'};
    const next={'pending':'accepted','accepted':'en_route','en_route':'on_scene','on_scene':'completed'};
    const nextLabel={'pending':'قبول الطلب','accepted':'بدء التوجه','en_route':'تأكيد الوصول','on_scene':'إنهاء الحالة'};
    final n=next[status];
    return Card(child:ListTile(leading:const Icon(Icons.emergency,color:Colors.red),title:Text(_t(labels[status]??status)),subtitle:Text('${_t('المريض')}: ${d['patientId']??''}'),trailing:n==null?null:FilledButton(onPressed:()=>_setRequestStatus(id,n),child:Text(_t(nextLabel[status]??n)))));
  }

  Widget _hero(String title,String subtitle)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(subtitle,style:const TextStyle(color:Colors.white70,height:1.4))]));
  Widget _section(String title,List<Widget> children)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),const Divider(),...children])));
  Widget _field(TextEditingController c,String label,{TextInputType? type,String? hint})=>Padding(padding:const EdgeInsets.only(bottom:9),child:TextField(controller:c,keyboardType:type,decoration:InputDecoration(labelText:label,hintText:hint,border:const OutlineInputBorder())));
}
