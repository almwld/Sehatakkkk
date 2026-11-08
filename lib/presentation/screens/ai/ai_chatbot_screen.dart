import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/local_storage_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/core/services/local_ai/smart_health_knowledge.dart';
import 'package:sehatak/core/services/local_ai/symptom_interpreter.dart';
import 'package:sehatak/core/services/local_ai/local_intent_engine.dart';
import 'package:sehatak/core/services/local_ai/dialogue_state.dart';
import 'package:sehatak/core/services/local_ai/medical_safety_engine.dart';
import 'package:sehatak/core/services/local_ai/medical_knowledge_catalog.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});
  @override State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}
class _AiChatbotScreenState extends State<AiChatbotScreen> with SingleTickerProviderStateMixin {
  String _t(String value) => AppStrings.of(context).translate(value);
  String _localized(String ar, String en, String fr) {
    final language = AppStrings.of(context).locale.languageCode;
    return language == 'fr' ? fr : (language == 'en' ? en : ar);
  }
  final _controller=TextEditingController(); final _scroll=ScrollController(); final _bot=ChatBot();
  final List<Map<String,dynamic>> _messages=[]; bool _loading=false; late final AnimationController _typingController; LocalDialogueState _dialogue=LocalDialogueState();
  final LocalStorageService _historyStore=LocalStorageService();
  String _sessionId='assistant_guest_v1'; bool _historyReady=false; bool _historyLoading=false;
  static const _quick=<Map<String,String>>[
    {'title':'أعراضي','title_en':'My symptoms','title_fr':'Mes symptômes','prompt_ar':'اشعر ب حمى وعندي غثيان','prompt_en':'I have a fever and nausea','prompt_fr':'J’ai de la fièvre et des nausées'},
    {'title':'طبيب','title_en':'Doctor','title_fr':'Médecin','prompt_ar':'أريد طبيباً مناسباً','prompt_en':'I want to find a suitable doctor','prompt_fr':'Je veux trouver un médecin adapté'},
    {'title':'دواء','title_en':'Medicine','title_fr':'Médicament','prompt_ar':'أريد معلومات آمنة عن دواء','prompt_en':'I need safe information about a medicine','prompt_fr':'Je veux des informations fiables sur un médicament'},
    {'title':'تحاليل','title_en':'Lab tests','title_fr':'Analyses','prompt_ar':'أين أجد التحاليل؟','prompt_en':'Where can I find laboratory tests?','prompt_fr':'Où puis-je trouver un laboratoire ?'},
    {'title':'خدمات التطبيق','title_en':'App services','title_fr':'Services de l’application','prompt_ar':'عرفني بخدمات صحتك','prompt_en':'Show me Sehatak services','prompt_fr':'Présentez-moi les services de Sehatak'},
    {'title':'مساعدة','title_en':'Help','title_fr':'Aide','prompt_ar':'أحتاج مساعدة من داخل التطبيق','prompt_en':'I need help using the app','prompt_fr':'J’ai besoin d’aide pour utiliser l’application'},
  ];

  @override void initState(){super.initState();_restoreHistory();_typingController=AnimationController(vsync:this,duration:const Duration(milliseconds:1100))..repeat();}
  @override void dispose(){_typingController.dispose();_controller.dispose();_scroll.dispose();super.dispose();}

