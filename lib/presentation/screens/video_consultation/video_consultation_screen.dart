import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({super.key});
  @override State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}
class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  List<Map<String,dynamic>> _doctors=[]; bool _isLoading=true; String _selectedFilter='الكل';
  final _filters=['الكل','متاح الآن','الأعلى تقييماً','الأقل سعراً'];
  @override void initState(){super.initState();_loadDoctors();}
  Future<void> _loadDoctors() async { try {
    final snap=await FirebaseFirestore.instance.collection('doctors').where('isActive',isEqualTo:true).limit(50).get();
    if(!mounted)return; setState((){_doctors=snap.docs.map((d){final x=d.data();return {...x,'id':d.id,'name':x['name']??x['displayName']??'طبيب','specialty':x['specialty']??x['specialization']??'عام','rating':(x['rating'] as num?)?.toDouble()??0.0,'reviews':(x['reviews'] as num?)?.toInt()??0,'price':'${x['consultationPrice']??x['price']??0}','available':x['available']==true,'online':x['online']==true,'image':x['imageUrl']??x['image']??'','nextAvailable':x['nextAvailable']??'غير محدد'};}).toList();_isLoading=false;});
  } catch(_){if(mounted)setState((){_doctors=[];_isLoading=false;});}}
  List<Map<String,dynamic>> get _filteredDoctors {final l=List<Map<String,dynamic>>.from(_doctors);switch(_selectedFilter){case'متاح الآن':l.retainWhere((d)=>d['online']==true);break;case'الأعلى تقييماً':l.sort((a,b)=>(b['rating'] as double).compareTo(a['rating'] as double));break;case'الأقل سعراً':l.sort((a,b)=>(double.tryParse(a['price'].toString())??double.maxFinite).compareTo(double.tryParse(b['price'].toString())??double.maxFinite));}return l;}
  void _startConsultation(Map<String,dynamic> doctor){showDialog(context:context,builder:(c)=>AlertDialog(title:Text('استشارة مع ${doctor['name']}'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('التخصص: ${doctor['specialty']}'),const SizedBox(height:8),Text('التقييم: ${doctor['rating']} (${doctor['reviews']} تقييم)'),const SizedBox(height:8),Text('السعر: ${doctor['price']} ر.ي')]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('إلغاء')),ElevatedButton.icon(onPressed:(){Navigator.pop(c);_chooseCallType(doctor);},icon:const Icon(Icons.call),label:const Text('الاتصال'),style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white))]));}
  void _chooseCallType(Map<String, dynamic> doctor) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'نوع الاستشارة مع ${doctor['name']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(c);
                    _startRealCall(doctor, true);
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('مكالمة فيديو'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(c);
                    _startRealCall(doctor, false);
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('مكالمة صوتية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRealCall(Map<String,dynamic> doctor,bool video) async {final me=FirebaseAuth.instance.currentUser;final doctorId=(doctor['userId']??doctor['id']??'').toString();if(me==null||doctorId.isEmpty||doctorId==me.uid){ToastService.showError('حساب الطبيب غير صالح للمكالمة');return;}try{final data=await FirebaseFirestore.instance.collection('users').doc(me.uid).get();final chatId=await ChatService().createChat(doctorId:doctorId,doctorName:doctor['name'].toString(),patientName:(data.data()?['name']??me.displayName??'مستخدم').toString(),doctorImage:doctor['image']?.toString(),patientImage:me.photoURL);final call=await CallService().initiateCall(receiverId:doctorId,receiverName:doctor['name'].toString(),receiverPhotoUrl:doctor['image']?.toString(),type:video?CallType.video:CallType.audio,chatId:chatId);if(!mounted||call==null)return;await Navigator.push(context,MaterialPageRoute(builder:(_)=>CallScreen(chatId:chatId,doctorName:doctor['name'].toString(),doctorId:doctorId,doctorImage:doctor['image']?.toString(),isVideo:video,isOutgoing:true)));}catch(e){if(mounted)ToastService.showError('تعذر بدء المكالمة: $e');}}
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('استشارة فيديو'),
        backgroundColor: dark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: dark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (_, i) {
                        final f = _filters[i];
                        final selected = f == _selectedFilter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : (dark ? const Color(0xFF1A2540) : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : (dark ? Colors.grey.shade400 : Colors.grey.shade700),
                                fontSize: 13,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _filteredDoctors.isEmpty
                        ? const Center(child: Text('لا يوجد أطباء متاحون حالياً'))
                        : ListView.builder(
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (_, i) => _doctorCard(_filteredDoctors[i], dark),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _doctorCard(Map<String,dynamic> d,bool dark){final image=d['image']?.toString()??'';final name=d['name']?.toString()??'طبيب';return Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(14)),child:Row(children:[CircleAvatar(radius:28,backgroundImage:image.isNotEmpty?NetworkImage(image):null,child:image.isEmpty?Text(name.isNotEmpty?name[0]:'ط'):null),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.bold,color:dark?Colors.white:Colors.black87)),Text(d['specialty']?.toString()??'عام',style:TextStyle(fontSize:12,color:dark?Colors.grey.shade400:Colors.grey.shade600)),const SizedBox(height:4),Text('${d['price']} ر.ي',style:TextStyle(fontSize:11,color:dark?Colors.white:Colors.black87))])),ElevatedButton(onPressed:d['available']==true?()=>_startConsultation(d):null,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:const Text('ابدأ'))]));}
}