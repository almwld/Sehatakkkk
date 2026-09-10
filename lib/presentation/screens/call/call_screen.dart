import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CallScreen extends StatefulWidget {
  final String chatId; final String? callId; final String doctorName, doctorId; final bool isVideo; final String? doctorImage; final bool isOutgoing;
  const CallScreen({super.key, required this.chatId, this.callId, required this.doctorName, required this.doctorId, this.isVideo=true, this.doctorImage, this.isOutgoing=true});
  @override State<CallScreen> createState()=>_CallScreenState();
}
class _CallScreenState extends State<CallScreen> {
  final _live=LiveKitService(), _calls=CallService(); Room? _room; StreamSubscription<CallModel?>? _callSub; Timer? _timer; Timer? _answerTimeout; String? _callId,_roomName,_error; VideoTrack? _remote,_local; int _seconds=0; DateTime? _connectedAt; bool _connecting=true,_muted=false,_camera=true,_speaker=false,_joined=false,_ending=false;

  @override void initState(){super.initState();_connect();}

  Future<void> _connect() async {
    try {
      final user=FirebaseAuth.instance.currentUser;
      if(user==null) throw StateError('يجب تسجيل الدخول');
      CallModel? call;
      if(widget.isOutgoing){
        call=await _calls.initiateCall(receiverId:widget.doctorId,receiverName:widget.doctorName,receiverPhotoUrl:widget.doctorImage,type:widget.isVideo?CallType.video:CallType.audio,chatId:widget.chatId,idempotencyKey:'call_${DateTime.now().microsecondsSinceEpoch}');
      } else if(widget.callId!=null){
        call=await _calls.streamCall(widget.callId!).first;
        if(call == null) throw StateError('المكالمة غير موجودة');
        if(call!.receiverId != null && call!.receiverId != user.uid) throw StateError('هذه المكالمة ليست موجهة لهذا المستخدم');
      }
      if(call==null) throw StateError('تعذر العثور على المكالمة');
      _callId=call.id;
      _roomName=(call.liveKitRoomName?.trim().isNotEmpty==true?call.liveKitRoomName:'call_${call.id}');
      _callSub=_calls.streamCall(call.id).listen((c){
        if(!mounted||c==null)return;
        if(c.status==CallStatus.connected&&!_joined){_answerTimeout?.cancel();_join(c,user);}
        else if(c.status==CallStatus.cancelled||c.status==CallStatus.rejected||c.status==CallStatus.missed||c.status==CallStatus.ended){if(!_ending)_finishFromRemote();}
      });
      if(widget.isOutgoing && call.status != CallStatus.connected){
        _answerTimeout=Timer(const Duration(seconds:45),() async {
          if(_ending||_joined)return;
          try{if(_callId!=null)await _calls.missCall(_callId!);}catch(e){debugPrint('call answer timeout: $e');}
          if(mounted)await _finishFromRemote();
        });
      }
      if(call.status==CallStatus.connected && !_joined) await _join(call,user);
      if(mounted)setState(()=>_connecting=!_joined);
    }catch(e){
      debugPrint('Call connect: $e');
      if(mounted)setState((){_connecting=false;_error=e.toString();});
      ToastService.showError('فشل تجهيز المكالمة');
    }
  }