  Future<void> _send(String value) async {
    final text=value.trim(); if(text.isEmpty||_loading||!_historyReady)return;
    var historyWriteFailed=false;
    final userTime=DateTime.now();
    setState((){_messages.add({'text':text,'user':true,'time':userTime});_controller.clear();_loading=true;}); _scrollToEnd();
    try { await _historyStore.saveMessage(sessionId:_sessionId,message:text,isUser:true,type:'user'); } catch (_) { historyWriteFailed=true; }
    await Future<void>.delayed(const Duration(milliseconds:220));
    final intent=LocalAiIntentEngine.classify(text); final safety=MedicalSafetyEngine.assess(text,languageCode:AppStrings.of(context).locale.languageCode); final knowledge=MedicalKnowledgeCatalog.answer(text,AppStrings.of(context).locale.languageCode); final symptom=SymptomInterpreter.analyze(text,languageCode:AppStrings.of(context).locale.languageCode); final services=intent.services.isNotEmpty?intent.services:SmartHealthKnowledge.findServices(text); final service=services.isEmpty?null:services.first; Map<String,dynamic> result;
    try { await _dialogue.update(topic: symptom?['symptoms']?.toString() ?? (services.isNotEmpty ? services.first['title']?.toString() : null), intent:intent.intent.name, userMessage:text); } catch (_) { /* Conversation memory must never block a chatbot reply. */ }
    if(knowledge!=null){result=knowledge;}else if(safety.emergency){result={'response':safety.response,'type':'emergency'};}else if(symptom!=null){result={'response':symptom['response'],'type':'symptom'};}else if(intent.intent==LocalAiIntent.greeting){result={'response':_localized('أهلاً بك. اكتب سؤالك بطريقتك المعتادة وسأساعدك أو أوجّهك إلى الخدمة المناسبة.','Hello. Ask in your own words and I’ll help or guide you to the right service.','Bonjour. Posez votre question avec vos propres mots ; je vous aiderai ou vous orienterai vers le bon service.'),'type':'greeting'};}else{try{result=_bot.respond(text,languageCode:AppStrings.of(context).locale.languageCode);}catch(_){result={'response':_localized('اذكر ما تحتاجه أو الأعراض التي تشعر بها.','Tell me what you need or describe your symptoms.','Dites-moi ce dont vous avez besoin ou décrivez vos symptômes.'),'type':'clarification'};}}
    var reply=(result['response']??_localized('ما الذي تريد معرفته؟','What would you like to know?','Que souhaitez-vous savoir ?')).toString();
    if(result['source']!=null){
      reply+='\n\n${_localized('المصدر','Source','Source')}: ${result['source']}';
      if(result['source_url']!=null) reply+='\n${result['source_url']}';
      final lang=AppStrings.of(context).locale.languageCode;
      final reviewNote=lang=='fr'
          ? 'Validation clinique locale en attente.'
          : (lang=='en' ? 'Local clinician review is pending.' : 'ما زالت المراجعة السريرية المحلية مطلوبة.');
      reply+='\n${reviewNote}';
    }
    if(services.isNotEmpty&&symptom==null&&knowledge==null){reply+='\n\n📍 ${_localized('داخل صحتك','In Sehatak','Dans Sehatak')}\n${services.map((s)=>'• ${_t(s['title'] as String)}: ${_t(s['help'] as String)}').join('\n')}\n\n${_localized('اختر الخدمة المناسبة أدناه.','Choose the relevant service below.','Choisissez le service approprié ci-dessous.')}';}
    if(!mounted)return; final responseTime=DateTime.now(); setState((){_messages.add({'text':reply,'user':false,'time':responseTime,'service':service,'services':services});_loading=false;});
    try { await _historyStore.saveMessage(sessionId:_sessionId,message:reply,isUser:false,type:result['type']?.toString()??'assistant'); } catch (_) { historyWriteFailed=true; }
    _scrollToEnd();
    if(historyWriteFailed){final lang=AppStrings.of(context).locale.languageCode;_toast(lang=='fr'?'Impossible d’enregistrer tout l’historique sur cet appareil.':(lang=='en'?'Chat history could not be fully saved on this device.':'تعذر حفظ سجل المحادثة بالكامل على هذا الجهاز.'));}
  }
  void _scrollToEnd()=>WidgetsBinding.instance.addPostFrameCallback((_){if(_scroll.hasClients)_scroll.animateTo(_scroll.position.maxScrollExtent,duration:const Duration(milliseconds:260),curve:Curves.easeOut);});
  void _toast(String message)=>Fluttertoast.showToast(msg:message,toastLength:Toast.LENGTH_SHORT,gravity:ToastGravity.BOTTOM,backgroundColor:const Color(0xDD263238),textColor:Colors.white,fontSize:13);
  Future<void> _openService(Map<String,dynamic> s)async{final route=s['route']?.toString()??'';if(route.isEmpty){_toast(_localized('لا يوجد مسار متاح لهذه الخدمة حالياً','This service is not available from this screen yet.','Ce service n’est pas encore accessible depuis cet écran.'));return;}try{await context.push(route);}catch(_){_toast(_localized('تعذر فتح الخدمة من المسار الحالي','Could not open this service from the current screen.','Impossible d’ouvrir ce service depuis l’écran actuel.'));}}

