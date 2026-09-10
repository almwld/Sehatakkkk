import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final bool isGroup;
  final String? groupImage;
  final String? lastMessage;
  const ChatRoomScreen({super.key, required this.chatId, required this.otherUserId, required this.otherUserName, this.otherUserImage, this.isGroup = false, this.groupImage, this.lastMessage});
  @override State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> with WidgetsBindingObserver {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chatService = ChatService();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _chatSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  bool _online = false, _muted = false, _pinned = false, _loading = true;
  List<MessageModel> _messages = const [];
  CollectionReference<Map<String, dynamic>> get _messagesRef => _firestore.collection('chats').doc(widget.chatId).collection('messages');

  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); _listen(); _markRead(); }
  void _listen() {
    _chatSub = _firestore.collection('chats').doc(widget.chatId).snapshots().listen((s) { if (!mounted || !s.exists) return; final d=s.data()??{}; setState(() { _muted=d['isMuted']==true; _pinned=d['isPinned']==true; }); });
    _userSub = _firestore.collection('users').doc(widget.otherUserId).snapshots().listen((s) { if (mounted && s.exists) setState(() => _online=s.data()?['isOnline']==true); });
    _messagesSub = _messagesRef.orderBy('timestamp', descending: true).limit(100).snapshots().listen((s) {
      if (!mounted) return;
      final list=s.docs.where((d)=>d.data()['timestamp'] is Timestamp).map((d)=>MessageModel.fromFirestore(d.id,d.data())).toList();
      setState(() { _messages=list; _loading=false; }); _markRead();
    }, onError:(e){ debugPrint('Chat stream error: $e'); if(mounted)setState(()=>_loading=false); });
  }
  Future<void> _markRead() async { try { await _chatService.markAsRead(widget.chatId); } catch(e){ debugPrint('markAsRead: $e'); } }
  void _startCall(bool video) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallScreen(chatId: widget.chatId, doctorName: widget.otherUserName, doctorId: widget.otherUserId, doctorImage: widget.otherUserImage ?? widget.groupImage, isVideo: video, isOutgoing: true)));
  void _openProfile() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ChatContactProfile(userId: widget.otherUserId, name: widget.otherUserName, imageUrl: widget.otherUserImage ?? widget.groupImage)));
  @override void dispose(){_messagesSub?.cancel();_chatSub?.cancel();_userSub?.cancel();WidgetsBinding.instance.removeObserver(this);super.dispose();}
  @override void didChangeAppLifecycleState(AppLifecycleState s){if(s==AppLifecycleState.resumed)_markRead();}
  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF2F5F6),appBar:AppBar(elevation:0,backgroundColor:dark?const Color(0xFF101827):Colors.white,leading:const BackButton(),titleSpacing:0,title:InkWell(onTap:_openProfile,child:Row(children:[Stack(children:[CircleAvatar(radius:21,backgroundColor:AppColors.primary.withOpacity(.12),backgroundImage:(widget.otherUserImage??widget.groupImage)!=null?CachedNetworkImageProvider(widget.otherUserImage??widget.groupImage!):null,child:(widget.otherUserImage??widget.groupImage)==null?Text(widget.otherUserName.isEmpty?'م':widget.otherUserName.characters.first):null),if(_online&&!widget.isGroup)PositionedDirectional(end:0,bottom:0,child:Container(width:12,height:12,decoration:BoxDecoration(color:Colors.green,shape:BoxShape.circle,border:Border.all(color:dark?const Color(0xFF101827):Colors.white,width:2))))]),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.isGroup?'المجموعة':widget.otherUserName,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:15,fontWeight:FontWeight.w700,color:dark?Colors.white:Colors.black87)),Text(_online?'متصل الآن':'غير متصل',style:TextStyle(fontSize:11,color:_online?Colors.green:Colors.grey))]))])),actions:[if(!widget.isGroup)IconButton(onPressed:()=>_startCall(false),icon:const Icon(Icons.call_rounded)),if(!widget.isGroup)IconButton(onPressed:()=>_startCall(true),icon:const Icon(Icons.videocam_rounded)),PopupMenuButton<String>(onSelected:(v)async{final r=_firestore.collection('chats').doc(widget.chatId);if(v=='mute')await r.update({'isMuted':!_muted});if(v=='pin')await r.update({'isPinned':!_pinned});},itemBuilder:(_)=>[PopupMenuItem(value:'mute',child:Text(_muted?'إلغاء كتم الإشعارات':'كتم الإشعارات')),PopupMenuItem(value:'pin',child:Text(_pinned?'إلغاء تثبيت المحادثة':'تثبيت المحادثة'))])]),
      body:Column(children:[Expanded(child:_loading?const Center(child:CircularProgressIndicator()):_messages.isEmpty?const Center(child:Text('ابدأ المحادثة')):ChatBackground(child:ListView.builder(reverse:true,padding:const EdgeInsets.all(8),itemCount:_messages.length,itemBuilder:(_,i){final m=_messages[i];return MessageBubble(key:ValueKey(m.id),message:m.toFirestore(),isMe:m.senderId==_auth.currentUser?.uid,onCallAgain:(_)=>_startCall(false),onReaction:(e)=>_chatService.addReaction(widget.chatId,m.id,e));})),),SafeArea(top:false,child:ChatInputBar(chatId:widget.chatId,onSendMessage:(_){},onSendImage:(_){},))])
    );
  }
}

class _ChatContactProfile extends StatelessWidget { final String userId,name; final String? imageUrl; const _ChatContactProfile({required this.userId,required this.name,this.imageUrl}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('الملف الشخصي')),body:FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(future:FirebaseFirestore.instance.collection('users').doc(userId).get(),builder:(_,s){final d=s.data?.data()??{};final image=imageUrl??d['photoUrl']?.toString()??d['imageUrl']?.toString();return Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(children:[CircleAvatar(radius:52,backgroundImage:image!=null?CachedNetworkImageProvider(image):null,child:image==null?const Icon(Icons.person,size:52):null),const SizedBox(height:14),Text(d['name']?.toString()??d['displayName']?.toString()??name,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),if('${d['specialty']??''}'.isNotEmpty)Padding(padding:const EdgeInsets.only(top:8),child:Text(d['specialty'].toString())),if('${d['bio']??''}'.isNotEmpty)Padding(padding:const EdgeInsets.only(top:8),child:Text(d['bio'].toString(),textAlign:TextAlign.center))])));})));
}