  Future<void> _join(CallModel call, User user) async {
    if(_joined||_ending)return;
    if(widget.isVideo&&!(await Permission.camera.request()).isGranted)throw StateError('يرجى منح إذن الكاميرا');
    if(!(await Permission.microphone.request()).isGranted)throw StateError('يرجى منح إذن الميكروفون');
    _room=await _live.startCall(roomName:_roomName!,callerName:user.displayName??widget.doctorName,isVideo:widget.isVideo);
    _joined=true;_connectedAt=call.connectedAt?.toDate()??DateTime.now();_seconds=DateTime.now().difference(_connectedAt!).inSeconds.clamp(0,1<<30);
    _timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted&&_connectedAt!=null)setState(()=>_seconds=DateTime.now().difference(_connectedAt!).inSeconds.clamp(0,1<<30));});
    _room!.events.on<ParticipantConnectedEvent>((e)=>_bind(e.participant));_room!.events.on<TrackSubscribedEvent>((e)=>_bind(e.participant));_room!.events.on<TrackPublishedEvent>((e)=>_bind(e.participant));_room!.events.on<ParticipantDisconnectedEvent>((_) {if(mounted)setState(()=>_remote=null);});
    for(final p in _room!.remoteParticipants.values){_bind(p);} final p=_room!.localParticipant;if(p!=null)_bind(p);
    if(mounted)setState(()=>_connecting=false);
  }
  void _bind(Participant p){for(final pub in p.videoTracks){final t=pub.track;if(t is VideoTrack&&mounted)setState(()=>p is LocalParticipant?_local=t:_remote=t);}}
  Future<void> _finishFromRemote() async {if(_ending)return;_ending=true;_answerTimeout?.cancel();_timer?.cancel();_callSub?.cancel();SoundManager().stopAll();await _live.endCall();if(mounted)Navigator.of(context).pop();}
  Future<void> _end() async {if(_ending)return;_ending=true;_answerTimeout?.cancel();_timer?.cancel();_callSub?.cancel();SoundManager().stopAll();try{if(_callId!=null)await _calls.endCall(_callId!,durationSeconds:_joined?_seconds:0);}catch(e){debugPrint('call state end: $e');}await _live.endCall();if(mounted)Navigator.of(context).pop();}
  Future<void> _mute()async{final e=await _live.toggleMicrophone();if(mounted)setState(()=>_muted=!e);} Future<void> _cam()async{final e=await _live.toggleCamera();if(mounted)setState(()=>_camera=e);}
  @override void dispose(){_answerTimeout?.cancel();_timer?.cancel();_callSub?.cancel();SoundManager().stopAll();if(_joined)_live.endCall();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.black,body:SafeArea(child:Stack(children:[Positioned.fill(child:widget.isVideo&&_remote!=null?VideoTrackRenderer(_remote!):Center(child:Column(mainAxisSize:MainAxisSize.min,children:[CircleAvatar(radius:54,backgroundImage:widget.doctorImage!=null?NetworkImage(widget.doctorImage!):null,child:widget.doctorImage==null?const Icon(Icons.person,color:Colors.white,size:48):null),const SizedBox(height:18),Text(widget.doctorName,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(_connecting?(widget.isOutgoing?'في انتظار قبول المكالمة...':'جاري الاتصال...'):_fmt(_seconds),style:const TextStyle(color:Colors.white70))]))),if(widget.isVideo&&_local!=null)PositionedDirectional(top:18,end:18,child:ClipRRect(borderRadius:BorderRadius.circular(14),child:SizedBox(width:110,height:160,child:VideoTrackRenderer(_local!)))),if(_error!=null)Center(child:Container(margin:const EdgeInsets.all(24),padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Colors.black87,borderRadius:BorderRadius.circular(16)),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.error_outline,color:Colors.redAccent,size:42),const SizedBox(height:10),const Text('تعذر بدء المكالمة',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(_error!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,fontSize:11)),const SizedBox(height:14),ElevatedButton(onPressed:_end,child:const Text('إغلاق'))]))),if(_error==null)Positioned(bottom:28,left:0,right:0,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[_btn(_muted?Icons.mic_off:Icons.mic,_mute),if(widget.isVideo)_btn(_camera?Icons.videocam:Icons.videocam_off,_cam),_btn(_speaker?Icons.volume_up:Icons.volume_down,(){setState(()=>_speaker=!_speaker);_live.setSpeakerphone(_speaker);}),_btn(Icons.call_end,_end,red:true)]))])));
  Widget _btn(IconData i,VoidCallback f,{bool red=false})=>Padding(padding:const EdgeInsets.symmetric(horizontal:7),child:FloatingActionButton(heroTag:'${i.codePoint}${red?'r':''}',mini:true,backgroundColor:red?Colors.red:Colors.white12,onPressed:f,child:Icon(i,color:Colors.white)));
  String _fmt(int s)=>'${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';
}