  @override Widget build(BuildContext context){final dark=Theme.of(context).brightness==Brightness.dark;return Scaffold(
    backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF7FAFA),
    appBar:AppBar(backgroundColor:AppColors.primary,foregroundColor:Colors.white,elevation:0,title:Row(children:[_assistantIcon(32),const SizedBox(width:8),Expanded(child:Text(_t('المساعد الصحي الذكي'),style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold))),Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(10)),child:Text(_t('صحتك'),style:const TextStyle(fontSize:9)))]),actions:[IconButton(onPressed:_historyReady?_clear:null,tooltip:_localized('محادثة جديدة','New chat','Nouvelle discussion'),icon:const Icon(Icons.delete_outline))]),
    body:Column(children:[Expanded(child:!_historyReady?const Center(child:CircularProgressIndicator()):ListView.builder(controller:_scroll,padding:const EdgeInsets.fromLTRB(12,8,12,12),itemCount:_messages.length+(_loading?1:0),itemBuilder:(_,i)=>i==_messages.length?_typing(dark):_message(_messages[i],dark))),_quickSuggestions(dark),_input(dark)]));}
  Widget _assistantIcon(double size)=>Image.asset('assets/images/services/ai_assistant.webp',width:size,height:size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>Icon(Icons.medical_services,color:Colors.white,size:size*.65));
  Widget _quickSuggestions(bool dark)=>Container(
    width:double.infinity,
    padding:const EdgeInsetsDirectional.fromSTEB(10,8,10,6),
    decoration:BoxDecoration(
      color:dark?const Color(0xFF111A2D):Colors.white,
      boxShadow:const[BoxShadow(blurRadius:5,color:Color(0x11000000))],
    ),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
      Text(AppStrings.of(context).locale.languageCode=='fr'?'Questions suggérées':(AppStrings.of(context).locale.languageCode=='en'?'Suggested questions':'أسئلة مقترحة'),style:TextStyle(fontWeight:FontWeight.w600,fontSize:12,color:dark?Colors.white70:Colors.black54)),
      const SizedBox(height:5),
      SizedBox(height:36,child:ListView.separated(
        scrollDirection:Axis.horizontal,
        itemCount:_quick.length,
        separatorBuilder:(_,__)=>const SizedBox(width:7),
        itemBuilder:(_,i)=>ActionChip(
          visualDensity:VisualDensity.compact,
          avatar:const Icon(Icons.chat_bubble_outline,size:14),
          label:Text(AppStrings.of(context).locale.languageCode=='fr'?_quick[i]['title_fr']!:(AppStrings.of(context).locale.languageCode=='en'?_quick[i]['title_en']!:_quick[i]['title']!),style:const TextStyle(fontSize:11)),
          onPressed:()=>_send(_quick[i][AppStrings.of(context).locale.languageCode=='fr'?'prompt_fr':(AppStrings.of(context).locale.languageCode=='en'?'prompt_en':'prompt_ar')]!),
        ),
      )),
    ]),
  );
  Widget _message(Map<String,dynamic> m,bool dark){final user=m['user']==true;final s=m['service'] as Map<String,dynamic>?; final services=(m['services'] as List?)?.cast<Map<String,dynamic>>() ?? const <Map<String,dynamic>>[];return Align(alignment:user?AlignmentDirectional.centerEnd:AlignmentDirectional.centerStart,child:Container(constraints:const BoxConstraints(maxWidth:360),margin:const EdgeInsets.symmetric(vertical:5),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:user?AppColors.primary:(dark?const Color(0xFF1A2540):Colors.white),borderRadius:BorderRadius.circular(17).copyWith(bottomRight:user?const Radius.circular(4):null,bottomLeft:user?null:const Radius.circular(4)),boxShadow:user?null:const[BoxShadow(blurRadius:3,color:Color(0x10000000))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m['text']?.toString()??'',style:TextStyle(color:user?Colors.white:(dark?Colors.white:Colors.black87),height:1.5,fontSize:14)),if(!user&&(services.isNotEmpty||s!=null))...[const SizedBox(height:9),Wrap(spacing:7,runSpacing:7,children:(services.isNotEmpty?services:<Map<String,dynamic>>[s!]).map((item)=>OutlinedButton.icon(onPressed:()=>_openService(item),icon:Icon(item['icon'] as IconData,size:16),label:Text('${_t('فتح')} ${_t(item['title'] as String)}'))).toList())],const SizedBox(height:3),Text(_time(m['time'] as DateTime),style:TextStyle(fontSize:9,color:user?Colors.white70:Colors.grey))])));}
  Widget _typing(bool dark)=>Align(alignment:AlignmentDirectional.centerStart,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Padding(padding:const EdgeInsetsDirectional.only(start:4,end:6,bottom:8),child:_assistantIcon(28)),AnimatedBuilder(animation:_typingController,builder:(_,__)=>Container(margin:const EdgeInsets.all(8),padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(mainAxisSize:MainAxisSize.min,children:List.generate(3,(i){final phase=(_typingController.value+i/3)%1;final scale=.65+.35*(.5+.5*math.sin(phase*2*math.pi));return Transform.scale(scale:scale,child:Container(width:7,height:7,margin:EdgeInsets.only(right:i==2?0:5),decoration:BoxDecoration(color:dark?Colors.grey[300]:Colors.grey[600],shape:BoxShape.circle)));})))),
  ]));
  Widget _input(bool dark)=>SafeArea(top:false,child:Container(padding:const EdgeInsets.fromLTRB(10,7,10,8),decoration:BoxDecoration(color:dark?const Color(0xFF111A2D):Colors.white,boxShadow:const[BoxShadow(blurRadius:6,color:Color(0x12000000))]),child:Row(children:[Expanded(child:TextField(controller:_controller,textDirection:AppStrings.of(context).locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,textInputAction:TextInputAction.send,onSubmitted:_send,decoration:InputDecoration(hintText:_localized('اكتب ما تشعر به أو ما تحتاجه…','Describe your symptoms or ask what you need…','Décrivez vos symptômes ou posez votre question…'),filled:true,fillColor:dark?const Color(0xFF1A2540):const Color(0xFFF3F5F6),border:OutlineInputBorder(borderRadius:BorderRadius.circular(24),borderSide:BorderSide.none),contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:11)))),const SizedBox(width:7),IconButton.filled(onPressed:(_loading||!_historyReady)?null:()=>_send(_controller.text),icon:const Icon(Icons.send_rounded))])));
  Future<void> _restoreHistory() async {
    if(_historyLoading)return; _historyLoading=true;
    try {
      final uid=FirebaseAuth.instance.currentUser?.uid;
      _sessionId=uid==null?'assistant_guest_v1':'assistant_user_$uid';
      _dialogue=LocalDialogueState(storageKey:'local_ai_dialogue_$_sessionId');
      await _dialogue.load();
      await _historyStore.initialize();
      final rows=await _historyStore.getConversation(_sessionId);
      if(!mounted)return;
      setState(() {
        _messages.addAll(rows.map((row)=>{'text':row['message']?.toString()??'','user':row['is_user']==1,'time':DateTime.fromMillisecondsSinceEpoch((row['timestamp'] as num?)?.toInt()??DateTime.now().millisecondsSinceEpoch)}));
        if(_messages.isEmpty){_messages.add({'text':'${_localized('مرحباً 👋','Hello 👋','Bonjour 👋')}\\n${_t('المساعد الصحي الذكي')} — ${_localized('كيف أساعدك اليوم؟','How can I help today?','Comment puis-je vous aider aujourd’hui ?')}','user':false,'time':DateTime.now()});}
        _historyReady=true;
      });
      _scrollToEnd();
    } catch (_) {
      if(mounted){setState(() {if(_messages.isEmpty){_messages.add({'text':_localized('مرحباً، كيف أساعدك اليوم؟','Hello, how can I help today?','Bonjour, comment puis-je vous aider aujourd’hui ?'),'user':false,'time':DateTime.now()});}_historyReady=true;});final lang=AppStrings.of(context).locale.languageCode;_toast(lang=='fr'?'Impossible de restaurer l’historique local.':(lang=='en'?'Could not restore local chat history.':'تعذر استعادة سجل المحادثة المحلي.'));}
    } finally {_historyLoading=false;}
  }
  Future<void> _clear() async {
    var clearFailed=false;
    try { await _dialogue.clear(); } catch (_) { clearFailed=true; }
    try { await _historyStore.clearConversation(_sessionId); } catch (_) { clearFailed=true; }
    if(!mounted)return;
    setState((){_messages.clear();_messages.add({'text':_localized('مرحباً، كيف أساعدك؟','Hello, how can I help?','Bonjour, comment puis-je vous aider ?'),'user':false,'time':DateTime.now()});});
    if(clearFailed){final lang=AppStrings.of(context).locale.languageCode;_toast(lang=='fr'?'L’historique n’a pas pu être entièrement effacé.':(lang=='en'?'Chat history could not be fully cleared.':'تعذر مسح سجل المحادثة بالكامل.'));}
  }
  String _time(DateTime t)=>'${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
}