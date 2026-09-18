import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/core/services/local_ai/smart_health_knowledge.dart';
import 'package:sehatak/core/services/local_ai/symptom_interpreter.dart';
import 'package:sehatak/presentation/screens/help_center/help_center_screen.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});
  @override State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}
class _AiChatbotScreenState extends State<AiChatbotScreen> with SingleTickerProviderStateMixin {
  final _controller=TextEditingController(); final _scroll=ScrollController(); final _bot=ChatBot();
  final List<Map<String,dynamic>> _messages=[]; bool _loading=false; late final AnimationController _typingController;
  static const _quick=<Map<String,String>>[
    {'title':'أعراضي','prompt':'اشعر ب حمى وعندي غثيان'},{'title':'طبيب','prompt':'أريد طبيباً مناسباً'},
    {'title':'دواء','prompt':'أريد معلومات عن دواء'},{'title':'تحاليل','prompt':'أين أجد التحاليل؟'},
    {'title':'خدمات التطبيق','prompt':'عرفني بخدمات صحتك'},{'title':'مساعدة','prompt':'أحتاج مساعدة من داخل التطبيق'},
  ];

  @override void initState(){super.initState();_typingController=AnimationController(vsync:this,duration:const Duration(milliseconds:1100))..repeat();_messages.add({'text':'مرحباً 👋\nأنا مساعدك الصحي داخل «صحتك». افهم كلامك حتى لو كتبته بالعامية مثل: «اشعر ب حمى»، «عندي غثيان»، «راسي يوجعني» أو «نفسي ضيق».\n\nوأقدر أيضاً أشرح لك أين تجد الأطباء والصيدلية والمختبرات والاستشارات وباقي خدمات التطبيق.','user':false,'time':DateTime.now()});}
  @override void dispose(){_typingController.dispose();_controller.dispose();_scroll.dispose();super.dispose();}

  Future<void> _send(String value) async {
    final text=value.trim(); if(text.isEmpty||_loading)return;
    setState((){_messages.add({'text':text,'user':true,'time':DateTime.now()});_controller.clear();_loading=true;}); _scrollToEnd();
    await Future<void>.delayed(const Duration(milliseconds:420));
    final symptom=SymptomInterpreter.analyze(text); final service=SmartHealthKnowledge.findService(text); Map<String,dynamic> result;
    if(symptom!=null){result={'response':symptom['response'],'type':'symptom'};}else{try{result=_bot.respond(text);}catch(_){result={'response':'خلّني أفهمك أكثر. هل تقصد عرضاً صحياً، دواءً، طبيباً، تحليلاً، أو خدمة داخل التطبيق؟\n\nمثال: «عندي حرارة وغثيان» أو «أريد طبيب أطفال».','type':'clarification'};}}
    var reply=(result['response']??'خلّني أفهم طلبك أكثر.').toString();
    if(service!=null&&symptom==null){reply+='\n\n📍 داخل صحتك\n\${service['help']}\n\nاضغط «فتح الخدمة» للانتقال إليها.';}
    if(symptom==null&&service==null&&!_looksLikeGreeting(text)){reply+='\n\nتقدر تكتبها بطريقتك، حتى بالعامية. مثلاً: «بطني يوجعني»، «نفسي ضيق»، «أبغى دكتور جلدية». وإذا ما فهمت المقصود، بسألك أسئلة بسيطة بدل ما أوقف عند «لم أعرف».';}
    if(!mounted)return; setState((){_messages.add({'text':reply,'user':false,'time':DateTime.now(),'service':service});_loading=false;});_scrollToEnd();
  }
  bool _looksLikeGreeting(String s)=>RegExp(r'^(سلام|هلا|اهلا|أهلا|مرحبا|مرحباً|السلام)').hasMatch(s.trim());
  void _scrollToEnd()=>WidgetsBinding.instance.addPostFrameCallback((_){if(_scroll.hasClients)_scroll.animateTo(_scroll.position.maxScrollExtent,duration:const Duration(milliseconds:260),curve:Curves.easeOut);});
  void _toast(String message)=>Fluttertoast.showToast(msg:message,toastLength:Toast.LENGTH_SHORT,gravity:ToastGravity.BOTTOM,backgroundColor:const Color(0xDD263238),textColor:Colors.white,fontSize:13);
  Future<void> _openService(Map<String,dynamic> s)async{final route=s['route']?.toString()??'';if(route.isEmpty){_toast('هذه الخدمة غير متاحة حالياً');return;}try{await Navigator.of(context).pushNamed(route);}catch(_){_toast('الخدمة غير متاحة من هذا المسار حالياً');}}

