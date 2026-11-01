import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/toast_service.dart';

class SosScreen extends StatefulWidget { const SosScreen({super.key}); @override State<SosScreen> createState()=>_SosScreenState(); }
class _SosScreenState extends State<SosScreen>{
 String _t(String value) => AppStrings.of(context).translate(value);
 int _countdown=5; bool _isActivated=false; Timer? _timer;
 @override void initState(){super.initState();_startCountdown();}
 void _startCountdown(){_timer=Timer.periodic(const Duration(seconds:1),(timer){if(!mounted){timer.cancel();return;}if(_countdown>0){setState(()=>_countdown--);}else{timer.cancel();setState(()=>_isActivated=true);}});}
 void _cancelSOS(){_timer?.cancel();Navigator.pop(context);}
 Future<void> _callAmbulance()async{const numbers=['194','191','199'];for(final n in numbers){final uri=Uri(scheme:'tel',path:n);if(await canLaunchUrl(uri)){await launchUrl(uri);return;}}if(mounted)ToastService.showError(_t('تعذر فتح تطبيق الاتصال؛ اتصل بالطوارئ يدويًا'));}
 @override void dispose(){_timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context){return Scaffold(backgroundColor:_isActivated?AppColors.error:AppColors.error.withOpacity(.95),body:SafeArea(child:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
   if(!_isActivated)...[
     Text(_t('سيتم إرسال إنذار طوارئ خلال'),style:Theme.of(context).textTheme.titleMedium?.copyWith(color:AppColors.white)),const SizedBox(height:24),Text('$_countdown',style:Theme.of(context).textTheme.displayLarge?.copyWith(color:AppColors.white,fontWeight:FontWeight.bold)),const SizedBox(height:24),TextButton(onPressed:_cancelSOS,style:TextButton.styleFrom(backgroundColor:AppColors.white,foregroundColor:AppColors.error,padding:const EdgeInsets.symmetric(horizontal:32,vertical:16)),child:Text(_t('إلغاء الإنذار')))
   ] else ...[
     const Icon(Icons.warning,size:100,color:AppColors.white),const SizedBox(height:24),Text(_t('تم إرسال إنذار الطوارئ!'),style:Theme.of(context).textTheme.headlineMedium?.copyWith(color:AppColors.white,fontWeight:FontWeight.bold),textAlign:TextAlign.center),const SizedBox(height:16),Text(_t('تم إخطار جهات الاتصال في الطوارئ والخدمات الطبية'),textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyMedium?.copyWith(color:AppColors.white.withOpacity(.9))),const SizedBox(height:32),ElevatedButton.icon(onPressed:_callAmbulance,icon:const Icon(Icons.call,size:20),label:Text(_t('الاتصال بالإسعاف')),style:ElevatedButton.styleFrom(backgroundColor:AppColors.white,foregroundColor:AppColors.error)),const SizedBox(height:16),TextButton(onPressed:()=>Navigator.pop(context),child:Text(_t('إغلاق'),style:const TextStyle(color:AppColors.white)))
   ]
 ]))));}
}