  @override Widget build(BuildContext context){final dark=Theme.of(context).brightness==Brightness.dark;return Scaffold(
    backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF7FAFA),
    appBar:AppBar(backgroundColor:AppColors.primary,foregroundColor:Colors.white,elevation:0,title:Row(children:[_assistantIcon(32),const SizedBox(width:8),const Expanded(child:Text('المساعد الصحي الذكي',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold))),Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(10)),child:const Text('صحتك',style:TextStyle(fontSize:9)))]),actions:[IconButton(onPressed:_clear,icon:const Icon(Icons.delete_outline))]),
    body:Column(children:[_serviceHub(dark),Expanded(child:ListView.builder(controller:_scroll,padding:const EdgeInsets.fromLTRB(12,8,12,12),itemCount:_messages.length+(_loading?1:0),itemBuilder:(_,i)=>i==_messages.length?_typing(dark):_message(_messages[i],dark))),_input(dark)]));}
  Widget _assistantIcon(double size)=>Image.asset('assets/images/services/ai_assistant.png',width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>Icon(Icons.medical_services,color:Colors.white,size:size*.65));
  Widget _serviceHub(bool dark)=>Container(padding:const EdgeInsets.fromLTRB(10,8,10,6),decoration:BoxDecoration(color:dark?const Color(0xFF111A2D):Colors.white,boxShadow:const[BoxShadow(blurRadius:5,color:Color(0x11000000))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('كيف أساعدك اليوم؟',style:TextStyle(fontWeight:FontWeight.bold,color:dark?Colors.white:Colors.black87)),const SizedBox(height:6),
    SizedBox(height:38,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:_quick.length,separatorBuilder:(_,__)=>const SizedBox(width:6),itemBuilder:(_,i)=>ActionChip(avatar:const Icon(Icons.auto_awesome,size:15),label:Text(_quick[i]['title']!),onPressed:()=>_send(_quick[i]['prompt']!)))),
    const SizedBox(height:6),SizedBox(height:64,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:SmartHealthKnowledge.services.length,separatorBuilder:(_,__)=>const SizedBox(width:6),itemBuilder:(_,i){final s=SmartHealthKnowledge.services[i];return InkWell(onTap:()=>_openService(s),borderRadius:BorderRadius.circular(12),child:Container(width:88,padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):const Color(0xFFF3F8F7),borderRadius:BorderRadius.circular(12)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(s['icon'] as IconData,color:AppColors.primary,size:21),const SizedBox(height:2),Text(s['title'] as String,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w600))])));})),
    Align(alignment:AlignmentDirectional.centerEnd,child:TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const HelpCenterScreen())),icon:const Icon(Icons.support_agent_outlined,size:17),label:const Text('مركز المساعدة'),style:TextButton.styleFrom(visualDensity:VisualDensity.compact))),
  ]));
  Widget _message(Map<String,dynamic> m,bool dark){final user=m['user']==true;final s=m['service'] as Map<String,dynamic>?;return Align(alignment:user?AlignmentDirectional.centerEnd:AlignmentDirectional.centerStart,child:Container(constraints:const BoxConstraints(maxWidth:360),margin:const EdgeInsets.symmetric(vertical:5),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:user?AppColors.primary:(dark?const Color(0xFF1A2540):Colors.white),borderRadius:BorderRadius.circular(17).copyWith(bottomRight:user?const Radius.circular(4):null,bottomLeft:user?null:const Radius.circular(4)),boxShadow:user?null:const[BoxShadow(blurRadius:3,color:Color(0x10000000))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m['text']?.toString()??'',style:TextStyle(color:user?Colors.white:(dark?Colors.white:Colors.black87),height:1.5,fontSize:14)),if(!user&&s!=null)...[const SizedBox(height:9),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>_openService(s),icon:const Icon(Icons.open_in_new,size:17),label:Text('فتح \${s['title']}'),style:FilledButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white,minimumSize:const Size(0,40))))],const SizedBox(height:3),Text(_time(m['time'] as DateTime),style:TextStyle(fontSize:9,color:user?Colors.white70:Colors.grey))])));}
  Widget _typing(bool dark)=>Align(alignment:AlignmentDirectional.centerStart,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Padding(padding:const EdgeInsetsDirectional.only(start:4,end:6,bottom:8),child:_assistantIcon(28)),AnimatedBuilder(animation:_typingController,builder:(_,__)=>Container(margin:const EdgeInsets.all(8),padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(mainAxisSize:MainAxisSize.min,children:List.generate(3,(i){final phase=(_typingController.value+i/3)%1;final scale=.65+.35*(.5+.5*math.sin(phase*2*math.pi));return Transform.scale(scale:scale,child:Container(width:7,height:7,margin:EdgeInsets.only(right:i==2?0:5),decoration:BoxDecoration(color:dark?Colors.grey[300]:Colors.grey[600],shape:BoxShape.circle)));})))),
  ]));
  Widget _input(bool dark)=>SafeArea(top:false,child:Container(padding:const EdgeInsets.fromLTRB(10,7,10,8),decoration:BoxDecoration(color:dark?const Color(0xFF111A2D):Colors.white,boxShadow:const[BoxShadow(blurRadius:6,color:Color(0x12000000))]),child:Row(children:[Expanded(child:TextField(controller:_controller,textDirection:TextDirection.rtl,textInputAction:TextInputAction.send,onSubmitted:_send,decoration:InputDecoration(hintText:'اكتب ما تشعر به أو ما تحتاجه…',filled:true,fillColor:dark?const Color(0xFF1A2540):const Color(0xFFF3F5F6),border:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:BorderSide.none),contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:11)))),const SizedBox(width:7),IconButton.filled(onPressed:_loading?null:()=>_send(_controller.text),icon:const Icon(Icons.send_rounded))])));
  void _clear(){setState((){_messages.clear();_messages.add({'text':'بدأنا محادثة جديدة. قل لي ما تشعر به أو ما تريد الوصول إليه داخل صحتك.','user':false,'time':DateTime.now()});});}
  String _time(DateTime t)=>'\${t.hour.toString().padLeft(2,'0')}:\${t.minute.toString().padLeft(2,'0')}';
}